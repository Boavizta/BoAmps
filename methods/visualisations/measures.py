import plotly.express as px
from plotly.graph_objects import Figure

from db_model.retrievers.measures import get_measures


def plot_measures() -> Figure:
    """
    Scatter: power_consumption vs measurement_duration, color=measurement_method.
    """
    df = get_measures().dropna(subset=['power_consumption', 'measurement_duration'])
    fig = px.scatter(
        df,
        x='power_consumption',
        y='measurement_duration',
        color='measurement_method',
        title='Measures: power consumption vs duration',
        labels={'power_consumption': 'Power (kWh)', 'measurement_duration': 'Duration (s)'},
    )
    return fig
