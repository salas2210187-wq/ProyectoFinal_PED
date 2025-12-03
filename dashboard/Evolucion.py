import streamlit as st
from Common import charts_evolucion_desempleo_general, apply_global_filters

def mostrar_evolucion(global_state):
    st.header("Evolución y Ocupación")
    fig_dual, fig_area, df_evo = charts_evolucion_desempleo_general()
    df_evo = apply_global_filters(df_evo, global_state)
    c1, c2 = st.columns(2)
    if fig_dual:
        c1.plotly_chart(fig_dual, use_container_width=True)
    if fig_area:
        c2.plotly_chart(fig_area, use_container_width=True)
    if st.session_state.get("show_table", True):
        st.dataframe(df_evo)
