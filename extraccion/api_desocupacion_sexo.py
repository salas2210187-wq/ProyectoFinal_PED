import requests
import pandas as pd

def extraer_api(url):
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()["data"]

        d = {"State": [], "Quarter": [], "Sex": [], "Total":[]}

        for item in data:
            d["State"].append(item["State"])
            d["Quarter"].append(item["Quarter"])
            d["Sex"].append(item["Sex"])
            d["Total"].append(item["Workforce"])
        df = pd.DataFrame(d)
        return df
    else:
        print("ERROR")


if __name__ == "__main__":
    df1 = extraer_api("https://www.economia.gob.mx/datamexico/api/data?State=2&Economically+Active+Population=1&Population+Classification=2&cube=inegi_enoe&drilldowns=State,Quarter,Sex&measures=Workforce&locale=es&parents=false")
    df2 = extraer_api("https://www.economia.gob.mx/datamexico/api/data?State=2&Economically+Active+Population=1&Population+Classification=2&cube=inegi_enoe&drilldowns=State,Quarter,Sex&measures=Workforce&locale=es&parents=false")
    df = pd.concat([df1, df2])
    df.to_csv("datasets/pob_desocupada_sexo.csv")
