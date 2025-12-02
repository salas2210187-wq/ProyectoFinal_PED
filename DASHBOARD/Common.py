import streamlit as st
from sqlalchemy import create_engine
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from typing import Optional, Tuple

# ---------------------------
# CONFIG DB: Define credenciales y la URI de SQLAlchemy para conectarse a MySQL
# ---------------------------
DB_CONFIG = {
    "user": "root",
    "password": "Carro1406M.",
    "host": "localhost",
    "db": "Project_Final_Unemployment"
}

CONN_URI = f"mysql+mysqlconnector://{DB_CONFIG['user']}:{DB_CONFIG['password']}@{DB_CONFIG['host']}/{DB_CONFIG['db']}"

# ---------------------------
# VISTAS: lista de nombres de vistas en la DB que la app usa
# ---------------------------
VIEWS = [
    "Vista_Composicion_Formalidad",
    "Vista_Brecha_Salarial",
    "Vista_Resumen_Anual",
    "Vista_Evolucion_Desempleo_General",
    "Vista_Desbalance_Genero_PEA",
    "Vista_Salario_Por_Formalidad",
    "Vista_Salario_Por_Genero"
]

# ---------------------------
# CONECTOR: Crea un engine de SQLAlchemy usando CONN_URI
# ---------------------------
# con @st.cache_resource Streamlit la cachea y no reconstruye el engine en cada re-ejecución interactiva —
# mejora rendimiento y evita abrir muchas conexiones
@st.cache_resource
def get_engine():
    engine = create_engine(CONN_URI)
    return engine

# ---------------------------
# CARGAR VISTAS A DATAFRAME
# ---------------------------
# @st.cache_data: la primera vez carga y cachea los datos; en siguientes ejecuciones usa la caché
# evita consultas repetitivas
@st.cache_data
def load_view_df(view_name: str) -> Optional[pd.DataFrame]:
    engine = get_engine()
    # Ejecuta SELECT * sobre la vista indicada y retorna un pandas.DataFrame
    query = f"SELECT * FROM {view_name};"
    try:
        df = pd.read_sql(query, engine)
        # Normalizar nombres con strip()
        df.columns = [c.strip() for c in df.columns]
        return df
    except Exception as e:
        st.error(f"Error cargando {view_name}: {e}")
        return None

# ---------------------------
# DECTORES DE COLUMNAS: Recorren columnas y devuelven el primer match
# ---------------------------
def detect_year_column(df: pd.DataFrame) -> Optional[str]:
    candidates = ["Año", "AÑO", "year", "year_num", "anio", "anio_num"]
    for c in candidates:
        if c in df.columns:
            return c
    # Minúsculas
    for c in df.columns:
        if "year" in c.lower() or "año" in c.lower() or "anio" in c.lower():
            return c
    return None

def detect_quarter_column(df: pd.DataFrame) -> Optional[str]:
    candidates = ["Periodo", "Periodo_Trimestre", "quarter_label", "quarter"]
    for c in candidates:
        if c in df.columns:
            return c
    for c in df.columns:
        if "quarter" in c.lower() or "period" in c.lower() or "trimest" in c.lower():
            return c
    return None

# ---------------------------
# KPIs: CALCULA INDICADORES SEGÚN COLUMNAS
# ---------------------------
# Se usa en la pestaña Resumen para obtener KPIs
def compute_kpis_resumen(df: pd.DataFrame) -> Tuple[dict, pd.DataFrame]:
    kpis = {}
    if df is None or df.empty:
        return kpis, df
    # Detecta year_col (o usa la primera columna)
    year_col = detect_year_column(df) or df.columns[0]

    # ordenar por year_col para tomar el último registro
    try:
        df_sorted = df.sort_values(by=year_col)
    except Exception:
        df_sorted = df.copy()
    last = df_sorted.iloc[-1]

    # Busca entre varias columnas posibles (por si la vista usa otro nombre) y devuelve el valor o None
    def safe_get(row, candidates):
        for c in candidates:
            if c in row.index:
                return row[c]
        return None

    kpis["Año"] = last.get(year_col, "")
    kpis["Total Desocupados"] = safe_get(last, ["Total_Desocupados_Acumulado", "total_unemployed_count", "Total_Desocupados_Acumulado"])
    kpis["Tasa desempleo (%)"] = safe_get(last, ["Tasa_Desempleo_Promedio_Anual", "Tasa_Desocupacion_Porc"])
    return kpis, df_sorted

