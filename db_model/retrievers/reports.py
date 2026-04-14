from typing import Optional

import duckdb
import pandas as pd

from db_model.constants import (
    CONFIDENTIALITY_LEVEL, DATASET_PARQUET, INFRASTRUCTURE_PARQUET,
    INFRA_TYPE, MEASURE_PARQUET, PUBLISHER_NAME, QUALITY, REPORT_DATETIME,
    REPORT_PARQUET, REPORT_STATUS, TASK_FAMILY, TASK_STAGE,
)
from db_model.retrievers.utils import fetch_from_parquet


def get_reports(
    publisher_name: Optional[str] = None,
    task_stage: Optional[str] = None,
    task_family: Optional[str] = None,
    infra_type: Optional[str] = None,
    report_status: Optional[str] = None,
    quality: Optional[str] = None,
    confidentiality_level: Optional[str] = None,
) -> pd.DataFrame:
    """
    Return the report table with optional equality filters.
    """
    filters = {
        k: v for k, v in {
            PUBLISHER_NAME: publisher_name,
            TASK_STAGE: task_stage,
            TASK_FAMILY: task_family,
            INFRA_TYPE: infra_type,
            REPORT_STATUS: report_status,
            QUALITY: quality,
            CONFIDENTIALITY_LEVEL: confidentiality_level,
        }.items() if v is not None
    }
    return fetch_from_parquet(REPORT_PARQUET, filters)


def get_reports_by_date() -> pd.DataFrame:
    """
    Return report counts grouped by date (truncated from report_datetime).
    """
    query = f"""
        SELECT
            CAST(report_datetime AS DATE) AS report_date,
            COUNT(report_id)              AS report_count,
            publisher_name
        FROM read_parquet('{REPORT_PARQUET}')
        WHERE report_datetime IS NOT NULL
        GROUP BY report_date, publisher_name
        ORDER BY report_date
    """
    return duckdb.execute(query).df()


def get_reports_cross_table() -> pd.DataFrame:
    """
    Join report / dataset / measure / infrastructure (gpu only) on report_id.
    Returns one row per report with aggregated totals across tables.
    """
    query = f"""
        SELECT
            r.report_id,
            r.task_stage || ',' || r.task_family  AS task_label,
            SUM(d.data_quantity)                   AS total_data_quantity,
            SUM(m.power_consumption)               AS total_power_consumption,
            SUM(i.memory_size * i.nb_component)    AS total_gpu_memory
        FROM read_parquet('{REPORT_PARQUET}') r
        LEFT JOIN read_parquet('{DATASET_PARQUET}')         d USING (report_id)
        LEFT JOIN read_parquet('{MEASURE_PARQUET}')         m USING (report_id)
        LEFT JOIN read_parquet('{INFRASTRUCTURE_PARQUET}')  i
               ON i.report_id = r.report_id AND i.component_type = 'gpu'
        GROUP BY r.report_id, task_label
    """
    return duckdb.execute(query).df()


