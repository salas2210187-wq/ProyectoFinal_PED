use Project_Final_Unemployment;

-- ========================================================
--                  Vistas Generales
-- ========================================================

-- -------------------------------------------------------------------------

-- 1. CREACIÓN DE LA VISTA: TENDENCIA DE DESEMPLEO Y OCUPACIÓN GENERAL
CREATE VIEW Vista_Evolucion_Desempleo_General AS
SELECT
    P.id_quarter AS ID_Periodo,
    P.quarter_label AS Periodo_Trimestre,
    P.year_num AS Año,
    TP.total_population_count AS PEA_Total,
    U.total_unemployed_count AS Desocupados_Total,
    -- Cálculo de Ocupados: PEA - Desocupados
    (TP.total_population_count - U.total_unemployed_count) AS Ocupados_Total,
    -- Tasa de Desocupación: (Desocupados / PEA) * 100
    ROUND((U.total_unemployed_count * 100.0) / TP.total_population_count, 2) AS Tasa_Desocupacion_Porc,
    -- Tasa de Ocupación: (Ocupados / PEA) * 100
    ROUND(((TP.total_population_count - U.total_unemployed_count) * 100.0) / TP.total_population_count, 2) AS Tasa_Ocupacion_Porc
FROM Periods P
JOIN TotalPopulation TP ON P.id_quarter = TP.id_quarter
JOIN Unemployment U ON P.id_quarter = U.id_quarter
ORDER BY P.id_quarter;

-- 2. EJEMPLO DE USO (Filtro para los años 2023 y 2024 según el objetivo)
SELECT * FROM Vista_Evolucion_Desempleo_General WHERE Año IN (2023, 2024);


-- -------------------------------------------------------------------------

-- 1. CREACIÓN DE LA VISTA: DISTRIBUCIÓN DE PEA POR GÉNERO
CREATE VIEW Vista_Desbalance_Genero_PEA AS
SELECT
    P.id_quarter AS ID_Periodo,
    P.quarter_label AS Periodo_Trimestre,
    G.gender_label AS Sexo,
    -- Desocupados por género (desde LaborActivity)
    LA.unemployed_count AS Desocupados,
    -- Ocupados Estimados (usamos el total de Salariados por género como proxy)
    SM.total_count AS Ocupados_Estimados,
    -- PEA Estimada por género: Desocupados + Ocupados Estimados
    (SM.total_count + LA.unemployed_count) AS PEA_Estimada_Total
FROM Periods P
JOIN Genders G ON G.id_gender IN (1, 2) -- Filtrar por Hombre y Mujer
JOIN LaborActivity LA ON P.id_quarter = LA.id_quarter AND G.id_gender = LA.id_gender
JOIN SalaryMetrics SM ON P.id_quarter = SM.id_quarter AND G.id_gender = SM.id_gender AND SM.id_formality = 0 -- id_formality=0 es el total, sin distinguir formal/informal
ORDER BY P.id_quarter, G.id_gender;

-- 2. EJEMPLO DE USO (Filtro para los años 2023 y 2024 según el objetivo)
SELECT * FROM Vista_Desbalance_Genero_PEA WHERE SUBSTR(Periodo_Trimestre, 1, 4) IN ('2023', '2024');

-- ------------------------------------------------------------------------------

-- 1. CREACIÓN DE LA VISTA: SALARIO PROMEDIO POR FORMALIDAD
CREATE VIEW Vista_Salario_Por_Formalidad AS
SELECT
    P.id_quarter AS ID_Periodo,
    P.quarter_label AS Periodo_Trimestre,
    F.formality_label AS Clasificacion,
    SM.average_monthly_wage AS Salario_Promedio_Mensual,
    SM.total_count AS Conteo_Poblacional
FROM Periods P
JOIN SalaryMetrics SM ON P.id_quarter = SM.id_quarter
JOIN Formality F ON SM.id_formality = F.id_formality
WHERE SM.id_gender = 0 -- Total general de salarios por formalidad
    AND SM.id_formality IN (1, 2) -- Empleo Informal (1) y Empleo Formal (2)
ORDER BY P.id_quarter DESC, F.id_formality;

-- 2. EJEMPLO DE USO (Obtener el último periodo disponible)
SELECT * FROM Vista_Salario_Por_Formalidad WHERE ID_Periodo = (SELECT MAX(ID_Periodo) FROM Periods);

