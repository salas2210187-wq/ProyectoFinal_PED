import streamlit as st
from Common import (
    charts_resumen_anual, apply_global_filters, show_kpi_row
)

def mostrar_resumen(global_state):
    st.header("Resumen Anual")

    fig_line, fig_bar, df_res, kpis = charts_resumen_anual(global_state)

    show_kpi_row(kpis)

    col1, col2 = st.columns(2)
    if fig_line:
        col1.plotly_chart(fig_line, use_container_width=True)
    if fig_bar:
        col2.plotly_chart(fig_bar, use_container_width=True)

    if st.session_state.get("show_table", True):
        st.dataframe(df_res)
