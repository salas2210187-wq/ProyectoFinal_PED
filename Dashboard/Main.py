import streamlit as st
from Common import sidebar_controls

from Resumen import mostrar_resumen
from Evolucion import mostrar_evolucion
from Salarios import mostrar_salarios
from Formalidad import mostrar_formalidad
from PEA_Genero import mostrar_pea_genero
from Todas_las_Vistas import mostrar_todas


def main():
    st.set_page_config(page_title="Dashboard Desempleo - Baja California",
                       layout="wide", initial_sidebar_state="expanded")

    st.markdown("<h1 style='text-align:center;'>Desempleo en Baja California</h1>",
                unsafe_allow_html=True)
    st.markdown("<h4 style='text-align:right;'>Datos del 2010 al 2025</h4>",
                unsafe_allow_html=True)
    st.markdown("---")

    global_state = {}
    sidebar_controls(global_state)

    tabs = st.tabs([
        "Resumen", "Evolución", "Salarios",
        "Formalidad", "PEA & Género", "Todas las vistas"
    ])

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


if __name__ == "__main__":
    main()
