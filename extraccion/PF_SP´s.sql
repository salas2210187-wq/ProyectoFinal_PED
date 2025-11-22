USE Project_Final_Unemployment;

-- Tablas Padres
-- ======================================================================
-- 1. TABLA PERIODS 
-- ======================================================================

-- GET ALL
DELIMITER //
CREATE PROCEDURE SP_GETALL_PERIODS()
BEGIN
	SELECT * FROM Periods;
END//
DELIMITER ;

-- GET BY ID 
DELIMITER //
CREATE PROCEDURE SP_GETBYID_PERIOD(IN p_id_quarter INT)
BEGIN
	SELECT * FROM Periods WHERE id_quarter = p_id_quarter;
END //
DELIMITER ;

-- INSERT 
DELIMITER //
CREATE PROCEDURE SP_INSERT_PERIOD(
    IN p_id_quarter INT,
    IN p_quarter_label VARCHAR(10),
    IN p_year_num INT,
    IN p_quarter_num INT
)
BEGIN
    INSERT INTO Periods(id_quarter, quarter_label, year_num, quarter_num) 
    VALUES (p_id_quarter, p_quarter_label, p_year_num, p_quarter_num);
END //
DELIMITER ;

-- UPDATE 
DELIMITER //
CREATE PROCEDURE SP_UPDATE_PERIOD(
    IN p_id_quarter INT,
    IN p_New_quarter_label VARCHAR(10),
    IN p_New_year_num INT,
    IN p_New_quarter_num INT
)
BEGIN
    UPDATE Periods 
    SET quarter_label = p_New_quarter_label, 
        year_num = p_New_year_num, 
        quarter_num = p_New_quarter_num 
    WHERE id_quarter = p_id_quarter;
END //
DELIMITER ;

-- DELETE BY ID
DELIMITER //
CREATE PROCEDURE SP_DELETE_PERIOD_BY_ID(IN p_id_quarter INT)
BEGIN
    DELETE FROM Periods WHERE id_quarter = p_id_quarter;
END //
DELIMITER ;

-- DELETE ALL
DELIMITER //
CREATE PROCEDURE SP_DELETE_ALL_PERIODS()
BEGIN
    DELETE FROM Periods;  
END //
DELIMITER ;


-- ======================================================================
-- 2. TABLA GENDERS  
-- ======================================================================

-- GET ALL
DELIMITER //
CREATE PROCEDURE SP_GETALL_GENDERS()
BEGIN
	SELECT * FROM Genders;
END//
DELIMITER ;

-- GET BY ID 
DELIMITER //
CREATE PROCEDURE SP_GETBYID_GENDER(IN p_id_gender INT)
BEGIN
	SELECT * FROM Genders WHERE id_gender = p_id_gender;
END //
DELIMITER ;

-- INSERT 
DELIMITER //
CREATE PROCEDURE SP_INSERT_GENDER(
    IN p_id_gender INT,
    IN p_gender_label VARCHAR(20)
)
BEGIN
    INSERT INTO Genders(id_gender, gender_label) VALUES (p_id_gender, p_gender_label);
END //
DELIMITER ;

-- UPDATE 
DELIMITER //
CREATE PROCEDURE SP_UPDATE_GENDER(
    IN p_id_gender INT,
    IN p_New_gender_label VARCHAR(20)
)
BEGIN
    UPDATE Genders SET gender_label = p_New_gender_label WHERE id_gender = p_id_gender;
END //
DELIMITER ;

-- DELETE BY ID
DELIMITER //
CREATE PROCEDURE SP_DELETE_GENDER_BY_ID(IN p_id_gender INT)
BEGIN
    DELETE FROM Genders WHERE id_gender = p_id_gender;
END //
DELIMITER ;

-- DELETE ALL
DELIMITER //
CREATE PROCEDURE SP_DELETE_ALL_GENDERS()
BEGIN
    DELETE FROM Genders;  
END //
DELIMITER ;


-- ======================================================================
-- 3. TABLA FORMALITY  
-- ======================================================================