-- --------------------------------------------------------------------------------

-- 1. CREACIÓN DE LA VISTA: SALARIO PROMEDIO POR GÉNERO
CREATE VIEW Vista_Salario_Por_Genero AS
SELECT
    P.id_quarter AS ID_Periodo,
    P.quarter_label AS Periodo_Trimestre,
    G.gender_label AS Sexo,
    SM.average_monthly_wage AS Salario_Promedio_Mensual,
    SM.total_count AS Conteo_Poblacional
FROM Periods P
JOIN SalaryMetrics SM ON P.id_quarter = SM.id_quarter
JOIN Genders G ON SM.id_gender = G.id_gender
WHERE SM.id_formality = 0 -- Total general de salarios por género
    AND SM.id_gender IN (1, 2) -- Hombre (1) y Mujer (2)
ORDER BY P.id_quarter DESC, G.id_gender;

-- 2. EJEMPLO DE USO (Obtener el último periodo disponible)
SELECT * FROM Vista_Salario_Por_Genero WHERE ID_Periodo = (SELECT MAX(ID_Periodo) FROM Periods);


-- ------------------------------------------------------------



-- ========================================================
--                  Vistas Especificas
-- ========================================================


CREATE VIEW Vista_Composicion_Formalidad AS
SELECT 
    P.quarter_label AS Periodo,
    P.year_num AS Año,
    F.formality_label AS Tipo_Empleo,
    SM.total_count AS Cantidad_Trabajadores,
    SM.average_monthly_wage AS Salario_Promedio_Mensual
FROM SalaryMetrics SM
JOIN Periods P ON SM.id_quarter = P.id_quarter
JOIN Formality F ON SM.id_formality = F.id_formality
WHERE SM.id_formality IN (1, 2) -- Filtramos solo Formal (2) e Informal (1)
ORDER BY P.year_num, P.quarter_num;

-- EJEMPLO: Ver la cantidad de trabajadores informales en los años 2023 y 2024
select * from Vista_Composicion_Formalidad where Tipo_Empleo = 'Empleo Informal' and Año in (2023, 2024);


-- --------------------------------------------------------------


CREATE VIEW Vista_Brecha_Salarial AS
SELECT 
    P.quarter_label AS Periodo,
    P.year_num AS Año,
    -- Subconsultas o CASE para pivotar los datos en una sola fila por periodo
    MAX(CASE WHEN SM.id_gender = 1 THEN SM.average_monthly_wage END) AS Salario_Hombres,
    MAX(CASE WHEN SM.id_gender = 2 THEN SM.average_monthly_wage END) AS Salario_Mujeres,
    -- Cálculo directo de la brecha en pesos
    (MAX(CASE WHEN SM.id_gender = 1 THEN SM.average_monthly_wage END) - 
     MAX(CASE WHEN SM.id_gender = 2 THEN SM.average_monthly_wage END)) AS Diferencia_Salarial
FROM SalaryMetrics SM
JOIN Periods P ON SM.id_quarter = P.id_quarter
WHERE SM.id_formality = 0 -- Usamos el promedio general (sin filtrar formalidad)
GROUP BY P.id_quarter, P.quarter_label, P.year_num;

-- EJEMPLO: Ver la diferencia entre salario por genero en los años 2023 y 2024
select * from Vista_Brecha_Salarial where Año IN (2023, 2024);

-- --------------------------------------------------------------

CREATE VIEW Vista_Resumen_Anual AS
SELECT 
    P.year_num AS Año,
    SUM(U.total_unemployed_count) AS Total_Desocupados_Acumulado, -- Es el total real
    AVG(U.total_unemployed_count) AS Promedio_Desocupados_Trimestral, -- Es el promedio por trimestre
    ROUND(AVG((U.total_unemployed_count * 100.0) / TP.total_population_count), 2) AS Tasa_Desempleo_Promedio_Anual
FROM Periods P
JOIN Unemployment U ON P.id_quarter = U.id_quarter
JOIN TotalPopulation TP ON P.id_quarter = TP.id_quarter
GROUP BY P.year_num
ORDER BY P.year_num;

-- EJEMPLO: Resumen de tasa de desempleo de los años 2023 y 2024
select * from Vista_Resumen_Anual where Año in (2023, 2024);