# ---------------------------
# FILTROS - BARRA LATERAL
# ---------------------------
# Contiene los filtros que luego usará apply_global_filters
def sidebar_controls(global_state):
    st.sidebar.title("Controles de Resumen")
    st.sidebar.markdown("Filtros")

    # --- FILTRO DE AÑO ---
    all_years = set()
    for v in VIEWS:
        df = load_view_df(v)
        if df is not None:
            yc = detect_year_column(df)
            if yc and yc in df.columns:
                try:
                    all_years.update(df[yc].dropna().astype(int).unique().tolist())
                except:
                    all_years.update(df[yc].dropna().unique().tolist())

    years_sorted = sorted(list(all_years))

    if years_sorted:
        year_sel = st.sidebar.selectbox("Año", ["Todos"] + years_sorted)
        global_state["year"] = None if year_sel == "Todos" else year_sel
    else:
        global_state["year"] = None

    # --- FILTRO DE GÉNERO ---
    generos = set()
    for v in VIEWS:
        df = load_view_df(v)
        if df is not None and "Sexo" in df.columns:
            generos.update(df["Sexo"].dropna().unique().tolist())

    if generos:
        gen_sel = st.sidebar.selectbox("Género", ["Todos"] + sorted(list(generos)))
        global_state["genero"] = None if gen_sel == "Todos" else gen_sel
    else:
        global_state["genero"] = None

    # --- FILTRO DE FORMALIDAD ---
    formalidades = set()
    for v in VIEWS:
        df = load_view_df(v)
        if df is not None:
            if "Clasificacion" in df.columns:
                formalidades.update(df["Clasificacion"].dropna().unique().tolist())
            if "Tipo_Empleo" in df.columns:
                formalidades.update(df["Tipo_Empleo"].dropna().unique().tolist())

    if formalidades:
        form_sel = st.sidebar.selectbox("Formalidad", ["Todos"] + sorted(list(formalidades)))
        global_state["formalidad"] = None if form_sel == "Todos" else form_sel
    else:
        global_state["formalidad"] = None

    st.sidebar.markdown("---")
    st.sidebar.checkbox("Mostrar tabla de datos para las secciones", value=True, key="show_table")

# ---------------------------
# Aplicación de filtros a DF
# ---------------------------
# Toma un Dataframe y aplica los filtros previos, devolviendo el Dataframe filtrado
def apply_global_filters(df: pd.DataFrame, global_state: dict) -> pd.DataFrame:
    if df is None:
        return df

    df2 = df.copy()

    # Año
    y = global_state.get("year")
    if y is not None:
        yc = detect_year_column(df2)
        if yc in df2.columns:
            df2 = df2[df2[yc].astype(str) == str(y)]

    # Género
    gen = global_state.get("genero")
    if gen is not None and "Sexo" in df2.columns:
        df2 = df2[df2["Sexo"] == gen]

    # Formalidad
    form = global_state.get("formalidad")
    if form is not None:
        for col in ["Clasificacion", "Tipo_Empleo"]:
            if col in df2.columns:
                df2 = df2[df2[col] == form]

    return df2

# ---------------------------
# Helper KPIs
# ---------------------------
# Muestra KPIs (diccionario) en una fila de st.columns y
# convierte los valores a string para st.metric
def show_kpi_row(kpis: dict):
    if not kpis:
        return
    cols = st.columns(len(kpis))
    i = 0
    for k, v in kpis.items():
        cols[i].metric(k, str(v))
        i += 1

