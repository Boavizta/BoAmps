import plotly.graph_objects as go
from plotly.subplots import make_subplots

from db_model.retrievers.infrastructure import get_infrastructure


def plot_infrastructure() -> go.Figure:
    """
    Horizontal bar subplots (one per component_type): manufacturer vs nb_component, colored by memory_size.
    """
    df = get_infrastructure()
    grouped = df.groupby(["component_type", "manufacturer", "memory_size"], dropna=False)["nb_component"].sum().reset_index()
    types = sorted(grouped["component_type"].dropna().unique())

    fig = make_subplots(cols=1, rows=len(types), subplot_titles=types, shared_yaxes=True)
    for row, ctype in enumerate(types, start=1):
        sub = grouped[grouped["component_type"] == ctype].sort_values("nb_component")
        fig.add_trace(
            go.Bar(
                x=sub["nb_component"],
                y=sub["manufacturer"].fillna("unknown"),
                orientation="h",
                marker=dict(color=sub["memory_size"], colorscale="Viridis", showscale=(row == len(types))),
                name=ctype,
                showlegend=False,
            ),
            row=row, col=1,
        )
    fig.update_layout(title="Infrastructure components by type", height=600)
    return fig
