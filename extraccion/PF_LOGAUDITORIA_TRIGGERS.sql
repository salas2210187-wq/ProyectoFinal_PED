USE Project_Final_Unemployment;

-- ==========================================================
-- TABLA DE AUDITORÍA 
-- ==========================================================
CREATE TABLE IF NOT EXISTS LOG_AUDITORIA (
    ID_LOG INT AUTO_INCREMENT PRIMARY KEY,
    TABLENAME VARCHAR(50),
    USERNAME VARCHAR(50),
    OPERATION VARCHAR(20),
    DATE_OPERATION DATETIME,
    DETAIL TEXT
);





-- ==================================================
-- ============  🐅    TRIGGERS    🐅    ============
-- ==================================================


DELIMITER //
-- ==========================================================
-- 1. TABLA PERIODS
-- ==========================================================
CREATE TRIGGER LOG_INSERT_PERIODS
AFTER INSERT ON Periods FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Periods', USER(), 'INSERT', NOW(), 'Inserto en la tabla Periods');
END//

CREATE TRIGGER LOG_UPDATE_PERIODS
AFTER UPDATE ON Periods FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Periods', USER(), 'UPDATE', NOW(), 'Modifico la tabla Periods');
END//

CREATE TRIGGER LOG_DELETE_PERIODS
BEFORE DELETE ON Periods FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Periods', USER(), 'DELETE', NOW(), CONCAT('Eliminó el Periodo ID: ', OLD.id_quarter));
END//

-- ==========================================================
-- 2. TABLA GENDERS
-- ==========================================================
CREATE TRIGGER LOG_INSERT_GENDERS
AFTER INSERT ON Genders FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Genders', USER(), 'INSERT', NOW(), 'Inserto en la tabla Genders');
END//

CREATE TRIGGER LOG_UPDATE_GENDERS
AFTER UPDATE ON Genders FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Genders', USER(), 'UPDATE', NOW(), 'Modifico la tabla Genders');
END//

CREATE TRIGGER LOG_DELETE_GENDERS
BEFORE DELETE ON Genders FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Genders', USER(), 'DELETE', NOW(), CONCAT('Eliminó el Genero ID: ', OLD.id_gender));
END//

-- ==========================================================
-- 3. TABLA FORMALITY
-- ==========================================================
CREATE TRIGGER LOG_INSERT_FORMALITY
AFTER INSERT ON Formality FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Formality', USER(), 'INSERT', NOW(), 'Inserto en la tabla Formality');
END//

CREATE TRIGGER LOG_UPDATE_FORMALITY
AFTER UPDATE ON Formality FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Formality', USER(), 'UPDATE', NOW(), 'Modifico la tabla Formality');
END//

CREATE TRIGGER LOG_DELETE_FORMALITY
BEFORE DELETE ON Formality FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Formality', USER(), 'DELETE', NOW(), CONCAT('Eliminó la Formalidad ID: ', OLD.id_formality));
END//

-- ==========================================================
-- 4. TABLA TOTALPOPULATION
-- ==========================================================
CREATE TRIGGER LOG_INSERT_TOTALPOPULATION
AFTER INSERT ON TotalPopulation FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('TotalPopulation', USER(), 'INSERT', NOW(), 'Inserto en la tabla TotalPopulation');
END//

CREATE TRIGGER LOG_UPDATE_TOTALPOPULATION
AFTER UPDATE ON TotalPopulation FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('TotalPopulation', USER(), 'UPDATE', NOW(), 'Modifico la tabla TotalPopulation');
END//

CREATE TRIGGER LOG_DELETE_TOTALPOPULATION
BEFORE DELETE ON TotalPopulation FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('TotalPopulation', USER(), 'DELETE', NOW(), CONCAT('Eliminó en la tabla TotalPopulation, ID: ', OLD.id_quarter));
END//

-- ==========================================================
-- 5. TABLA LABORACTIVITY
-- ==========================================================
CREATE TRIGGER LOG_INSERT_LABORACTIVITY
AFTER INSERT ON LaborActivity FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('LaborActivity', USER(), 'INSERT', NOW(), 'Inserto en la tabla LaborActivity');
END//

CREATE TRIGGER LOG_UPDATE_LABORACTIVITY
AFTER UPDATE ON LaborActivity FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('LaborActivity', USER(), 'UPDATE', NOW(), 'Modifico la tabla LaborActivity');
END//

CREATE TRIGGER LOG_DELETE_LABORACTIVITY
BEFORE DELETE ON LaborActivity FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('LaborActivity', USER(), 'DELETE', NOW(), CONCAT('Eliminó en la tabla LaborActivity, ID: ', OLD.id_quarter, ' Gender: ', OLD.id_gender));
END//

