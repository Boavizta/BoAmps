import json
from functools import lru_cache
from pathlib import Path

from jsonschema import Draft4Validator
from referencing import Registry, Resource

MODEL_DIR = Path(__file__).parents[2] / "model"

_SUB_SCHEMA_FILES = [
    MODEL_DIR / "algorithm_schema.json",
    MODEL_DIR / "dataset_schema.json",
    MODEL_DIR / "measure_schema.json",
    MODEL_DIR / "hardware_schema.json",
]
_REPORT_SCHEMA_FILE = MODEL_DIR / "report_schema.json"


@lru_cache(maxsize=1)
def _build_validator() -> Draft4Validator:
    """
    Build and cache the jsonschema validator with a local sub-schema registry.
    Registry keys are read from each schema's own 'id' field so they match
    the $ref values in report_schema.json without hardcoding URLs.
    """
    resources = []
    for path in _SUB_SCHEMA_FILES:
        contents = json.loads(path.read_text())
        resources.append((contents["id"], Resource.from_contents(contents)))
    registry = Registry().with_resources(resources)
    schema = json.loads(_REPORT_SCHEMA_FILE.read_text())
    return Draft4Validator(schema, registry=registry)


def validate(data: dict) -> list[str]:
    """
    Validate a report dict against the BoAmps JSON schema.
    Returns a list of error messages; empty list means valid.
    """
    validator = _build_validator()
    return [err.message for err in validator.iter_errors(data)]
