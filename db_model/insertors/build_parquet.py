import json
import logging

import duckdb
import pandas as pd

from db_model.constants import ALGORITHM_PARQUET
from db_model.constants import DATASET_PARQUET
from db_model.constants import INFRASTRUCTURE_PARQUET
from db_model.constants import MEASURE_PARQUET
from db_model.constants import PARQUET_DIR
from db_model.constants import REPORT_PARQUET
from db_model.insertors.json_validator import validate
from db_model.insertors.parsers import parse_algorithms
from db_model.insertors.parsers import parse_datasets
from db_model.insertors.parsers import parse_infrastructure
from db_model.insertors.parsers import parse_measures
from db_model.insertors.parsers import parse_report

log = logging.getLogger(__name__)


def _load_json(path) -> dict | None:
    """
    Load a JSON file, returning None on parse errors.
    """
    try:
        return json.loads(path.read_text(encoding='utf-8'))
    except Exception as exc:
        log.warning('Skipping %s: %s', path.name, exc)
        return None


def _report_id(data: dict, path) -> str:
    """
    Resolve report_id from the JSON or fall back to filename stem.
    """
    return data.get('header', {}).get('reportId') or path.stem


def _write_parquet(rows: list, dest) -> None:
    """
    Write a list of SQLModel instances to a Parquet file via DuckDB.
    """
    pd.DataFrame([r.model_dump() for r in rows])
    duckdb.execute(f"COPY (SELECT * FROM df) TO '{dest}' (FORMAT PARQUET)")


def build(data_dir) -> None:
    """
    Read all JSON files from data_dir, validate each against the BoAmps JSON
    schema (skipping invalid reports), then write one Parquet file per table.
    """
    PARQUET_DIR.mkdir(parents=True, exist_ok=True)

    reports, measures, algorithms, datasets, infrastructure = [], [], [], [], []
    skipped = 0

    for path in sorted(data_dir.glob('*.json')):
        data = _load_json(path)
        if data is None:
            skipped += 1
            continue
        errors = validate(data)
        if errors:
            log.warning('Skipping %s — %d schema error(s): %s', path.name, len(errors), errors[0])
            skipped += 1
            continue
        rid = _report_id(data, path)
        reports.append(parse_report(rid, data))
        measures.extend(parse_measures(rid, data))
        algorithms.extend(parse_algorithms(rid, data))
        datasets.extend(parse_datasets(rid, data))
        infrastructure.extend(parse_infrastructure(rid, data))

    _write_parquet(reports, REPORT_PARQUET)
    _write_parquet(measures, MEASURE_PARQUET)
    _write_parquet(algorithms, ALGORITHM_PARQUET)
    _write_parquet(datasets, DATASET_PARQUET)
    _write_parquet(infrastructure, INFRASTRUCTURE_PARQUET)

    log.info(
        'Built %d reports | %d measures | %d algorithms | %d datasets | %d components | %d skipped',
        len(reports), len(measures), len(algorithms), len(datasets), len(infrastructure), skipped,
    )
