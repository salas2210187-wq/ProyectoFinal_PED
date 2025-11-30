import streamlit as st
from sqlalchemy import create_engine
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from typing import Optional, Tuple

# ---------------------------
# CONFIG DB
# ---------------------------
DB_CONFIG = {
    "user": "root",
    "password": "Carro1406M.",
    "host": "localhost",
    "db": "Project_Final_Unemployment"
}

CONN_URI = f"mysql+mysqlconnector://{DB_CONFIG['user']}:{DB_CONFIG['password']}@{DB_CONFIG['host']}/{DB_CONFIG['db']}"

# ---------------------------
# VISTAS
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
# Conector
# ---------------------------
@st.cache_resource
def get_engine():
    engine = create_engine(CONN_URI)
    return engine

# ---------------------------
# Cargar vista a DataFrame
# ---------------------------
@st.cache_data
def load_view_df(view_name: str) -> Optional[pd.DataFrame]:
    engine = get_engine()
    query = f"SELECT * FROM {view_name};"
    try:
        df = pd.read_sql(query, engine)
        # Normalizar nombres
        df.columns = [c.strip() for c in df.columns]
        return df
    except Exception as e:
        st.error(f"Error cargando {view_name}: {e}")
        return None

# ---------------------------
# Detectar columna año/trimestre
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
# KPIs: calcula indicadores según columnas
# ---------------------------
def compute_kpis_resumen(df: pd.DataFrame) -> Tuple[dict, pd.DataFrame]:
    kpis = {}
    if df is None or df.empty:
        return kpis, df
    year_col = detect_year_column(df) or df.columns[0]
    # ordenar por año
    try:
        df_sorted = df.sort_values(by=year_col)
    except Exception:
        df_sorted = df.copy()
    last = df_sorted.iloc[-1]
    # Acceso
    def safe_get(row, candidates):
        for c in candidates:
            if c in row.index:
                return row[c]
        return None
    kpis["Último año"] = last.get(year_col, "")
    kpis["Total desocupados (2025 Q1)"] = safe_get(last, ["Total_Desocupados_Acumulado", "total_unemployed_count", "Total_Desocupados_Acumulado"])
    kpis["% Tasa desempleo (2025 Q1)"] = safe_get(last, ["Tasa_Desempleo_Promedio_Anual", "Tasa_Desocupacion_Porc"])
    return kpis, df_sorted

# ---------------------------
# GRÁFICAS POR VISTA
# ---------------------------
def charts_resumen_anual():
    df = load_view_df("Vista_Resumen_Anual")
    if df is None:
        return None, None, None
    year_col = detect_year_column(df) or "Año"
    # Line: tasa
    if "Tasa_Desempleo_Promedio_Anual" in df.columns:
        fig_line = px.line(df, x=year_col, y="Tasa_Desempleo_Promedio_Anual",
                           markers=True, title="Tasa de Desempleo Promedio Anual")
    else:
        fig_line = None
    # Bar: total desocupados
    if "Total_Desocupados_Acumulado" in df.columns:
        fig_bar = px.bar(df, x=year_col, y="Total_Desocupados_Acumulado",
                         title="Total de Desocupados Acumulado por Año")
    else:
        fig_bar = None
    # KPI data
    kpis, df_sorted = compute_kpis_resumen(df)
    return fig_line, fig_bar, df_sorted, kpis

def charts_evolucion_desempleo_general():
    df = load_view_df("Vista_Evolucion_Desempleo_General")
    if df is None:
        return None, None, None
    x = "ID_Periodo" if "ID_Periodo" in df.columns else detect_year_column(df) or "Periodo_Trimestre"
    fig_dual = None
    if "Tasa_Desocupacion_Porc" in df.columns and "Tasa_Ocupacion_Porc" in df.columns:
        fig_dual = go.Figure()
        fig_dual.add_trace(go.Scatter(x=df[x], y=df["Tasa_Desocupacion_Porc"], mode="lines+markers", name="Tasa Desocupación (%)"))
        fig_dual.add_trace(go.Scatter(x=df[x], y=df["Tasa_Ocupacion_Porc"], mode="lines+markers", name="Tasa Ocupación (%)"))
        fig_dual.update_layout(title="Tasa de Desocupación vs Ocupación (%)")
    if "Desocupados_Total" in df.columns and "Ocupados_Total" in df.columns:
        fig_area = go.Figure()
        fig_area.add_trace(go.Scatter(x=df[x], y=df["Ocupados_Total"], stackgroup='one', name="Ocupados"))
        fig_area.add_trace(go.Scatter(x=df[x], y=df["Desocupados_Total"], stackgroup='one', name="Desocupados"))
        fig_area.update_layout(title="Ocupados vs Desocupados")
    else:
        fig_area = None
    return fig_dual, fig_area, df

def charts_brecha_salarial():
    df = load_view_df("Vista_Brecha_Salarial")
    if df is None:
        return None, None, None
    x = detect_year_column(df) or "Año"
    fig_mirror = None
    if "Salario_Hombres" in df.columns and "Salario_Mujeres" in df.columns:
        fig_mirror = go.Figure()
        fig_mirror.add_trace(go.Bar(x=df[x], y=df["Salario_Hombres"], name="Hombres"))
        fig_mirror.add_trace(go.Bar(x=df[x], y=df["Salario_Mujeres"], name="Mujeres"))
        fig_mirror.update_layout(barmode='group', title="Salario promedio: Hombres vs Mujeres")
    fig_gap = None
    if "Diferencia_Salarial" in df.columns:
        fig_gap = px.line(df, x=x, y="Diferencia_Salarial", title="Diferencia Salarial (H - M) en pesos", markers=True)
    return fig_mirror, fig_gap, df

