import math
from typing import Any

from db_model.constants import (
    ALGORITHM_NAME, ALGORITHM_TYPE, ALGORITHM_URI, AVERAGE_UTILIZATION_CPU,
    AVERAGE_UTILIZATION_GPU, CLASS_PATH, CLOUD_INSTANCE, CLOUD_PROVIDER,
    CLOUD_SERVICE, COMPONENT_DESCRIPTION, COMPONENT_NAME, COMPONENT_TYPE,
    CONFIDENTIALITY_LEVEL, COUNTRY, CPU_TRACKING_MODE, DATA_FORMAT,
    DATA_QUANTITY, DATA_SIZE, DATA_TYPE, DATA_USAGE, DATASET_DESCRIPTION,
    DATASET_NAME, DISTRIBUTION, DISTRIBUTION_VERSION, DURATION_CALIBRATION_MEASUREMENT,
    EPOCHS_NUMBER, ESTIMATED_ACCURACY, FAMILY, FORMAT_VERSION,
    FORMAT_VERSION_SPECIFICATION_URI, FOUNDATION_MODEL_NAME, FOUNDATION_MODEL_URI,
    FRAMEWORK, FRAMEWORK_VERSION, GPU_TRACKING_MODE, INFRA_TYPE, LANGUAGE,
    LATITUDE, LAYERS_NUMBER, LICENSING, LOCATION, LONGITUDE, MANUFACTURER,
    MEASURED_ACCURACY, MEASUREMENT_DATETIME, MEASUREMENT_DURATION,
    MEASUREMENT_METHOD, MEMORY_SIZE, NB_COMPONENT, NB_REQUEST, OPTIMIZER, OS,
    OWNER, PARAMETERS_NUMBER, POWER_CALIBRATION_MEASUREMENT, POWER_CONSUMPTION,
    POWER_SOURCE, POWER_SOURCE_CARBON_INTENSITY, POWER_SUPPLIER_TYPE,
    PUBLISHER_DIVISION, PUBLISHER_NAME, PUBLISHER_PROJECT_NAME, QUALITY,
    QUANTIZATION, REPORT_DATETIME, REPORT_ID, REPORT_STATUS, SERIES, SHARE,
    SHAPE, SOFTWARE_VERSION, SOURCE, SOURCE_URI, TASK_DESCRIPTION, TASK_FAMILY,
    TASK_STAGE, TRAINING_TYPE, VERSION,
)
from db_model.schema import AlgorithmRow, DatasetRow, InfrastructureRow, MeasureRow, ReportRow


def _clean(value: Any) -> Any:
    """
    Return None for NaN floats, pass everything else through.
    """
    if isinstance(value, float) and math.isnan(value):
        return None
    return value


def parse_report(report_id: str, data: dict) -> ReportRow:
    """
    Extract a single flat report row from a JSON report dict.
    """
    header = data.get("header", {})
    publisher = header.get("publisher", {})
    task = data.get("task", {})
    system = data.get("system", {})
    software = data.get("software", {})
    infra = data.get("infrastructure", {})
    env = data.get("environment", {})
    return ReportRow.model_validate({
        REPORT_ID: report_id,
        LICENSING: header.get("licensing"),
        FORMAT_VERSION: header.get("formatVersion"),
        FORMAT_VERSION_SPECIFICATION_URI: header.get("formatVersionSpecificationUri"),
        REPORT_DATETIME: header.get("reportDatetime"),
        REPORT_STATUS: header.get("reportStatus"),
        PUBLISHER_NAME: publisher.get("name"),
        PUBLISHER_DIVISION: publisher.get("division"),
        PUBLISHER_PROJECT_NAME: publisher.get("projectName"),
        CONFIDENTIALITY_LEVEL: publisher.get("confidentialityLevel"),
        TASK_STAGE: task.get("taskStage"),
        TASK_FAMILY: task.get("taskFamily"),
        NB_REQUEST: _clean(task.get("nbRequest")),
        MEASURED_ACCURACY: _clean(task.get("measuredAccuracy")),
        ESTIMATED_ACCURACY: task.get("estimatedAccuracy"),
        TASK_DESCRIPTION: task.get("taskDescription"),
        OS: system.get("os"),
        DISTRIBUTION: system.get("distribution"),
        DISTRIBUTION_VERSION: system.get("distributionVersion"),
        LANGUAGE: software.get("language"),
        SOFTWARE_VERSION: software.get("version"),
        INFRA_TYPE: infra.get("infraType"),
        CLOUD_PROVIDER: infra.get("cloudProvider"),
        CLOUD_INSTANCE: infra.get("cloudInstance"),
        CLOUD_SERVICE: infra.get("cloudService"),
        COUNTRY: env.get("country"),
        LATITUDE: _clean(env.get("latitude")),
        LONGITUDE: _clean(env.get("longitude")),
        LOCATION: env.get("location"),
        POWER_SUPPLIER_TYPE: env.get("powerSupplierType"),
        POWER_SOURCE: env.get("powerSource"),
        POWER_SOURCE_CARBON_INTENSITY: _clean(env.get("powerSourceCarbonIntensity")),
        QUALITY: data.get("quality"),
    })