-- ==========================================================
-- 6. TABLA SALARYMETRICS
-- ==========================================================
CREATE TRIGGER LOG_INSERT_SALARYMETRICS
AFTER INSERT ON SalaryMetrics FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('SalaryMetrics', USER(), 'INSERT', NOW(), 'Inserto en la tabla SalaryMetrics');
END//

CREATE TRIGGER LOG_UPDATE_SALARYMETRICS
AFTER UPDATE ON SalaryMetrics FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('SalaryMetrics', USER(), 'UPDATE', NOW(), 'Modifico la tabla SalaryMetrics');
END//

CREATE TRIGGER LOG_DELETE_SALARYMETRICS
BEFORE DELETE ON SalaryMetrics FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('SalaryMetrics', USER(), 'DELETE', NOW(), CONCAT('Eliminó en la tabla SalaryMetrics, ID: ', OLD.id_quarter, ' G: ', OLD.id_gender, ' F: ', OLD.id_formality));
END//

-- ==========================================================
-- 7. TABLA UNEMPLOYMENT
-- ==========================================================
CREATE TRIGGER LOG_INSERT_UNEMPLOYMENT
AFTER INSERT ON Unemployment FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Unemployment', USER(), 'INSERT', NOW(), 'Inserto en la tabla Unemployment');
END//

CREATE TRIGGER LOG_UPDATE_UNEMPLOYMENT
AFTER UPDATE ON Unemployment FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Unemployment', USER(), 'UPDATE', NOW(), 'Modifico la tabla Unemployment');
END//

CREATE TRIGGER LOG_DELETE_UNEMPLOYMENT
BEFORE DELETE ON Unemployment FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Unemployment', USER(), 'DELETE', NOW(), CONCAT('Eliminó en la tabla Unemployment, ID: ', OLD.id_quarter));
END//

DELIMITER ;



-- Datos falsos solo para pruebas
-- =============================================================================================
-- TABLAS PADRE 
-- =============================================================================================

-- 1. PERIODS =============================================================================================
SELECT * FROM Periods;

INSERT INTO Periods (id_quarter, quarter_label, year_num, quarter_num) VALUES (9999, 'TEST-Q1', 2099, 1);

UPDATE Periods SET quarter_label = 'TEST-MOD' WHERE id_quarter = 9999;



-- 2. GENDERS =============================================================================================
SELECT * FROM Genders;

INSERT INTO Genders (id_gender, gender_label) VALUES (8888, 'Genero Prueba');

UPDATE Genders SET gender_label = 'Genero Editado' WHERE id_gender = 8888;


-- 3. FORMALITY =============================================================================================
SELECT * FROM Formality;

INSERT INTO Formality (id_formality, formality_label) VALUES (7777, 'Formalidad Prueba');

UPDATE Formality SET formality_label = 'Formalidad Editada' WHERE id_formality = 7777;


-- =============================================================================================
-- TABLAS HIJAS
-- =============================================================================================

-- 4. TOTALPOPULATION =============================================================================================
SELECT * FROM TotalPopulation;

INSERT INTO TotalPopulation (id_quarter, total_population_count) VALUES (9999, 1000000);

UPDATE TotalPopulation SET total_population_count = 2000000 WHERE id_quarter = 9999;


-- 5. UNEMPLOYMENT =============================================================================================
SELECT * FROM Unemployment;

INSERT INTO Unemployment (id_quarter, total_unemployed_count) VALUES (9999, 5000);

UPDATE Unemployment SET total_unemployed_count = 10000 WHERE id_quarter = 9999;


-- 6. LABORACTIVITY =============================================================================================
SELECT * FROM LaborActivity;

INSERT INTO LaborActivity (id_quarter, id_gender, pea_count, unemployed_count) VALUES (9999, 8888, 50000, 2000);

UPDATE LaborActivity SET pea_count = 60000 WHERE id_quarter = 9999 AND id_gender = 8888;


-- 7. SALARYMETRICS =============================================================================================
SELECT * FROM SalaryMetrics;

INSERT INTO SalaryMetrics (id_quarter, id_gender, id_formality, total_count, average_monthly_wage) VALUES (9999, 8888, 7777, 100, 15000.50);

UPDATE SalaryMetrics SET average_monthly_wage = 25000.00 WHERE id_quarter = 9999 AND id_gender = 8888 AND id_formality = 7777;


-- PRUEBA DE DELETE por orden de restricciones
DELETE FROM TotalPopulation WHERE id_quarter = 9999;
DELETE FROM Unemployment WHERE id_quarter = 9999;
DELETE FROM LaborActivity WHERE id_quarter = 9999 AND id_gender = 8888;
DELETE FROM SalaryMetrics WHERE id_quarter = 9999 AND id_gender = 8888 AND id_formality = 7777;

DELETE FROM Periods WHERE id_quarter = 9999;
DELETE FROM Genders WHERE id_gender = 8888;
DELETE FROM Formality WHERE id_formality = 7777;





SELECT * FROM LOG_AUDITORIA ORDER BY ID_LOG DESC;