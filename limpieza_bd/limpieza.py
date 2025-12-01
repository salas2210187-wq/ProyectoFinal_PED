import pandas as pd

def load_data(file_path):
    # se necesitan para poder cargar los datos de los csv y poderlos leer
    # se elimina index, id_state y state ya que todos los registros son de bajacalifornia con id 2
    df = pd.read_csv(file_path)
    if 'IdClasification' in df.columns:
        df = df.rename(columns={'IdClasification':'IdFormality'})
    cols_to_drop = ['Unnamed: 0', 'IdState', 'State']
    return df.drop(columns=[col for col in cols_to_drop if col in df.columns], errors= 'ignore')

def limpiar_preparar_pgf(files):
    #limpiar y preparar datos de periods
    df_periods = load_data(files['pob_total'])
    df_periods = df_periods[['IdQuarter', 'Quarter']].drop_duplicates()
    df_periods = df_periods.rename(columns={'IdQuarter': 'id_quarter', 'Quarter': 'quarter_label'})
    df_periods['year_num'] = df_periods['quarter_label'].str[:4].astype(int)
    df_periods['quarter_num'] = df_periods['quarter_label'].str[-2:].str.replace('Q', '').astype(int)

    #limpiar y preparar datos de genders
    df_genders = load_data(files['salary_sex'])
    df_genders = df_genders[['IdSex', 'Sex']].drop_duplicates()
    df_genders['id_gender'] = pd.to_numeric(df_genders['IdSex'], errors='coerce')
    df_genders['id_gender'] = df_genders['id_gender'].fillna(0).astype(int)
    df_genders = df_genders.rename(columns={'Sex': 'gender_label'})

    #limpiar y preparar datos de formality
    df_formality = load_data(files['salary_formality'])
    df_formality = df_formality[['IdFormality', 'Clasification']].drop_duplicates()
    df_formality['IdFormality'] = df_formality['IdFormality'].astype(int)
    df_formality = df_formality.rename(columns={'IdFormality': 'id_formality', 'Clasification': 'formality_label'})

    return df_periods, df_genders, df_formality

def limpiar_preparar_pdls(files):
    # mapeos para eliminar duplicados en tablas como periods y genders
    df_map_periods = load_data(files['pob_total'])[['IdQuarter', 'Quarter']].drop_duplicates().rename(
        columns={'IdQuarter': 'id_quarter', 'Quarter': 'Quarter'})
    df_map_genders = load_data(files['salary_sex'])[['IdSex', 'Sex']].drop_duplicates().rename(
        columns={'IdSex': 'id_gender', 'Sex': 'Sex'})

    # se insertan los datos de salary_formality en la tabla de totalpopulation mysql
    df_pea_bc = load_data(files['pea_bc'])
    df_pea_bc = df_pea_bc.rename(columns={'IdQuarter': 'id_quarter', 'Total': 'total_population_count'})
    df_pea_bc = df_pea_bc[['id_quarter', 'total_population_count']]

    # se insertan y limpian los datos de pop_desocupada en la tabla de unemployment mysql
    df_desocupada = load_data(files['pob_desocupada'])
    df_desocupada = df_desocupada.rename(columns={'IdQuarter': 'id_quarter', 'Total': 'total_unemployed_count'})
    df_desocupada = df_desocupada[['id_quarter', 'total_unemployed_count']]

    # se insertan los datos de pea_sex y desocupada_sex en la tabla de laboractivity mysql
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

    #limpiar los datos de salary_sex y salary_formality en la tabla de salarymetrics mysql
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

    return df_pea_bc, df_desocupada, df_labor, df_salary




