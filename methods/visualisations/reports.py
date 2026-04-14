import plotly.express as px
from plotly.graph_objects import Figure

from db_model.retrievers.reports import get_reports, get_reports_by_date, get_reports_cross_table


def plot_reports() -> Figure:
    """
    Horizontal bar: sum of nb_request per task_description, color=task_family.
    """
    df = get_reports().dropna(subset=["task_description", "nb_request"])
    agg = df.groupby(["task_description", "task_family"], dropna=False)["nb_request"].sum().reset_index()
    fig = px.bar(
        agg.sort_values("nb_request"),
        x="nb_request",
        y="task_description",
        color="task_family",
        orientation="h",
        title="Reports: total requests per task description",
        labels={"nb_request": "Total requests", "task_description": "Task description"},
        height=1000,
    )
    fig.update_xaxes(type='log')
    return fig


def plot_reports_over_time() -> Figure:
    """
    Line chart: number of reports per date.
    """
    df = get_reports_by_date()
    fig = px.bar(
        df,
        x="report_date",
        y="report_count",
        color="publisher_name",
        title="Reports submitted over time",
        labels={"report_date": "Date", "report_count": "Number of reports"},
    )
    return fig


def plot_reports_cross_table() -> Figure:
    """
    Bubble scatter across tables: total_data_quantity vs total_power_consumption, size=total_gpu_memory, color=task_label.
    """
    df = get_reports_cross_table().dropna(subset=["total_data_quantity", "total_power_consumption"])
    df["total_gpu_memory"] = df["total_gpu_memory"].fillna(0)
    fig = px.scatter(
        df,
        x="total_data_quantity",
        y="total_power_consumption",
        size="total_gpu_memory",
        color="task_label",
        title="Reports: data quantity vs power consumption (size = GPU memory)",
        labels={
            "total_data_quantity": "Total data quantity (tokens)",
            "total_power_consumption": "Total power (kWh)",
            "total_gpu_memory": "GPU memory (GB)",
        },
    )
    return fig
