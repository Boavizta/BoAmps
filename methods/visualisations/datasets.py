import plotly.express as px
from plotly.graph_objects import Figure

from db_model.retrievers.datasets import get_datasets


def plot_datasets(bucket_size: float = 1_000_000) -> Figure:
    """
    Histogram of data_quantity distribution bucketed by bucket_size, colored by data_type.
    """
    df = get_datasets().dropna(subset=['data_quantity'])
    fig = px.histogram(
        df,
        x='data_quantity',
        color='data_usage',
        nbins=max(1, int((df['data_quantity'].max() - df['data_quantity'].min()) / bucket_size)),
        title='Dataset data_quantity distribution',
        labels={'data_quantity': 'Data quantity', 'count': 'Reports'},
    )
    return fig
