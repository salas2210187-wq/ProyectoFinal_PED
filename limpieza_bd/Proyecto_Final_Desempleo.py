# Proyeco Final Desempleo de Baja California

import mysql.connector
from mysql.connector import Error
import pandas as pd
from sqlalchemy import create_engine
from enum import Enum

from limpieza_bd.limpieza import load_data, limpiar_preparar_pgf, limpiar_preparar_pdls


class DataBD(Enum):
    USER = 'root'
    PASSWORD = '12345678'
    NAME_BD = 'Project_Final_Unemployment'
    SERVER = 'localhost'

def archivos_csv():
    files = {
    'pob_total': 'datasets/pob_total_bc.csv',
    'salary_sex': 'datasets/pob_salario_sexo.csv',
    'salary_formality': 'datasets/pob_salario_formalidad.csv',
    'pea_bc': 'datasets/pob_pea_bc.csv',
    'pob_desocupada': 'datasets/pob_desocupada.csv',
    'pea_sex': 'datasets/pob_pea_sexo.csv',
    'desocupada_sex' : 'datasets/pob_desocupada_sexo.csv'}
    return files

cadena_conexion = f"mysql+mysqlconnector://{DataBD.USER.value}:{DataBD.PASSWORD.value}@{DataBD.SERVER.value}/{DataBD.NAME_BD.value}"

def cargar_datos_pgf(conexionMySQL):
    files = archivos_csv()

    #limpiar y preparar
    df_periods, df_genders, df_formality = limpiar_preparar_pgf(files)

    # insertar en periods
    df_periods.to_sql(name='periods', con=conexionMySQL, if_exists='append', index=False)

    # insertar en genders
    df_genders[['id_gender', 'gender_label']].to_sql(name= 'genders', con=conexionMySQL, if_exists='append', index=False)

    # insertar en formality
    df_formality.to_sql(name= 'formality', con=conexionMySQL, if_exists='append', index=False)

def insert_genders_formality():
    # Se crea una cadena de conexion para poder agregar los inserts en
    # la tabla genders y formality para que el codigo pueda correr sin restricciones
    cadena = (
        f"mysql+mysqlconnector://{DataBD.USER.value}:{DataBD.PASSWORD.value}@{DataBD.SERVER.value}/{DataBD.NAME_BD.value}")
    try:
        cnx = mysql.connector.connect(
            user=DataBD.USER.value,
            password=DataBD.PASSWORD.value,
            host=DataBD.SERVER.value,
            database=DataBD.NAME_BD.value
        )
        with cnx.cursor() as cursor:
            mysql_genders = ("INSERT INTO Genders (id_gender, gender_label) VALUES (0, 'S/N genero') "
                             "ON DUPLICATE KEY UPDATE gender_label=VALUES(gender_label)")
            cursor.execute(mysql_genders)
            mysql_formality = ("INSERT INTO Formality (id_formality, formality_label) VALUES (0, 'S/N Especificación') "
                               "ON DUPLICATE KEY UPDATE formality_label=VALUES(formality_label)")
            cursor.execute(mysql_formality)

            cnx.commit()

    except Error as e:
        print(f"❌ Error al insertar claves: {e}")
        # Si la conexión falla, no continúa
        raise

    finally:
        if 'cnx' in locals() and cnx.is_connected():
            cnx.close()

def cargar_datos_pdls(conexionMySQL):
    files = archivos_csv()

    #limpiar y preparar
    df_pea_bc, df_desocupada, df_labor, df_salary = limpiar_preparar_pdls(files)

    # se insertan los datos de salary_formality en la tabla de totalpopulation mysql
    df_pea_bc.to_sql(name='totalpopulation', con=conexionMySQL, if_exists='append', index=False)

    # se insertan y limpian los datos de pob_desocupada en la tabla de unemployment mysql
    df_desocupada.to_sql(name= 'unemployment', con=conexionMySQL, if_exists='append', index=False)

    # se insertan los datos de pea_sex y desocupada_sex en la tabla de laboractivity mysql
    df_labor.to_sql(name='laboractivity', con=conexionMySQL, if_exists='append', index=False)

    # se insertan los datos de salary_sex y salary_formality en la tabla de salarymetrics mysql
    df_salary.to_sql(name='salarymetrics', con=conexionMySQL, if_exists='append', index=False)

def etl():
    NAME_BD = DataBD.NAME_BD.value
    print(f"Iniciando Proceso ETL para la base de datos: {NAME_BD}")

    try:
        insert_genders_formality()

        # se crea la conexion con mysql
        engineMySQL = create_engine(cadena_conexion)
        conexionMySQL = engineMySQL.connect()

        # cargar datasets (periods, genders y formality)
        cargar_datos_pgf(conexionMySQL)

        #cargar datasets (poblacion, desempleo, actividad, salario)
        cargar_datos_pdls(conexionMySQL)

        # se cierra la conexion con mysql
        conexionMySQL.close()

        print("\n Proceso ETL finalizado con éxito.")

    except Exception as e:
        print(f"\n❌ ¡Error! durante la conexión o inserción en MySQL: {e}")

#if __name__ == '__main__':
 #   etl()