-- GET ALL
DELIMITER //
CREATE PROCEDURE SP_GETALL_FORMALITY()
BEGIN
	SELECT * FROM Formality;
END//
DELIMITER ;

-- GET BY ID 
DELIMITER //
CREATE PROCEDURE SP_GETBYID_FORMALITY(IN p_id_formality INT)
BEGIN
	SELECT * FROM Formality WHERE id_formality = p_id_formality;
END //
DELIMITER ;

-- INSERT 
DELIMITER //
CREATE PROCEDURE SP_INSERT_FORMALITY(
    IN p_id_formality INT,
    IN p_formality_label VARCHAR(45)
)
BEGIN
    INSERT INTO Formality(id_formality, formality_label) 
    VALUES (p_id_formality, p_formality_label);
END //
DELIMITER ;

-- UPDATE 
DELIMITER //
CREATE PROCEDURE SP_UPDATE_FORMALITY(
    IN p_id_formality INT,
    IN p_New_formality_label VARCHAR(45)
)
BEGIN
    UPDATE Formality SET formality_label = p_New_formality_label WHERE id_formality = p_id_formality;
END //
DELIMITER ;

-- DELETE BY ID
DELIMITER //
CREATE PROCEDURE SP_DELETE_FORMALITY_BY_ID(IN p_id_formality INT)
BEGIN
    DELETE FROM Formality WHERE id_formality = p_id_formality;
END //
DELIMITER ;

-- DELETE ALL
DELIMITER //
CREATE PROCEDURE SP_DELETE_ALL_FORMALITY()
BEGIN
    DELETE FROM Formality;  
END //
DELIMITER ;


-- Tablas hijas
-- ======================================================================
-- 4. TABLA TOTALPOPULATION depende de Periods
-- ======================================================================

-- GET ALL
DELIMITER //
CREATE PROCEDURE SP_GETALL_TOTALPOPULATION()
BEGIN
	SELECT * FROM TotalPopulation;
END//
DELIMITER ;

-- GET BY ID 
DELIMITER //
CREATE PROCEDURE SP_GETBYID_TOTALPOPULATION(IN p_id_quarter INT)
BEGIN
	SELECT * FROM TotalPopulation WHERE id_quarter = p_id_quarter;
END //
DELIMITER ;

-- INSERT 
DELIMITER //
CREATE PROCEDURE SP_INSERT_TOTALPOPULATION(
    IN p_id_quarter INT,
    IN p_total_population_count BIGINT
)
BEGIN
    INSERT INTO TotalPopulation(id_quarter, total_population_count) 
    VALUES (p_id_quarter, p_total_population_count);
END //
DELIMITER ;

-- UPDATE 
DELIMITER //
CREATE PROCEDURE SP_UPDATE_TOTALPOPULATION(
    IN p_id_quarter INT,
    IN p_New_total_population_count BIGINT
)
BEGIN
    UPDATE TotalPopulation 
    SET total_population_count = p_New_total_population_count 
    WHERE id_quarter = p_id_quarter;
END //
DELIMITER ;

-- DELETE BY ID
DELIMITER //
CREATE PROCEDURE SP_DELETE_TOTALPOPULATION_BY_ID(IN p_id_quarter INT)
BEGIN
    DELETE FROM TotalPopulation WHERE id_quarter = p_id_quarter;
END //
DELIMITER ;

-- DELETE ALL
DELIMITER //
CREATE PROCEDURE SP_DELETE_ALL_TOTALPOPULATION()
BEGIN
    DELETE FROM TotalPopulation;  
END //
DELIMITER ;


-- ======================================================================
-- 5. TABLA UNEMPLOYMENT depende de Periods
-- ======================================================================

-- GET ALL
DELIMITER //
CREATE PROCEDURE SP_GETALL_UNEMPLOYMENT()
BEGIN
	SELECT * FROM Unemployment;
END//
DELIMITER ;

-- GET BY ID 
DELIMITER //
CREATE PROCEDURE SP_GETBYID_UNEMPLOYMENT(IN p_id_quarter INT)
BEGIN
	SELECT * FROM Unemployment WHERE id_quarter = p_id_quarter;
