-- Base de datos Proyecto Final 
-- Creación de base de datos 
DROP DATABASE IF EXISTS Project_Final_Unemployment; 
CREATE DATABASE Project_Final_Unemployment;
USE Project_Final_Unemployment;

-- Creación de tablas 
-- Tabla Periodos
CREATE TABLE  Periods(
	id_quarter INT PRIMARY KEY,
    quarter_label VARCHAR(10) NOT NULL,
    year_num INT NOT NULL,
    quarter_num INT NOT NULL
);

-- Tabla Generos
CREATE TABLE Genders(
	id_gender INT PRIMARY KEY,
    gender_label VARCHAR(20) NOT NULL
);

-- Tabla Formalidad
CREATE TABLE Formality(
	id_formality INT PRIMARY KEY,
    formality_label VARCHAR(45) NOT NULL
);

-- Tabla Poblacion Total
CREATE TABLE TotalPopulation(
    id_quarter INT,
    total_population_count BIGINT NOT NULL,
    PRIMARY KEY (id_quarter),
    FOREIGN KEY (id_quarter) REFERENCES Periods(id_quarter)
);

-- Tabla Actividad Laboral
CREATE TABLE LaborActivity(
    id_quarter INT,
    id_gender INT,
    pea_count BIGINT,
    unemployed_count BIGINT,
    PRIMARY KEY (id_quarter, id_gender),
    FOREIGN KEY (id_quarter) REFERENCES Periods(id_quarter),
    FOREIGN KEY (id_gender) REFERENCES Genders(id_gender)
);

-- Tabla Metricas Salariales
CREATE TABLE SalaryMetrics (
    id_quarter INT NOT NULL,
    id_gender INT NOT NULL, 
    id_formality INT NOT NULL, 
    total_count BIGINT NOT NULL,
    average_monthly_wage DECIMAL(12, 2),
    PRIMARY KEY (id_quarter, id_gender, id_formality), 
    FOREIGN KEY (id_quarter) REFERENCES Periods(id_quarter),
    FOREIGN KEY (id_gender) REFERENCES Genders(id_gender),
    FOREIGN KEY (id_formality) REFERENCES Formality(id_formality)
);

-- Tabla Desempleo
CREATE TABLE Unemployment(
    id_quarter INT,
    total_unemployed_count BIGINT NOT NULL,
    PRIMARY KEY (id_quarter),
    FOREIGN KEY (id_quarter) REFERENCES Periods(id_quarter)
);

-- Vistas de tablas 
SHOW TABLES; 
SELECT * FROM periods;
SELECT * FROM genders;
SELECT * FROM formality;
SELECT * FROM totalpopulation;
SELECT * FROM unemployment; 
SELECT * FROM laboractivity;
SELECT * FROM salarymetrics; 
