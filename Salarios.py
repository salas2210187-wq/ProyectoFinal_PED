import streamlit as st
from Common import (
    charts_brecha_salarial,
    charts_salario_por_genero,
    apply_global_filters
)

def mostrar_salarios(global_state):
    st.header("Salarios y Brechas")

    # Brecha salarial
    fig_mirror, fig_gap, df_brecha = charts_brecha_salarial(global_state)
    # Salario por género
    fig_gen_line, fig_heat, df_spg = charts_salario_por_genero(global_state)

    a, b = st.columns(2)

    if fig_mirror:
        a.plotly_chart(fig_mirror, use_container_width=True)
    if fig_gap:
        a.plotly_chart(fig_gap, use_container_width=True)

    if fig_gen_line:
        b.plotly_chart(fig_gen_line, use_container_width=True)

    if fig_heat:
        st.plotly_chart(fig_heat, use_container_width=True)

    if st.session_state.get("show_table", True):
        st.subheader("Datos - Brecha Salarial")
        st.dataframe(df_brecha)

        st.subheader("Datos - Salario por Género")
        st.dataframe(df_spg)