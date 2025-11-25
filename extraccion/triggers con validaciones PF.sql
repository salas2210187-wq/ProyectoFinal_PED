USE Project_Final_Unemployment;

-- ==========================================================
-- 0. TABLA DE AUDITORÍA
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
-- ============   🐅    TRIGGERS    🐅    ===========
-- ==================================================

DELIMITER //

-- ==========================================================
-- 1. TABLA PERIODS (PADRE)
-- ==========================================================

CREATE TRIGGER LOG_INSERT_PERIODS 
AFTER INSERT ON Periods 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Periods', USER(), 'INSERT', NOW(), 'Inserto en la tabla Periods');
END//


CREATE TRIGGER LOG_UPDATE_PERIODS 
AFTER UPDATE ON Periods 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Periods', USER(), 'UPDATE', NOW(), 'Modifico la tabla Periods');
END//


CREATE TRIGGER V_LOG_DELETE_PERIODS
BEFORE DELETE ON Periods 
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM TotalPopulation WHERE id_quarter = OLD.id_quarter) OR
       EXISTS (SELECT 1 FROM Unemployment WHERE id_quarter = OLD.id_quarter) OR 
       EXISTS (SELECT 1 FROM LaborActivity WHERE id_quarter = OLD.id_quarter) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: No puedes borrar este Periodo. Primero elimina los registros en Población/Desempleo relacionados.';
    END IF;

    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Periods', USER(), 'DELETE', NOW(), CONCAT('Eliminó el Periodo ID: ', OLD.id_quarter));
END//

-- ==========================================================
-- 2. TABLA GENDERS (PADRE)
-- ==========================================================

CREATE TRIGGER LOG_INSERT_GENDERS 
AFTER INSERT ON Genders 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Genders', USER(), 'INSERT', NOW(), 'Inserto en la tabla Genders');
END//

CREATE TRIGGER LOG_UPDATE_GENDERS
AFTER UPDATE ON Genders 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Genders', USER(), 'UPDATE', NOW(), 'Modifico la tabla Genders');
END//


CREATE TRIGGER V_LOG_DELETE_GENDERS
BEFORE DELETE ON Genders 
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM LaborActivity WHERE id_gender = OLD.id_gender) OR
       EXISTS (SELECT 1 FROM SalaryMetrics WHERE id_gender = OLD.id_gender) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: No puedes borrar este Genero. Una de dos: Está siendo usado en Actividad Laboral o Salarios.';
    END IF;

    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Genders', USER(), 'DELETE', NOW(), CONCAT('Eliminó el Genero ID: ', OLD.id_gender));
END//

-- ==========================================================
-- 3. TABLA FORMALITY (PADRE)
-- ==========================================================

CREATE TRIGGER LOG_INSERT_FORMALITY 
AFTER INSERT ON Formality 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Formality', USER(), 'INSERT', NOW(), 'Inserto en la tabla Formality');
END//

CREATE TRIGGER LOG_UPDATE_FORMALITY 
AFTER UPDATE ON Formality 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Formality', USER(), 'UPDATE', NOW(), 'Modifico la tabla Formality');
END//


CREATE TRIGGER V_LOG_DELETE_FORMALITY
BEFORE DELETE ON Formality 
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM SalaryMetrics WHERE id_formality = OLD.id_formality) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: No puedes borrar esta Formalidad. Hay registros de Salarios que dependen de ella.';
    END IF;

    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Formality', USER(), 'DELETE', NOW(), CONCAT('Eliminó la Formalidad ID: ', OLD.id_formality));
END//

-- ==========================================================
-- 4. TABLA TOTALPOPULATION (HIJA)
-- ==========================================================

CREATE TRIGGER V_LOG_INSERT_TOTALPOPULATION 
BEFORE INSERT ON TotalPopulation 
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Periods WHERE id_quarter = NEW.id_quarter) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: No existe el Periodo indicado. BRO, inserta primero en la tabla Periods.';
    END IF;
END//


CREATE TRIGGER V_LOG_UPDATE_TOTALPOPULATION 
BEFORE UPDATE ON TotalPopulation 
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Periods WHERE id_quarter = NEW.id_quarter) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR PERSONALIZADO: Actualización fallida. El Periodo indicado no existe.';
    END IF;
END//


CREATE TRIGGER LOG_INSERT_TOTALPOPULATION 
AFTER INSERT ON TotalPopulation 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('TotalPopulation', USER(), 'INSERT', NOW(), 'Inserto en la tabla TotalPopulation');
END//

CREATE TRIGGER LOG_UPDATE_TOTALPOPULATION 
AFTER UPDATE ON TotalPopulation 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('TotalPopulation', USER(), 'UPDATE', NOW(), 'Modifico la tabla TotalPopulation');
END//

CREATE TRIGGER LOG_DELETE_TOTALPOPULATION 
BEFORE DELETE ON TotalPopulation 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('TotalPopulation', USER(), 'DELETE', NOW(), CONCAT('Eliminó en la tabla TotalPopulation, ID: ', OLD.id_quarter));
END//

-- ==========================================================
-- 5. TABLA LABORACTIVITY (HIJA)
-- ==========================================================


CREATE TRIGGER V_LOG_INSERT_LABORACTIVITY 
BEFORE INSERT ON LaborActivity 
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Periods WHERE id_quarter = NEW.id_quarter) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Falta el Periodo (id_quarter).';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Genders WHERE id_gender = NEW.id_gender) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Falta el Genero (id_gender).';
    END IF;
END//


