import requests
import pandas as pd

def extraer_api(url):
    response = requests.get(url) #respuesta de la solicitud

    if response.status_code == 200:
        data = response.json()["data"] #los datos vienen dentro de un diccionario y para obtenerlos es necesario acceder a la llave "data".

        d = {"State": [], "Quarter": [], "Sex": [], "Total":[]} #diccionario con lo que vamos a extraer

        for item in data: #ciclo para recorrer cada registro de data
            # agregar los registros que encuentre
            d["State"].append(item["State"])
            d["Quarter"].append(item["Quarter"])
            d["Sex"].append(item["Sex"])
            d["Total"].append(item["Workforce"])

        df = pd.DataFrame(d) #crear el dataframe
        print("Extracción de desocupación por género realizada con éxito.")
        return df

    else:
        print(f"Error {response.status_code} en la API")

def ejecutar_des2(urls):
    dataframes = [] #guardar los dataframe
    for url in urls: #recorrer la lista de urls
        df = extraer_api(url) #hacer el dataframe
        if df is not None: #si hay dataframe
            dataframes.append(df) #lo guarda en la lista

    #concatenar los df
    if dataframes: #si existen
        df_final = pd.concat(dataframes) #los une
        return df_final

    else:
        print("No se obtuvieron datos de las APIs")



#Descomentar en caso de querer hacer pruebas individuales
#if __name__ == '__main__':
#    urls = ["https://www.economia.gob.mx/datamexico/api/data?State=2&Economically+Active+Population=1&Population+Classification=2&cube=inegi_enoe&drilldowns=State,Quarter,Sex&measures=Workforce&locale=es&parents=false",
#    "https://www.economia.gob.mx/datamexico/api/data?State=2&Economically+Active+Population=1&cube=inegi_enoe&drilldowns=State,Quarter,Sex&measures=Workforce&locale=es&parents=false"]
#    df = ejecutar_des2(urls)
#    df.to_csv("../datasets/pob_desocupada_sexo.csv")
