import streamlit as st
from Common import VIEWS, load_view_df, apply_global_filters

def mostrar_todas(global_state):
    for v in VIEWS:
        st.subheader(v)
        df_v = load_view_df(v)
        df_v_filtered = apply_global_filters(df_v, global_state)

        if df_v_filtered is not None:
            st.download_button(
                f"Descargar {v}.csv",
                df_v_filtered.to_csv(index=False).encode("utf-8"),
                file_name=f"{v}.csv"
            )
            st.dataframe(df_v_filtered)
        else:
            st.info(f"No hay datos o no se pudo cargar {v}")
