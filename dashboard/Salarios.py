import streamlit as st
from Common import (
    charts_brecha_salarial,
    charts_salario_por_genero,
    apply_global_filters
)

def mostrar_salarios(global_state):
    st.header("Salarios y Brechas")
    fig_mirror, fig_gap, df_brecha = charts_brecha_salarial()
    fig_gen_line, fig_heat, df_spg = charts_salario_por_genero()

    c1, c2 = st.columns(2)
    if fig_mirror:
        c1.plotly_chart(fig_mirror, use_container_width=True)
    if fig_gap:
        c1.plotly_chart(fig_gap, use_container_width=True)
    if fig_gen_line:
        c2.plotly_chart(fig_gen_line, use_container_width=True)
    if fig_heat:
        st.plotly_chart(fig_heat, use_container_width=True)

    if st.session_state.get("show_table", True):
        st.subheader("Datos - Brecha Salarial")
        st.dataframe(apply_global_filters(df_brecha, global_state))

        st.subheader("Datos - Salario por Género")
        st.dataframe(apply_global_filters(df_spg, global_state))
