USE Project_Final_Unemployment;

-- ======================================================================
-- 1. TABLA PERIODS (PADRE)
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
    IF EXISTS (SELECT 1 FROM TotalPopulation WHERE id_quarter = p_id_quarter) OR
       EXISTS (SELECT 1 FROM Unemployment WHERE id_quarter = p_id_quarter) OR 
       EXISTS (SELECT 1 FROM LaborActivity WHERE id_quarter = p_id_quarter) OR
       EXISTS (SELECT 1 FROM SalaryMetrics WHERE id_quarter = p_id_quarter) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: No puedes borrar este Periodo porque hay registros en Población/Desempleo relacionados a ella.';
    END IF;

    DELETE FROM Periods WHERE id_quarter = p_id_quarter;
END //
DELIMITER ;

-- DELETE ALL 
DELIMITER //
CREATE PROCEDURE SP_DELETE_ALL_PERIODS()
BEGIN
    IF EXISTS (SELECT 1 FROM TotalPopulation) OR EXISTS (SELECT 1 FROM Unemployment) THEN   
         SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: No puedes borrar Periods, alguna de sus tablas hijas tiene datos o chance las dos.';
    END IF;
    DELETE FROM Periods;  
END //
DELIMITER ;


-- ======================================================================
-- 2. TABLA GENDERS (PADRE)
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
    IF EXISTS (SELECT 1 FROM LaborActivity WHERE id_gender = p_id_gender) OR
       EXISTS (SELECT 1 FROM SalaryMetrics WHERE id_gender = p_id_gender) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: No puedes borrar este Género porque usa en LaborActivity o SalaryMetrics.';
    END IF;

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
-- 3. TABLA FORMALITY (PADRE)
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
    IF EXISTS (SELECT 1 FROM SalaryMetrics WHERE id_formality = p_id_formality) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: No puedes borrar esta Formalidad porque se usa en SalaryMetrics.';
    END IF;

    DELETE FROM Formality WHERE id_formality = p_id_formality;
END //
DELIMITER ;



-- DELETE ALL
DELIMITER //
CREATE PROCEDURE SP_DELETE_ALL_FORMALITY()
BEGIN
    IF EXISTS (SELECT 1 FROM SalaryMetrics) THEN
         SIGNAL SQLSTATE '45000' 
         SET MESSAGE_TEXT = 'ERROR: No puedes vaciar la tabla Formality porque SalaryMetrics aun tiene datos.';
    END IF;
    
    -- Si no hay hijos, procede a borrar
    DELETE FROM Formality;  
END //
DELIMITER ;


-- ======================================================================
-- 4. TABLA TOTALPOPULATION 
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
    IF NOT EXISTS (SELECT 1 FROM Periods WHERE id_quarter = p_id_quarter) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: El Periodo indicado no existe.';
    END IF;

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
-- 5. TABLA UNEMPLOYMENT
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
    IF NOT EXISTS (SELECT 1 FROM Periods WHERE id_quarter = p_id_quarter) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: El Periodo indicado no existe.';
    END IF;

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
-- 6. TABLA LABORACTIVITY
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
    IF NOT EXISTS (SELECT 1 FROM Periods WHERE id_quarter = p_id_quarter) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Periodo inexistente.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Genders WHERE id_gender = p_id_gender) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Genero inexistente.';
    END IF;

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
-- 7. TABLA SALARYMETRICS
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
    IF NOT EXISTS (SELECT 1 FROM Periods WHERE id_quarter = p_id_quarter) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Falta Periodo.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Genders WHERE id_gender = p_id_gender) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Falta Genero.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Formality WHERE id_formality = p_id_formality) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Falta Formalidad.';
    END IF;

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
-- Pruebas 
-- ======================================================================
SET SQL_SAFE_UPDATES = 0;
-- ----------------------------------------------------------------------
-- 1. TABLA PERIODS 
-- ----------------------------------------------------------------------
CALL SP_INSERT_PERIOD(9999, 'TEST-Q', 2099, 4);
CALL SP_GETALL_PERIODS();
CALL SP_GETBYID_PERIOD(9999);
CALL SP_UPDATE_PERIOD(9999, 'MODIFIED', 2099, 4);
CALL SP_DELETE_PERIOD_BY_ID(9999);
CALL SP_DELETE_ALL_PERIODS();

