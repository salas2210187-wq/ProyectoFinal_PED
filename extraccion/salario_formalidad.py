import requests
import pandas as pd

def extraer_api(url):
    response = requests.get(url) #respuesta de la solicitud

    if response.status_code == 200:
        data = response.json()["data"] #los datos vienen dentro de un diccionario y para obtenerlos es necesario acceder a la llave "data".

        d = {"IdState": [], "State":[],"IdQuarter": [], "Quarter":[], "IdClasification": [],
             "Clasification": [], "MonthlyWage": [], "Total": [],} #diccionario con lo que vamos a extraer

        for item in data: #ciclo para recorrer cada registro de data
            # agregar los registros que encuentre
            d["IdState"].append(item["State ID"])
            d["State"].append(item["State"])
            d["IdQuarter"].append(item["Quarter ID"])
            d["Quarter"].append(item["Quarter"])
            d["IdClasification"].append(item["Classification of Formal and Informal Jobs of the First Activity ID"])
            d["Clasification"].append(item["Classification of Formal and Informal Jobs of the First Activity"])
            d["MonthlyWage"].append(item["Monthly Wage"])
            d["Total"].append(item["Workforce"])

        df = pd.DataFrame(d) #crear el dataframe
        df.to_csv("datasets/pob_salario_formalidad.csv")

        print("Extracción de datos de salario por formalidad realizada con éxito.")

    else:
        print(f"Error {response.status_code} en la API")

def ejecutar_form():
    url = "http://www.economia.gob.mx/datamexico/api/data?Classification of Formal and Informal Jobs of the First Activity=1,2&Population+Classification=1&State=2&cube=inegi_enoe&drilldowns=State,Quarter,Classification of Formal and Informal Jobs of the First Activity&measures=Monthly+Wage,Workforce&locale=es&parents=false"
    extraer_api(url)

#Descomentar en caso de querer hacer pruebas individuales
#Para las pruebas individuales en necesario cambiar el guardado a df.to_csv("../datasets/pob_salario_formalidad.csv")
#if __name__ == '__main__':
#    ejecutar_form()