import requests
import pandas as pd

def extraer_api(url):
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()["data"]

        d = {
            "IdState": [], "State":[],
            "IdQuarter": [], "Quarter":[],
            "IdClasification": [], "Clasification": [],
            "MonthlyWage": [], "Total": [],
        }

        for item in data:
            d["IdState"].append(item["State ID"])
            d["State"].append(item["State"])
            d["IdQuarter"].append(item["Quarter ID"])
            d["Quarter"].append(item["Quarter"])
            d["IdClasification"].append(item["Classification of Formal and Informal Jobs of the First Activity ID"])
            d["Clasification"].append(item["Classification of Formal and Informal Jobs of the First Activity"])
            d["MonthlyWage"].append(item["Monthly Wage"])
            d["Total"].append(item["Workforce"])

        df = pd.DataFrame(d)
        return df
    else:
        print("ERROR")


if __name__ == "__main__":
    df1 = extraer_api("http://www.economia.gob.mx/datamexico/api/data?Classification of Formal and Informal Jobs of the First Activity=1,2&Population+Classification=1&State=2&cube=inegi_enoe&drilldowns=State,Quarter,Classification of Formal and Informal Jobs of the First Activity&measures=Monthly+Wage,Workforce&locale=es&parents=false")
    df1.to_csv("datasets/pob_salario_formalidad.csv")