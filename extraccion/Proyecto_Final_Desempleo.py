# Proyeco Final Desempleo de Baja California

import mysql.connector
from mysql.connector import Error
import pandas as pd
from sqlalchemy import create_engine
from enum import Enum

class DataBD(Enum):
    USER = 'root'
    PASSWORD = 'datosavanzada'
    NAME_BD = 'Project_Final_Unemployment'
    SERVER = 'localhost'

files = {
    'pob_total': 'datasets/pob_total_bc.csv',
    'salary_sex': 'datasets/pob_salario_sexo.csv',
    'salary_formality': 'datasets/pob_salario_formalidad.csv',
    'pea_bc': 'datasets/pob_pea_bc.csv',
    'pop_desocupada': 'datasets/pob_desocupada.csv',
    'pea_sex': 'datasets/pob_pea_sexo.csv',
    'desocupada_sex' : 'datasets/pob_desocupada_sexo.csv'
}

cadena_conexion = f"mysql+mysqlconnector://{DataBD.USER.value}:{DataBD.PASSWORD.value}@{DataBD.SERVER.value}/{DataBD.NAME_BD.value}"
print(cadena_conexion)

def load_data(file_path):
    # se necesitan para poder cargar los datos de los csv y poderlos leer
    # se elimina index, id_state y state ya que todos los registros son de bajacalifornia con id 2
    df = pd.read_csv(file_path)
    if 'IdClasification' in df.columns:
        df = df.rename(columns={'IdClasification':'IdFormality'})
    cols_to_drop = ['Unnamed: 0', 'IdState', 'State']
    return df.drop(columns=[col for col in cols_to_drop if col in df.columns], errors= 'ignore')

def clean_data(conexionMySQL):
    # se insertan y limpian los datos de pop_total en la tabla de periods mysql
    df_periods = load_data(files['pob_total'])
    df_periods = df_periods[['IdQuarter', 'Quarter']].drop_duplicates()
    df_periods = df_periods.rename(columns={'IdQuarter': 'id_quarter', 'Quarter': 'quarter_label'})
    df_periods['year_num'] = df_periods['quarter_label'].str[:4].astype(int)
    df_periods['quarter_num'] = df_periods['quarter_label'].str[-2:].str.replace('Q', '').astype(int)
    df_periods.to_sql(name='periods', con=conexionMySQL, if_exists='append', index=False)

    # se insertan y limpian los datos de salary_sex en la tabla de genders mysql
    df_genders = load_data(files['salary_sex'])
    df_genders = df_genders[['IdSex', 'Sex']].drop_duplicates()
    df_genders['id_gender'] = pd.to_numeric(df_genders['IdSex'], errors= 'coerce')
    df_genders['id_gender'] = df_genders['id_gender'].fillna(0).astype(int)
    df_genders = df_genders.rename(columns={'Sex':  'gender_label'})
    df_genders[['id_gender', 'gender_label']].to_sql(name= 'genders', con=conexionMySQL, if_exists='append', index=False)

    # se insertan y limpian los datos de salary_formality en la tabla de formality mysql
    df_formality = load_data(files['salary_formality'])
    df_formality = df_formality[['IdFormality', 'Clasification']].drop_duplicates()
    df_formality['IdFormality'] = df_formality['IdFormality'].astype(int)
    df_formality = df_formality.rename(columns= {'IdFormality': 'id_formality', 'Clasification': 'formality_label'})
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

