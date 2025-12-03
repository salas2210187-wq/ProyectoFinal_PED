from tkinter import simpledialog, messagebox

#Extraccion de apis
from extraccion.pob_desocupada import ejecutar_des
from extraccion.pob_desocupada_sexo import ejecutar_des2
from extraccion.pob_pea import ejecutar_pea
from extraccion.pob_pea_sexo import ejecutar_peas
from extraccion.pob_total import ejecutar_total
from extraccion.salario_formalidad import ejecutar_form
from extraccion.salario_sexo import ejecutar_gen

#Limpieza y base de datos
from limpieza_bd.Proyecto_Final_Desempleo import etl

#Dashboard
import subprocess
import sys

# Main
opc = 0

#Extraer apis
def extraer_data():
    #Poblacion desocupada
    ejecutar_des()

    #Poblacion desocupada por genero
    urls = ["https://www.economia.gob.mx/datamexico/api/data?State=2&Economically+Active+Population=1&Population+Classification=2&cube=inegi_enoe&drilldowns=State,Quarter,Sex&measures=Workforce&locale=es&parents=false",
            "https://www.economia.gob.mx/datamexico/api/data?State=2&Economically+Active+Population=1&cube=inegi_enoe&drilldowns=State,Quarter,Sex&measures=Workforce&locale=es&parents=false"]
    df = ejecutar_des2(urls)
    df.to_csv("datasets/pob_desocupada_sexo.csv")

    #Poblacion PEA
    ejecutar_pea()

    #Poblacion PEA por genero
    ejecutar_peas()

    #Poblacion total
    ejecutar_total()

    #Salario por formalidad (trabajo forma o informal)
    ejecutar_form()

    #Salario por genero
    ejecutar_gen()

#MAIN
opc = 0

while opc != 4:
    opc = simpledialog.askinteger(
        "Menú Principal",
        "Seleccione una opción:\n"
        "1) Extracción\n"
        "2) Limpieza\n"
        "3) Visualización\n"
        "4) Exit"
    )

    if opc == 1:
        extraer_data()

    elif opc == 2:
        etl()

    elif opc == 3:
        streamlit_file = "dashboard/Main.py"
        subprocess.run([sys.executable, "-m", "streamlit", "run", streamlit_file])

    elif opc == 4:
        messagebox.showinfo("Salir", "Hasta luego :)")

    else:
        messagebox.showerror("ERROR", "Esa opción NO existe.")