END //
DELIMITER ;

-- INSERT 
DELIMITER //
CREATE PROCEDURE SP_INSERT_UNEMPLOYMENT(
    IN p_id_quarter INT,
    IN p_total_unemployed_count BIGINT
)
BEGIN
    INSERT INTO Unemployment(id_quarter, total_unemployed_count) 
    VALUES (p_id_quarter, p_total_unemployed_count);
END //
DELIMITER ;

-- UPDATE 
DELIMITER //
CREATE PROCEDURE SP_UPDATE_UNEMPLOYMENT(
    IN p_id_quarter INT,
    IN p_New_total_unemployed_count BIGINT
)
BEGIN
    UPDATE Unemployment 
    SET total_unemployed_count = p_New_total_unemployed_count 
    WHERE id_quarter = p_id_quarter;
END //
DELIMITER ;

-- DELETE BY ID
DELIMITER //
CREATE PROCEDURE SP_DELETE_UNEMPLOYMENT_BY_ID(IN p_id_quarter INT)
BEGIN
    DELETE FROM Unemployment WHERE id_quarter = p_id_quarter;
END //
DELIMITER ;

-- DELETE ALL
DELIMITER //
CREATE PROCEDURE SP_DELETE_ALL_UNEMPLOYMENT()
BEGIN
    DELETE FROM Unemployment;  
END //
DELIMITER ;


-- ======================================================================
-- 6. TABLA LABORACTIVITY depente de Periods y Genders
-- ======================================================================

-- GET ALL
DELIMITER //
CREATE PROCEDURE SP_GETALL_LABORACTIVITY()
BEGIN
	SELECT * FROM LaborActivity;
END//
DELIMITER ;

-- GET BY ID  
DELIMITER //
CREATE PROCEDURE SP_GETBYID_LABORACTIVITY(
    IN p_id_quarter INT,
    IN p_id_gender INT
)
BEGIN
	SELECT * FROM LaborActivity 
    WHERE id_quarter = p_id_quarter AND id_gender = p_id_gender;
END //
DELIMITER ;

-- INSERT 
DELIMITER //
CREATE PROCEDURE SP_INSERT_LABORACTIVITY(
    IN p_id_quarter INT,
    IN p_id_gender INT,
    IN p_pea_count BIGINT,
    IN p_unemployed_count BIGINT
)
BEGIN
    INSERT INTO LaborActivity(id_quarter, id_gender, pea_count, unemployed_count) 
    VALUES (p_id_quarter, p_id_gender, p_pea_count, p_unemployed_count);
END //
DELIMITER ;

-- UPDATE 
DELIMITER //
CREATE PROCEDURE SP_UPDATE_LABORACTIVITY(
    IN p_id_quarter INT,
    IN p_id_gender INT,
    IN p_New_pea_count BIGINT,
    IN p_New_unemployed_count BIGINT
)
BEGIN
    UPDATE LaborActivity 
    SET pea_count = p_New_pea_count, 
        unemployed_count = p_New_unemployed_count 
    WHERE id_quarter = p_id_quarter AND id_gender = p_id_gender;
END //
DELIMITER ;

-- DELETE BY ID
DELIMITER //
CREATE PROCEDURE SP_DELETE_LABORACTIVITY_BY_ID(
    IN p_id_quarter INT,
    IN p_id_gender INT
)
BEGIN
    DELETE FROM LaborActivity 
    WHERE id_quarter = p_id_quarter AND id_gender = p_id_gender;
END //
DELIMITER ;

-- DELETE ALL
DELIMITER //
CREATE PROCEDURE SP_DELETE_ALL_LABORACTIVITY()
BEGIN
    DELETE FROM LaborActivity;  
END //
DELIMITER ;


-- ======================================================================
-- 7. TABLA SALARYMETRICS depende de Periods, Genders y Formality
-- ======================================================================

