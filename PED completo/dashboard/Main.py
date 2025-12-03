# Archivo principal del dashboard en Streamlit. Este archivo NO ejecuta Streamlit directamente
# Streamlit se ejecuta mediante run.py
# Este archivo configura la página y crea las pestañas que importan y llaman a funciones mostrar_ de cada archivo en las pestañas
import streamlit as st
from Common import sidebar_controls

from Resumen import mostrar_resumen
from Evolucion import mostrar_evolucion
from Salarios import mostrar_salarios
from Formalidad import mostrar_formalidad
from PEA_Genero import mostrar_pea_genero
from Todas_las_Vistas import mostrar_todas


def main():
    # Muestra encabezados fijos
    st.set_page_config(page_title="Dashboard Desempleo - Baja California", layout="wide", initial_sidebar_state="expanded")

    # Encabezado
    st.markdown("<h1 style='text-align:center;'>Desempleo en Baja California</h1>", unsafe_allow_html=True)
    st.markdown("<h4 style='text-align:right; margin-top:0;'>Datos del 2010 al 2025</h4>", unsafe_allow_html=True)
    st.markdown("---")

    # Diccionario donde se almacenan los filtros globales seleccionados por el usuario (año, género, formalidad)
    global_state = {}
    # Cargar los controles de la barra lateral (filtros)
    sidebar_controls(global_state)

    # navegación: pestañas principales
    # st.tabs crea las pestañas. Dentro de cada with tabs[i]: llama a la función correspondiente importada desde las pestañas
    tabs = st.tabs([
        "Resumen", "Evolución", "Salarios", "Formalidad", "PEA & Género", "Todas las vistas"
    ])
    # Cada función mostrar_* pide datos y figuras a las funciones de common.py, aplica los filtros
    # con apply_global_filters() y muestra tablas/figuras con st.plotly_chart() o st.dataframe().
    with tabs[0]:
        mostrar_resumen(global_state)
    with tabs[1]:
        mostrar_evolucion(global_state)
    with tabs[2]:
        mostrar_salarios(global_state)
    with tabs[3]:
        mostrar_formalidad(global_state)
    with tabs[4]:
        mostrar_pea_genero(global_state)
    with tabs[5]:
        mostrar_todas(global_state)

    st.markdown("---")
    st.caption("Fuente de datos: información oficial de la página Data México. Procesamiento y vizualización realizadas para fines académicos.")

# Permite que main() se ejecute correctamente cuando Streamlit importa este archivo
if __name__ == "__main__":
    main()
