import plotly.express as px
from plotly.graph_objects import Figure

from db_model.retrievers.algorithms import get_algorithms


def plot_algorithms() -> Figure:
    """
    Bubble scatter: framework vs parameters_number,
    size=count of reports, color=foundation_model_name.
    """
    df = get_algorithms().dropna(subset=['framework', 'parameters_number'])
    agg = (
        df.groupby(['framework', 'parameters_number', 'foundation_model_name'], dropna=False)
        .size()
        .reset_index(name='report_count')
    )
    fig = px.scatter(
        agg,
        x='framework',
        y='parameters_number',
        size='report_count',
        color='foundation_model_name',
        title='Algorithms: framework vs parameters',
        labels={'parameters_number': 'Parameters (B)', 'report_count': 'Reports'},
    )
    return fig