-- ----------------------------------------------------------------------
-- 2. TABLA GENDERS 
-- ----------------------------------------------------------------------
CALL SP_INSERT_GENDER(8888, 'Genero Test');
CALL SP_GETALL_GENDERS();
CALL SP_GETBYID_GENDER(8888);
CALL SP_UPDATE_GENDER(8888, 'Genero Modif');
CALL SP_DELETE_GENDER_BY_ID(8888);
CALL SP_DELETE_ALL_GENDERS();

-- ----------------------------------------------------------------------
-- 3. TABLA FORMALITY  
-- ----------------------------------------------------------------------
CALL SP_INSERT_FORMALITY(7777, 'Formalidad Test');
CALL SP_GETALL_FORMALITY();
CALL SP_GETBYID_FORMALITY(7777);
CALL SP_UPDATE_FORMALITY(7777, 'Formalidad Modif');
CALL SP_DELETE_FORMALITY_BY_ID(7777);
CALL SP_DELETE_ALL_FORMALITY();

-- ----------------------------------------------------------------------
-- 4. TABLA UNEMPLOYMENT  
-- ----------------------------------------------------------------------
CALL SP_INSERT_UNEMPLOYMENT(9999, 50);
CALL SP_GETALL_UNEMPLOYMENT();
CALL SP_GETBYID_UNEMPLOYMENT(9999);
CALL SP_UPDATE_UNEMPLOYMENT(9999, 100);
CALL SP_DELETE_UNEMPLOYMENT_BY_ID(9999);
CALL SP_DELETE_ALL_UNEMPLOYMENT();

-- ----------------------------------------------------------------------
-- 5. TABLA TOTALPOPULATION
-- ----------------------------------------------------------------------
CALL SP_INSERT_TOTALPOPULATION(9999, 1000);
CALL SP_GETALL_TOTALPOPULATION();
CALL SP_GETBYID_TOTALPOPULATION(9999);
CALL SP_UPDATE_TOTALPOPULATION(9999, 2000);
CALL SP_DELETE_TOTALPOPULATION_BY_ID(9999);
CALL SP_DELETE_ALL_TOTALPOPULATION();


-- ----------------------------------------------------------------------
-- 6. TABLA LABORACTIVITY
-- ----------------------------------------------------------------------
CALL SP_INSERT_LABORACTIVITY(9999, 8888, 500, 50);
CALL SP_GETALL_LABORACTIVITY();
CALL SP_GETBYID_LABORACTIVITY(9999, 8888);
CALL SP_UPDATE_LABORACTIVITY(9999, 8888, 600, 60);
CALL SP_DELETE_LABORACTIVITY_BY_ID(9999, 8888);
CALL SP_DELETE_ALL_LABORACTIVITY();


-- ----------------------------------------------------------------------
-- 7. TABLA SALARYMETRICS
-- ----------------------------------------------------------------------
CALL SP_INSERT_SALARYMETRICS(9999, 8888, 7777, 200, 15000.50);
CALL SP_GETALL_SALARYMETRICS();
CALL SP_GETBYID_SALARYMETRICS(9999, 8888, 7777);
CALL SP_UPDATE_SALARYMETRICS(9999, 8888, 7777, 300, 25000.00);
CALL SP_DELETE_SALARYMETRICS_BY_ID(9999, 8888, 7777);
CALL SP_DELETE_ALL_SALARYMETRICS();


SET SQL_SAFE_UPDATES = 1;

