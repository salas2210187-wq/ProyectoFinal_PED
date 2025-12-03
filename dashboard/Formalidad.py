import streamlit as st
from Common import (
    charts_salario_por_formalidad,
    charts_composicion_formalidad,
    apply_global_filters
)

def mostrar_formalidad(global_state):
    st.header("Formalidad y Composición")
    fig_group, fig_line_sf, df_sform = charts_salario_por_formalidad()
    fig_donut, fig_stack, df_comp = charts_composicion_formalidad()

    a1, a2 = st.columns(2)
    if fig_group:
        a1.plotly_chart(fig_group, use_container_width=True)
    if fig_line_sf:
        a1.plotly_chart(fig_line_sf, use_container_width=True)
    if fig_donut:
        a2.plotly_chart(fig_donut, use_container_width=True)
    if fig_stack:
        a2.plotly_chart(fig_stack, use_container_width=True)

    if st.session_state.get("show_table", True):
        st.dataframe(apply_global_filters(df_sform, global_state))
        st.dataframe(apply_global_filters(df_comp, global_state))