-- GET ALL
DELIMITER //
CREATE PROCEDURE SP_GETALL_SALARYMETRICS()
BEGIN
	SELECT * FROM SalaryMetrics;
END//
DELIMITER ;

-- GET BY ID
DELIMITER //
CREATE PROCEDURE SP_GETBYID_SALARYMETRICS(
    IN p_id_quarter INT,
    IN p_id_gender INT,
    IN p_id_formality INT
)
BEGIN
	SELECT * FROM SalaryMetrics 
    WHERE id_quarter = p_id_quarter 
      AND id_gender = p_id_gender 
      AND id_formality = p_id_formality;
END //
DELIMITER ;

-- INSERT 
DELIMITER //
CREATE PROCEDURE SP_INSERT_SALARYMETRICS(
    IN p_id_quarter INT,
    IN p_id_gender INT,
    IN p_id_formality INT,
    IN p_total_count BIGINT,
    IN p_average_monthly_wage DECIMAL(12, 2)
)
BEGIN
    INSERT INTO SalaryMetrics(id_quarter, id_gender, id_formality, total_count, average_monthly_wage) 
    VALUES (p_id_quarter, p_id_gender, p_id_formality, p_total_count, p_average_monthly_wage);
END //
DELIMITER ;

-- UPDATE 
DELIMITER //
CREATE PROCEDURE SP_UPDATE_SALARYMETRICS(
    IN p_id_quarter INT,
    IN p_id_gender INT,
    IN p_id_formality INT,
    IN p_New_total_count BIGINT,
    IN p_New_average_monthly_wage DECIMAL(12, 2)
)
BEGIN
    UPDATE SalaryMetrics 
    SET total_count = p_New_total_count, 
        average_monthly_wage = p_New_average_monthly_wage
    WHERE id_quarter = p_id_quarter 
      AND id_gender = p_id_gender 
      AND id_formality = p_id_formality;
END //
DELIMITER ;

-- DELETE BY ID
DELIMITER //
CREATE PROCEDURE SP_DELETE_SALARYMETRICS_BY_ID(
    IN p_id_quarter INT,
    IN p_id_gender INT,
    IN p_id_formality INT
)
BEGIN
    DELETE FROM SalaryMetrics 
    WHERE id_quarter = p_id_quarter 
      AND id_gender = p_id_gender 
      AND id_formality = p_id_formality;
END //
DELIMITER ;

-- DELETE ALL
DELIMITER //
CREATE PROCEDURE SP_DELETE_ALL_SALARYMETRICS()
BEGIN
    DELETE FROM SalaryMetrics;  
END //
DELIMITER ;


-- ======================================================================
-- Pruebas en orden por las restricciones de las llaves
-- ======================================================================

-- ----------------------------------------------------------------------
-- 1. TABLA PERIODS 
-- ----------------------------------------------------------------------
-- INSERT
CALL SP_INSERT_PERIOD(9999, 'TEST-Q', 2099, 4);

-- GET ALL  
CALL SP_GETALL_PERIODS();

-- GET BY ID
CALL SP_GETBYID_PERIOD(9999);

-- UPDATE
CALL SP_UPDATE_PERIOD(9999, 'MODIFIED', 2099, 4);

-- DELETE BY ID no se llama todavia porque lo necesitamos para probar las tablas hijas abajo

-- DELETE ALL 
CALL SP_DELETE_ALL_PERIODS();


-- ----------------------------------------------------------------------
-- 2. TABLA GENDERS 
-- ----------------------------------------------------------------------
-- INSERT
CALL SP_INSERT_GENDER(8888, 'Genero Test');

-- GET ALL
CALL SP_GETALL_GENDERS();

-- GET BY ID
CALL SP_GETBYID_GENDER(8888);

-- UPDATE
CALL SP_UPDATE_GENDER(8888, 'Genero Modif');

-- DELETE BY ID no se llama todavia porque lo necesitamos para probar las tablas hijas abajo

-- DELETE ALL 
CALL SP_DELETE_ALL_GENDERS();


