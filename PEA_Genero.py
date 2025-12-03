import streamlit as st
from Common import (
    charts_desbalance_genero_pea,
    apply_global_filters
)

def mostrar_pea_genero(global_state):
    st.header("PEA y Desbalance por Género")

    fig_group_pea, fig_pct_pea, df_pea = charts_desbalance_genero_pea(global_state)

    b1, b2 = st.columns(2)

    if fig_group_pea:
        b1.plotly_chart(fig_group_pea, use_container_width=True)
    if fig_pct_pea:
        b2.plotly_chart(fig_pct_pea, use_container_width=True)

    if st.session_state.get("show_table", True):
        st.dataframe(df_pea)