def prepare_and_load(conexionMySQL):
    # mapeos para eliminar duplicados en tablas como periods y genders
    df_map_periods = load_data(files['pob_total'])[['IdQuarter', 'Quarter']].drop_duplicates().rename(
        columns={'IdQuarter': 'id_quarter', 'Quarter': 'Quarter'})
    df_map_genders = load_data(files['salary_sex'])[['IdSex', 'Sex']].drop_duplicates().rename(
        columns={'IdSex': 'id_gender', 'Sex': 'Sex'})

    # se insertan y limpian los datos de salary_formality en la tabla de totalpopulation mysql
    df_pea_bc = load_data(files['pea_bc'])
    df_pea_bc = df_pea_bc.rename(columns={'IdQuarter': 'id_quarter', 'Total': 'total_population_count'})
    df_pea_bc = df_pea_bc[['id_quarter', 'total_population_count']]
    df_pea_bc.to_sql(name='totalpopulation', con=conexionMySQL, if_exists='append', index=False)

    # se insertan y limpian los datos de pop_desocupada en la tabla de unemployment mysql
    df_desocupada = load_data(files['pop_desocupada'])
    df_desocupada = df_desocupada.rename(columns={'IdQuarter':'id_quarter', 'Total': 'total_unemployed_count'})
    df_desocupada = df_desocupada[['id_quarter', 'total_unemployed_count']]
    df_desocupada.to_sql(name= 'unemployment', con=conexionMySQL, if_exists='append', index=False)

    # se insertan y limpian los datos de pea_sex y desocupada_sex en la tabla de laboractivity mysql
    df_pea = load_data(files['pea_sex'])
    df_pea = df_pea.rename(columns={'IdQuarter': 'id_quarter', 'IdSex': 'id_gender', 'Total': 'pea_count'})
    df_pea['id_gender'] = pd.to_numeric(df_pea['id_gender'], errors='coerce').fillna(0).astype(int)

    df_unemployed = load_data(files['desocupada_sex'])
    df_unemployed = pd.merge(df_unemployed, df_map_periods, on='Quarter', how='left')
    df_unemployed = pd.merge(df_unemployed, df_map_genders, on='Sex', how='left')
    df_unemployed = df_unemployed.rename(
        columns={'Total': 'unemployed_count'})
    df_unemployed['id_gender'] = df_unemployed['id_gender'].fillna(0).astype(int)

    df_labor = pd.merge(
        df_pea[['id_quarter', 'id_gender', 'pea_count']],
        df_unemployed[['id_quarter', 'id_gender', 'unemployed_count']],
        on=['id_quarter', 'id_gender'],
        how='outer'
    )

    df_labor['pea_count'] = df_labor['pea_count'].fillna(0)
    df_labor['unemployed_count'] = df_labor['unemployed_count'].fillna(0).astype(int)
    df_labor = df_labor.drop_duplicates(subset=['id_quarter', 'id_gender'])
    df_labor.to_sql(name='laboractivity', con=conexionMySQL, if_exists='append', index=False)

    # se insertan y limpian los datos de salary_sex y salary_formality en la tabla de salarymetrics mysql
    df_salary_sex = load_data(files['salary_sex'])
    df_salary_sex = df_salary_sex.rename(
        columns={'IdQuarter': 'id_quarter', 'IdSex': 'id_gender', 'Total': 'total_count',
                 'Monthly Wage': 'average_monthly_wage'})
    df_salary_sex['id_formality'] = 0
    df_salary_sex['id_gender'] = pd.to_numeric(df_salary_sex['id_gender'], errors='coerce').fillna(0).astype(int)
    df_salary_sex = df_salary_sex[
        ['id_quarter', 'id_gender', 'id_formality', 'total_count', 'average_monthly_wage']]

    df_salary_formality = load_data(files['salary_formality'])
    df_salary_formality = df_salary_formality.rename(
        columns={'IdQuarter': 'id_quarter', 'IdFormality': 'id_formality', 'Total': 'total_count',
                 'MonthlyWage': 'average_monthly_wage'})
    df_salary_formality['id_gender'] = 0
    df_salary_formality['id_formality'] = pd.to_numeric(df_salary_formality['id_formality'], errors='coerce').fillna(
        0).astype(int)
    df_salary_formality = df_salary_formality[
        ['id_quarter', 'id_gender', 'id_formality', 'total_count', 'average_monthly_wage']]
    df_salary_formality['total_count'] = df_salary_formality['total_count'].fillna(0)
    df_salary_formality['average_monthly_wage'] = df_salary_formality['average_monthly_wage'].fillna(0)
    df_salary_formality = df_salary_formality.drop_duplicates()

    df_salary = pd.concat([df_salary_sex, df_salary_formality], ignore_index=True)
    df_salary.to_sql(name='salarymetrics', con=conexionMySQL, if_exists='append', index=False)

def etl():
    NAME_BD = DataBD.NAME_BD.value
    print(f"Iniciando Proceso ETL para la base de datos: {NAME_BD}")

    try:
        insert_genders_formality()

        # se crea la conexion con mysql
        engineMySQL = create_engine(cadena_conexion)
        conexionMySQL = engineMySQL.connect()

        # se mandar a llamar las funciones
        clean_data(conexionMySQL)
        prepare_and_load(conexionMySQL)

        # se cierra la conexion con mysql
        conexionMySQL.close()

        print("\n Proceso ETL finalizado con éxito.")

    except Exception as e:
        print(f"\n❌ ¡Error! durante la conexión o inserción en MySQL: {e}")

if __name__ == '__main__':
    etl()