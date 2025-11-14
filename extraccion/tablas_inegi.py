import pandas as pd

def pea_tj():
    d1 = {"City": [], "Quarter": [], "Sex": [], "Total": []}
    d2 = {"City": [], "Quarter": [], "Sex": [], "Total": []}
    df_htj = pd.read_csv("csv2/pea_hombreTj1.csv", encoding='latin-1')
    df_mtj = pd.read_csv("csv2/pea_mujeresTj2.csv",  encoding='latin-1')

    for i in df_htj:
        d1["City"].append("Tijuana")
        d1["Quarter"].append(i[0])
        d1["Sex"].append("Hombre")
        d1["Total"].append(i[1])
    for j in df_mtj:
        d2["City"].append("Tijuana")
        d2["Quarter"].append(j[0])
        d2["Sex"].append("Mujer")
        d2["Total"].append(j[1])
    df1 = pd.DataFrame(d1)
    df1.to_csv("datasets/inegi1.csv", index=False)
    df2 = pd.DataFrame(d2)
    df2.to_csv("datasets/inegi2.csv", index=False)

if __name__ == "__main__":
    pea_tj()
    #pea_mx()
    #desempleados_tj()
    #desempleados_mx()
    #trabajando_tj()
    #trabajando_mx()