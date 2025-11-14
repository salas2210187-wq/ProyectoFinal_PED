import requests
import pandas as pd

def extraer_api(url):
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()["data"]

        d = {
            "IdState": [], "State": [],
            "IdQuarter": [], "Quarter": [],
            "Total": []
        }

        for item in data:
            d["IdState"].append(item["State ID"])
            d["State"].append(item["State"])
            d["IdQuarter"].append(item["Quarter ID"])
            d["Quarter"].append(item["Quarter"])
            d["Total"].append(item["Workforce"])
        df = pd.DataFrame(d)
        return df
    else:
        print("ERROR")


if __name__ == "__main__":
    df1 = extraer_api("http://www.economia.gob.mx/datamexico/api/data?State=2&cube=inegi_enoe&drilldowns=State,Quarter&measures=Workforce&locale=es&parents=false")
    df1.to_csv("datasets/pop_total_bc.csv")
