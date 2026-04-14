from typing import Optional

import pandas as pd

from db_model.constants import MEASURE_PARQUET
from db_model.constants import MEASUREMENT_METHOD
from db_model.constants import REPORT_ID
from db_model.retrievers.utils import fetch_from_parquet


def get_measures(
    report_id: Optional[str] = None,
    measurement_method: Optional[str] = None,
) -> pd.DataFrame:
    """
    Return the measure table with optional equality filters.
    """
    filters = {
        k: v for k, v in {
            REPORT_ID: report_id,
            MEASUREMENT_METHOD: measurement_method,
        }.items() if v is not None
    }
    return fetch_from_parquet(MEASURE_PARQUET, filters)