# ---------------------------
# GRÁFICAS
# ---------------------------
'''
Cada función hace lo siguiente:
Llama a load_view_df() con la vista correspondiente.
Si df es None (error de carga), retorna Nonees para que la UI muestre nada o un mensaje.
Detecta la columna X (año/periodo) y crea figuras de Plotly según las columnas disponibles.
Devuelve objetos fig (Plotly) y normalmente el df (o df_sorted) para mostrar la tabla si el usuario lo desea.
'''
def charts_resumen_anual(global_state):
    df = load_view_df("Vista_Resumen_Anual")
    if df is None:
        return None, None, None, None

    # Aplicar filtros ANTES de crear gráficas
    df = apply_global_filters(df, global_state)

    year_col = detect_year_column(df) or "Año"

    # Línea — tasa anual
    fig_line = None
    if "Tasa_Desempleo_Promedio_Anual" in df.columns and not df.empty:
        fig_line = px.line(
            df, x=year_col, y="Tasa_Desempleo_Promedio_Anual",
            markers=True, title="Tasa de Desempleo Promedio Anual"
        )

    # Barras — total desocupados
    fig_bar = None
    if "Total_Desocupados_Acumulado" in df.columns and not df.empty:
        fig_bar = px.bar(
            df, x=year_col, y="Total_Desocupados_Acumulado",
            title="Total de Desocupados Acumulado por Año"
        )

    # KPIs con datos filtrados
    kpis, df_sorted = compute_kpis_resumen(df)

    return fig_line, fig_bar, df_sorted, kpis


def charts_evolucion_desempleo_general(global_state):
    df = load_view_df("Vista_Evolucion_Desempleo_General")
    if df is None:
        return None, None, None

    # Aplicar filtros
    df = apply_global_filters(df, global_state)

    x = "ID_Periodo" if "ID_Periodo" in df.columns else detect_year_column(df)

    fig_dual = None
    if ("Tasa_Desocupacion_Porc" in df.columns and
        "Tasa_Ocupacion_Porc" in df.columns and not df.empty):

        fig_dual = go.Figure()
        fig_dual.add_trace(
            go.Scatter(
                x=df[x], y=df["Tasa_Desocupacion_Porc"],
                mode="lines+markers", name="Tasa Desocupación (%)"
            )
        )
        fig_dual.add_trace(
            go.Scatter(
                x=df[x], y=df["Tasa_Ocupacion_Porc"],
                mode="lines+markers", name="Tasa Ocupación (%)"
            )
        )
        fig_dual.update_layout(title="Tasa de Desocupación vs Ocupación (%)")

    fig_area = None
    if "Desocupados_Total" in df.columns and "Ocupados_Total" in df.columns and not df.empty:
        fig_area = go.Figure()
        fig_area.add_trace(go.Scatter(x=df[x], y=df["Ocupados_Total"],
                                      stackgroup='one', name="Ocupados"))
        fig_area.add_trace(go.Scatter(x=df[x], y=df["Desocupados_Total"],
                                      stackgroup='one', name="Desocupados"))
        fig_area.update_layout(title="Ocupados vs Desocupados")

    return fig_dual, fig_area, df


def charts_brecha_salarial(global_state):
    df = load_view_df("Vista_Brecha_Salarial")
    if df is None:
        return None, None, None

    df = apply_global_filters(df, global_state)

    x = detect_year_column(df)

    fig_mirror = None
    if {"Salario_Hombres", "Salario_Mujeres"}.issubset(df.columns) and not df.empty:
        fig_mirror = go.Figure()
        fig_mirror.add_trace(go.Bar(x=df[x], y=df["Salario_Hombres"], name="Hombres"))
        fig_mirror.add_trace(go.Bar(x=df[x], y=df["Salario_Mujeres"], name="Mujeres"))
        fig_mirror.update_layout(barmode='group', title="Salario promedio: Hombres vs Mujeres")

    fig_gap = None
    if "Diferencia_Salarial" in df.columns and not df.empty:
        fig_gap = px.line(
            df, x=x, y="Diferencia_Salarial",
            markers=True, title="Diferencia Salarial (H - M)"
        )

    return fig_mirror, fig_gap, df