CREATE TRIGGER V_LOG_UPDATE_LABORACTIVITY 
BEFORE UPDATE ON LaborActivity 
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Periods WHERE id_quarter = NEW.id_quarter) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR PERSONALIZADO: Actualización fallida. El Periodo no existe.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Genders WHERE id_gender = NEW.id_gender) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR PERSONALIZADO: Actualización fallida. El Genero no existe.';
    END IF;
END//


CREATE TRIGGER LOG_INSERT_LABORACTIVITY 
AFTER INSERT ON LaborActivity 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('LaborActivity', USER(), 'INSERT', NOW(), 'Inserto en la tabla LaborActivity');
END//

CREATE TRIGGER LOG_UPDATE_LABORACTIVITY 
AFTER UPDATE ON LaborActivity 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('LaborActivity', USER(), 'UPDATE', NOW(), 'Modifico la tabla LaborActivity');
END//

CREATE TRIGGER LOG_DELETE_LABORACTIVITY 
BEFORE DELETE ON LaborActivity 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('LaborActivity', USER(), 'DELETE', NOW(), CONCAT('Eliminó en LaborActivity, ID: ', OLD.id_quarter));
END//

-- ==========================================================
-- 6. TABLA SALARYMETRICS (HIJA)
-- ==========================================================


CREATE TRIGGER V_LOG_INSERT_SALARYMETRICS 
BEFORE INSERT ON SalaryMetrics 
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Periods WHERE id_quarter = NEW.id_quarter) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Falta el Periodo.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Genders WHERE id_gender = NEW.id_gender) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Falta el Genero.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Formality WHERE id_formality = NEW.id_formality) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Falta la Formalidad.';
    END IF;
END//


CREATE TRIGGER V_LOG_UPDATE_SALARYMETRICS 
BEFORE UPDATE ON SalaryMetrics 
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Periods WHERE id_quarter = NEW.id_quarter) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Error Update. Falta Periodo.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Genders WHERE id_gender = NEW.id_gender) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Error Update. Falta Genero.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Formality WHERE id_formality = NEW.id_formality) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Error Update. Falta Formalidad.';
    END IF;
END//


CREATE TRIGGER LOG_INSERT_SALARYMETRICS 
AFTER INSERT ON SalaryMetrics 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('SalaryMetrics', USER(), 'INSERT', NOW(), 'Inserto en la tabla SalaryMetrics');
END//

CREATE TRIGGER LOG_UPDATE_SALARYMETRICS 
AFTER UPDATE ON SalaryMetrics 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('SalaryMetrics', USER(), 'UPDATE', NOW(), 'Modifico la tabla SalaryMetrics');
END//

CREATE TRIGGER LOG_DELETE_SALARYMETRICS 
BEFORE DELETE ON SalaryMetrics 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('SalaryMetrics', USER(), 'DELETE', NOW(), CONCAT('Eliminó en SalaryMetrics'));
END//

-- ==========================================================
-- 7. TABLA UNEMPLOYMENT (HIJA)
-- ==========================================================

-- VALIDAR INSERT
CREATE TRIGGER V_LOG_INSERT_UNEMPLOYMENT 
BEFORE INSERT ON Unemployment 
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Periods WHERE id_quarter = NEW.id_quarter) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: El Periodo no existe en la tabla Periods.';
    END IF;
END//


CREATE TRIGGER V_LOG_UPDATE_UNEMPLOYMENT 
BEFORE UPDATE ON Unemployment 
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Periods WHERE id_quarter = NEW.id_quarter) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Update fallido. El Periodo no existe.';
    END IF;
END//


CREATE TRIGGER LOG_INSERT_UNEMPLOYMENT 
AFTER INSERT ON Unemployment 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Unemployment', USER(), 'INSERT', NOW(), 'Inserto en la tabla Unemployment');
END//

CREATE TRIGGER LOG_UPDATE_UNEMPLOYMENT 
AFTER UPDATE ON Unemployment 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Unemployment', USER(), 'UPDATE', NOW(), 'Modifico la tabla Unemployment');
END//

CREATE TRIGGER LOG_DELETE_UNEMPLOYMENT 
BEFORE DELETE ON Unemployment 
FOR EACH ROW
BEGIN
    INSERT INTO LOG_AUDITORIA (TABLENAME, USERNAME, OPERATION, DATE_OPERATION, DETAIL)
    VALUES ('Unemployment', USER(), 'DELETE', NOW(), CONCAT('Eliminó en la tabla Unemployment'));
END//

DELIMITER ;


-- =============================================================================================
-- PRUEBAS
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
-- TABLAS HIJAS (AQUI ES DONDE SALTAN LOS ERRORES SI EL PROFE SE SALTA PASOS)
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


-- =============================================================================================
-- PRUEBA DE DELETE 
-- =============================================================================================

-- Borrado Correcto (De abajo hacia arriba):
DELETE FROM TotalPopulation WHERE id_quarter = 9999;
DELETE FROM Unemployment WHERE id_quarter = 9999;
DELETE FROM LaborActivity WHERE id_quarter = 9999 AND id_gender = 8888;
DELETE FROM SalaryMetrics WHERE id_quarter = 9999 AND id_gender = 8888 AND id_formality = 7777;

-- Ahora sí deja borrar a los padres:
DELETE FROM Periods WHERE id_quarter = 9999;
DELETE FROM Genders WHERE id_gender = 8888;
DELETE FROM Formality WHERE id_formality = 7777;

-- REVISAR LA AUDITORÍA
SELECT * FROM LOG_AUDITORIA ORDER BY ID_LOG DESC;