def parse_measures(report_id: str, data: dict) -> list[MeasureRow]:
    """
    Extract one row per measure entry.
    """
    rows = []
    for m in data.get("measures", []):
        duration = m.get("measurementDuration") or m.get("duration")
        rows.append(MeasureRow.model_validate({
            REPORT_ID: report_id,
            MEASUREMENT_METHOD: m.get("measurementMethod"),
            MANUFACTURER: m.get("manufacturer"),
            VERSION: m.get("version"),
            CPU_TRACKING_MODE: m.get("cpuTrackingMode"),
            GPU_TRACKING_MODE: m.get("gpuTrackingMode"),
            AVERAGE_UTILIZATION_CPU: _clean(m.get("averageUtilizationCpu")),
            AVERAGE_UTILIZATION_GPU: _clean(m.get("averageUtilizationGpu")),
            POWER_CALIBRATION_MEASUREMENT: _clean(m.get("powerCalibrationMeasurement")),
            DURATION_CALIBRATION_MEASUREMENT: _clean(m.get("durationCalibrationMeasurement")),
            POWER_CONSUMPTION: _clean(m.get("powerConsumption")),
            MEASUREMENT_DURATION: _clean(duration),
            MEASUREMENT_DATETIME: m.get("measurementDateTime"),
        }))
    return rows


def parse_algorithms(report_id: str, data: dict) -> list[AlgorithmRow]:
    """
    Extract one row per algorithm entry.
    """
    rows = []
    for a in data.get("task", {}).get("algorithms", []):
        rows.append(AlgorithmRow.model_validate({
            REPORT_ID: report_id,
            TRAINING_TYPE: a.get("trainingType"),
            ALGORITHM_TYPE: a.get("algorithmType"),
            ALGORITHM_NAME: a.get("algorithmName"),
            ALGORITHM_URI: a.get("algorithmUri"),
            FOUNDATION_MODEL_NAME: a.get("foundationModelName"),
            FOUNDATION_MODEL_URI: a.get("foundationModelUri"),
            PARAMETERS_NUMBER: _clean(a.get("parametersNumber")),
            FRAMEWORK: a.get("framework"),
            FRAMEWORK_VERSION: a.get("frameworkVersion"),
            CLASS_PATH: a.get("classPath"),
            LAYERS_NUMBER: _clean(a.get("layersNumber")),
            EPOCHS_NUMBER: _clean(a.get("epochsNumber")),
            OPTIMIZER: a.get("optimizer"),
            QUANTIZATION: a.get("quantization"),
        }))
    return rows


def parse_datasets(report_id: str, data: dict) -> list[DatasetRow]:
    """
    Extract one row per dataset entry.
    """
    rows = []
    for d in data.get("task", {}).get("dataset", []):
        rows.append(DatasetRow.model_validate({
            REPORT_ID: report_id,
            DATA_USAGE: d.get("dataUsage"),
            DATA_TYPE: d.get("dataType"),
            DATA_FORMAT: d.get("dataFormat"),
            DATA_SIZE: _clean(d.get("dataSize")),
            DATA_QUANTITY: _clean(d.get("dataQuantity")),
            SHAPE: d.get("shape"),
            SOURCE: d.get("source"),
            SOURCE_URI: d.get("sourceUri"),
            OWNER: d.get("owner"),
            DATASET_NAME: d.get("datasetName"),
            DATASET_DESCRIPTION: d.get("datasetDescription"),
        }))
    return rows


def parse_infrastructure(report_id: str, data: dict) -> list[InfrastructureRow]:
    """
    Extract one row per hardware component entry.
    """
    rows = []
    for c in data.get("infrastructure", {}).get("components", []):
        rows.append(InfrastructureRow.model_validate({
            REPORT_ID: report_id,
            COMPONENT_NAME: c.get("componentName"),
            COMPONENT_TYPE: c.get("componentType"),
            NB_COMPONENT: c.get("nbComponent"),
            MEMORY_SIZE: _clean(c.get("memorySize")),
            MANUFACTURER: c.get("manufacturer"),
            FAMILY: c.get("family"),
            SERIES: c.get("series"),
            SHARE: _clean(c.get("share")),
            COMPONENT_DESCRIPTION: c.get("componentDescription"),
        }))
    return rows
