from typing import Optional

import pandas as pd

from db_model.constants import ALGORITHM_PARQUET
from db_model.constants import ALGORITHM_TYPE
from db_model.constants import FOUNDATION_MODEL_NAME
from db_model.constants import FRAMEWORK
from db_model.constants import QUANTIZATION
from db_model.constants import REPORT_ID
from db_model.retrievers.utils import fetch_from_parquet


def get_algorithms(
    report_id: Optional[str] = None,
    algorithm_type: Optional[str] = None,
    foundation_model_name: Optional[str] = None,
    framework: Optional[str] = None,
    quantization: Optional[str] = None,
) -> pd.DataFrame:
    """
    Return the algorithm table with optional equality filters.
    """
    filters = {
        k: v for k, v in {
            REPORT_ID: report_id,
            ALGORITHM_TYPE: algorithm_type,
            FOUNDATION_MODEL_NAME: foundation_model_name,
            FRAMEWORK: framework,
            QUANTIZATION: quantization,
        }.items() if v is not None
    }
    return fetch_from_parquet(ALGORITHM_PARQUET, filters)
