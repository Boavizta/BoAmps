from typing import Optional

import pandas as pd

from db_model.constants import COMPONENT_TYPE
from db_model.constants import INFRASTRUCTURE_PARQUET
from db_model.constants import MANUFACTURER
from db_model.constants import REPORT_ID
from db_model.retrievers.utils import fetch_from_parquet


def get_infrastructure(
    report_id: Optional[str] = None,
    component_type: Optional[str] = None,
    manufacturer: Optional[str] = None,
) -> pd.DataFrame:
    """
    Return the infrastructure table with optional equality filters.
    """
    filters = {
        k: v for k, v in {
            REPORT_ID: report_id,
            COMPONENT_TYPE: component_type,
            MANUFACTURER: manufacturer,
        }.items() if v is not None
    }
    return fetch_from_parquet(INFRASTRUCTURE_PARQUET, filters)
