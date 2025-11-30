USE Project_Final_Unemployment;

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