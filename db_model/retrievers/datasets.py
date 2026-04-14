from typing import Optional

import pandas as pd

from db_model.constants import (
    DATA_TYPE, DATA_USAGE, DATASET_PARQUET, REPORT_ID, SOURCE,
)
from db_model.retrievers.utils import fetch_from_parquet


def get_datasets(
    report_id: Optional[str] = None,
    data_usage: Optional[str] = None,
    data_type: Optional[str] = None,
    source: Optional[str] = None,
) -> pd.DataFrame:
    """
    Return the dataset table with optional equality filters.
    """
    filters = {
        k: v for k, v in {
            REPORT_ID: report_id,
            DATA_USAGE: data_usage,
            DATA_TYPE: data_type,
            SOURCE: source,
        }.items() if v is not None
    }
    return fetch_from_parquet(DATASET_PARQUET, filters)