def charts_salario_por_genero():
    df = load_view_df("Vista_Salario_Por_Genero")
    if df is None:
        return None, None, None
    x = "Periodo_Trimestre" if "Periodo_Trimestre" in df.columns else detect_quarter_column(df) or detect_year_column(df)
    if "Salario_Promedio_Mensual" in df.columns and "Sexo" in df.columns:
        fig_line = px.line(df, x=x, y="Salario_Promedio_Mensual", color="Sexo",
                           title="Salario Promedio Mensual por Género", markers=True)
        try:
            pivot = df.pivot_table(values="Salario_Promedio_Mensual", index=x, columns="Sexo")
            fig_heat = px.imshow(pivot.T, labels=dict(x=x, y="Sexo", color="Salario"),
                                 x=pivot.index, y=pivot.columns, title="Mapa de calor: Salario por periodo y sexo")
        except Exception:
            fig_heat = None
    else:
        fig_line = None
        fig_heat = None
    return fig_line, fig_heat, df

def charts_salario_por_formalidad():
    df = load_view_df("Vista_Salario_Por_Formalidad")
    if df is None:
        return None, None, None
    x = "Periodo_Trimestre" if "Periodo_Trimestre" in df.columns else detect_quarter_column(df)
    if "Salario_Promedio_Mensual" in df.columns and "Clasificacion" in df.columns:
        fig_group = px.bar(df, x=x, y="Salario_Promedio_Mensual", color="Clasificacion",
                           barmode='group', title="Salario promedio por formalidad")
        fig_line = px.line(df, x=x, y="Salario_Promedio_Mensual", color="Clasificacion",
                           title="Tendencia de salario por formalidad", markers=True)
    else:
        fig_group = None
        fig_line = None
    return fig_group, fig_line, df

def charts_composicion_formalidad():
    df = load_view_df("Vista_Composicion_Formalidad")
    if df is None:
        return None, None, None
    if "Tipo_Empleo" in df.columns and "Cantidad_Trabajadores" in df.columns:
        last_period = df.iloc[-1].get("Periodo", None) if "Periodo" in df.columns else None
        fig_donut = px.pie(df, names="Tipo_Empleo", values="Cantidad_Trabajadores", hole=0.45,
                           title=f"Composición Formalidad ({last_period})")
        try:
            pivot = df.pivot_table(values="Cantidad_Trabajadores", index="Periodo", columns="Tipo_Empleo", aggfunc='sum').fillna(0)
            fig_stack = px.bar(pivot, x=pivot.index, y=pivot.columns, title="Evolución por formalidad")
        except Exception:
            fig_stack = None
    else:
        fig_donut = None
        fig_stack = None
    return fig_donut, fig_stack, df

def charts_desbalance_genero_pea():
    df = load_view_df("Vista_Desbalance_Genero_PEA")
    if df is None:
        return None, None, None
    x = "Periodo_Trimestre" if "Periodo_Trimestre" in df.columns else detect_quarter_column(df) or detect_year_column(df)
    if "Sexo" in df.columns and "PEA_Estimada_Total" in df.columns:
        fig_group = px.bar(df, x=x, y="PEA_Estimada_Total", color="Sexo", barmode='group',
                           title="PEA estimada por género")
        try:
            pivot = df.pivot_table(values="PEA_Estimada_Total", index=x, columns="Sexo", aggfunc='sum').fillna(0)
            pivot_pct = pivot.div(pivot.sum(axis=1), axis=0) * 100
            fig_pct = px.bar(pivot_pct, x=pivot_pct.index, y=pivot_pct.columns, title="% Participación PEA por género")
        except Exception:
            fig_pct = None
    else:
        fig_group = None
        fig_pct = None
    return fig_group, fig_pct, df

# ---------------------------
# Barra lateral
# ---------------------------
def sidebar_controls(global_state):
    st.sidebar.title("Controles de Resumen para tablas")
    st.sidebar.markdown("Filtros")
    all_years = set()
    for v in VIEWS:
        df = load_view_df(v)
        if df is not None:
            yc = detect_year_column(df)
            if yc and yc in df.columns:
                try:
                    all_years.update(df[yc].dropna().astype(int).unique().tolist())
                except Exception:
                    all_years.update(df[yc].dropna().unique().tolist())
    years_sorted = sorted(list(all_years))
    if years_sorted:
        year_sel = st.sidebar.selectbox("Años", options=["Todos"] + years_sorted, index=len(years_sorted))
        global_state["year"] = None if year_sel == "Todos" else year_sel
    else:
        global_state["year"] = None

    st.sidebar.markdown("---")
    st.sidebar.checkbox("Mostrar tabla de datos para las secciones", value=True, key="show_table")

# ---------------------------
# Aplicar filtros globales
# ---------------------------
def apply_global_filters(df: pd.DataFrame, global_state: dict) -> pd.DataFrame:
    if df is None:
        return df
    df2 = df.copy()
    y = global_state.get("year")
    q = global_state.get("quarter")
    if y is not None:
        yc = detect_year_column(df2)
        if yc and yc in df2.columns:
            try:
                df2 = df2[df2[yc].astype(str) == str(y)]
            except Exception:
                pass
    if q is not None:
        qc = detect_quarter_column(df2)
        if qc and qc in df2.columns:
            df2 = df2[df2[qc].astype(str).str.contains(q)]
    return df2

# ---------------------------
# Mostrar KPIs
# ---------------------------
def show_kpi_row(kpis: dict):
    if not kpis:
        return
    cols = st.columns(len(kpis))
    i = 0
    for k, v in kpis.items():
        cols[i].metric(k, str(v))
        i += 1