-- ----------------------------------------------------------------------
-- 3. TABLA FORMALITY  
-- ----------------------------------------------------------------------
-- INSERT
CALL SP_INSERT_FORMALITY(7777, 'Formalidad Test');

-- GET ALL
CALL SP_GETALL_FORMALITY();

-- GET BY ID
CALL SP_GETBYID_FORMALITY(7777);

-- UPDATE
CALL SP_UPDATE_FORMALITY(7777, 'Formalidad Modif');

-- DELETE BY ID no se llama todavia porque lo necesitamos para probar las tablas hijas abajo

-- DELETE ALL  
CALL SP_DELETE_ALL_FORMALITY();


-- ----------------------------------------------------------------------
-- 4. TABLA UNEMPLOYMENT  
-- ----------------------------------------------------------------------
-- INSERT esta se apoya del insert de la tabla PERIODS
CALL SP_INSERT_UNEMPLOYMENT(9999, 50);

-- GET ALL
CALL SP_GETALL_UNEMPLOYMENT();

-- GET BY ID
CALL SP_GETBYID_UNEMPLOYMENT(9999);

-- UPDATE
CALL SP_UPDATE_UNEMPLOYMENT(9999, 100);

-- DELETE BY ID  
CALL SP_DELETE_UNEMPLOYMENT_BY_ID(9999);

-- DELETE ALL
CALL SP_DELETE_ALL_UNEMPLOYMENT();


-- ----------------------------------------------------------------------
-- 5. TABLA TOTALPOPULATION depende de PERIODS
-- ----------------------------------------------------------------------
-- INSERT
CALL SP_INSERT_TOTALPOPULATION(9999, 1000);

-- GET ALL
CALL SP_GETALL_TOTALPOPULATION();

-- GET BY ID
CALL SP_GETBYID_TOTALPOPULATION(9999);

-- UPDATE
CALL SP_UPDATE_TOTALPOPULATION(9999, 2000);

-- DELETE BY ID 
CALL SP_DELETE_TOTALPOPULATION_BY_ID(9999);

-- DELETE ALL 
CALL SP_DELETE_ALL_TOTALPOPULATION();


-- ----------------------------------------------------------------------
-- 6. TABLA LABORACTIVITY depende de PERIODS y GENDERS
-- ----------------------------------------------------------------------
-- INSERT
CALL SP_INSERT_LABORACTIVITY(9999, 8888, 500, 50);

-- GET ALL
CALL SP_GETALL_LABORACTIVITY();

-- GET BY ID (Doble llave)
CALL SP_GETBYID_LABORACTIVITY(9999, 8888);

-- UPDATE
CALL SP_UPDATE_LABORACTIVITY(9999, 8888, 600, 60);

-- DELETE BY ID 
CALL SP_DELETE_LABORACTIVITY_BY_ID(9999, 8888);

-- DELETE ALL 
CALL SP_DELETE_ALL_LABORACTIVITY();


-- ----------------------------------------------------------------------
-- 7. TABLA SALARYMETRICS depende de PERIODS, GENDERS y FORMALITY
-- ----------------------------------------------------------------------
-- INSERT
CALL SP_INSERT_SALARYMETRICS(9999, 8888, 7777, 200, 15000.50);

-- GET ALL
CALL SP_GETALL_SALARYMETRICS();

-- GET BY ID (Triple llave)
CALL SP_GETBYID_SALARYMETRICS(9999, 8888, 7777);

-- UPDATE
CALL SP_UPDATE_SALARYMETRICS(9999, 8888, 7777, 300, 25000.00);

-- DELETE BY ID 
CALL SP_DELETE_SALARYMETRICS_BY_ID(9999, 8888, 7777);

-- DELETE ALL  
CALL SP_DELETE_ALL_SALARYMETRICS();


-- ----------------------------------------------------------------------
-- Llamada a los Delete de los padres 
-- ----------------------------------------------------------------------
CALL SP_DELETE_PERIOD_BY_ID(9999);
CALL SP_DELETE_GENDER_BY_ID(8888);
CALL SP_DELETE_FORMALITY_BY_ID(7777);



