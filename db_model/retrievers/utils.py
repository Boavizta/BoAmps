from pathlib import Path

import duckdb
import pandas as pd


def fetch_from_parquet(parquet: Path, filters: dict) -> pd.DataFrame:
    """
    Build and execute a simple equality-filtered query on a Parquet file.
    """
    clauses = " AND ".join(f"{k} = ?" for k in filters)
    where = f" WHERE {clauses}" if clauses else ""
    query = f"SELECT * FROM read_parquet('{parquet}'){where}"
    return duckdb.execute(query, list(filters.values())).df()


def to_csv(df: pd.DataFrame, dest: Path) -> None:
    """
    Write DataFrame to CSV without index.
    """
    df.to_csv(dest, index=False)


def export_to_csv(getter, dest: Path, **filters) -> None:
    """
    Export the result of a retriever function to CSV.

    `getter` is a callable that accepts keyword filters and returns a DataFrame.
    Possible values for 'getter' are the get_ methods defined elsewhere in db_model/retrievers.
    """
    df = getter(**filters)
    to_csv(df, dest)