def charts_salario_por_genero(global_state):
    df = load_view_df("Vista_Salario_Por_Genero")
    if df is None:
        return None, None, None

    df = apply_global_filters(df, global_state)

    x = "Periodo_Trimestre" if "Periodo_Trimestre" in df.columns else detect_quarter_column(df)

    fig_line = None
    fig_heat = None

    if {"Salario_Promedio_Mensual", "Sexo"}.issubset(df.columns) and not df.empty:
        fig_line = px.line(
            df, x=x, y="Salario_Promedio_Mensual",
            color="Sexo", markers=True,
            title="Salario Promedio Mensual por Género"
        )

        try:
            pivot = df.pivot_table(
                values="Salario_Promedio_Mensual",
                index=x, columns="Sexo"
            )
            fig_heat = px.imshow(
                pivot.T,
                labels=dict(x=x, y="Sexo", color="Salario"),
                x=pivot.index,
                y=pivot.columns,
                title="Mapa de calor: Salario por periodo y sexo"
            )
        except:
            fig_heat = None

    return fig_line, fig_heat, df


def charts_salario_por_formalidad(global_state):
    df = load_view_df("Vista_Salario_Por_Formalidad")
    if df is None:
        return None, None, None

    df = apply_global_filters(df, global_state)

    x = "Periodo_Trimestre" if "Periodo_Trimestre" in df.columns else detect_quarter_column(df)

    fig_group = None
    fig_line = None

    if {"Salario_Promedio_Mensual", "Clasificacion"}.issubset(df.columns) and not df.empty:
        fig_group = px.bar(
            df, x=x, y="Salario_Promedio_Mensual",
            color="Clasificacion", barmode='group',
            title="Salario promedio por formalidad"
        )

        fig_line = px.line(
            df, x=x, y="Salario_Promedio_Mensual",
            color="Clasificacion", markers=True,
            title="Tendencia de salario por formalidad"
        )

    return fig_group, fig_line, df


def charts_composicion_formalidad(global_state):
    df = load_view_df("Vista_Composicion_Formalidad")
    if df is None:
        return None, None, None

    df = apply_global_filters(df, global_state)

    fig_donut = None
    fig_stack = None

    if {"Tipo_Empleo", "Cantidad_Trabajadores"}.issubset(df.columns) and not df.empty:

        last_period = df.iloc[-1].get("Periodo", None) if "Periodo" in df.columns else ""

        fig_donut = px.pie(
            df, names="Tipo_Empleo", values="Cantidad_Trabajadores",
            hole=0.45, title=f"Composición por Formalidad ({last_period})"
        )

        try:
            pivot = df.pivot_table(
                values="Cantidad_Trabajadores",
                index="Periodo", columns="Tipo_Empleo",
                aggfunc='sum'
            ).fillna(0)

            fig_stack = px.bar(
                pivot, x=pivot.index, y=pivot.columns,
                title="Evolución por formalidad"
            )
        except:
            fig_stack = None

    return fig_donut, fig_stack, df


def charts_desbalance_genero_pea(global_state):
    df = load_view_df("Vista_Desbalance_Genero_PEA")
    if df is None:
        return None, None, None

    df = apply_global_filters(df, global_state)

    x = "Periodo_Trimestre" if "Periodo_Trimestre" in df.columns else detect_quarter_column(df)

    fig_group = None
    fig_pct = None

    if {"Sexo", "PEA_Estimada_Total"}.issubset(df.columns) and not df.empty:
        fig_group = px.bar(
            df, x=x, y="PEA_Estimada_Total",
            color="Sexo", barmode='group',
            title="PEA estimada por género"
        )

        try:
            pivot = df.pivot_table(
                values="PEA_Estimada_Total",
                index=x, columns="Sexo",
                aggfunc='sum'
            ).fillna(0)

            pivot_pct = pivot.div(pivot.sum(axis=1), axis=0) * 100

            fig_pct = px.bar(
                pivot_pct, x=pivot_pct.index, y=pivot_pct.columns,
                title="% Participación PEA por género"
            )
        except:
            fig_pct = None

    return fig_group, fig_pct, df