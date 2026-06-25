import math
from typing import Any

from db_model.constants import ALGORITHM_NAME
from db_model.constants import ALGORITHM_TYPE
from db_model.constants import ALGORITHM_URI
from db_model.constants import AVERAGE_UTILIZATION_CPU
from db_model.constants import AVERAGE_UTILIZATION_GPU
from db_model.constants import CLASS_PATH
from db_model.constants import CLOUD_INSTANCE
from db_model.constants import CLOUD_PROVIDER
from db_model.constants import CLOUD_SERVICE
from db_model.constants import COMPONENT_DESCRIPTION
from db_model.constants import COMPONENT_NAME
from db_model.constants import COMPONENT_TYPE
from db_model.constants import CONFIDENTIALITY_LEVEL
from db_model.constants import COUNTRY
from db_model.constants import CPU_TRACKING_MODE
from db_model.constants import DATA_FORMAT
from db_model.constants import DATA_QUANTITY
from db_model.constants import DATA_SIZE
from db_model.constants import DATA_TYPE
from db_model.constants import DATA_USAGE
from db_model.constants import DATASET_DESCRIPTION
from db_model.constants import DATASET_NAME
from db_model.constants import DISTRIBUTION
from db_model.constants import DISTRIBUTION_VERSION
from db_model.constants import DURATION_CALIBRATION_MEASUREMENT
from db_model.constants import EPOCHS_NUMBER
from db_model.constants import ESTIMATED_ACCURACY
from db_model.constants import FAMILY
from db_model.constants import FORMAT_VERSION
from db_model.constants import FORMAT_VERSION_SPECIFICATION_URI
from db_model.constants import FOUNDATION_MODEL_NAME
from db_model.constants import FOUNDATION_MODEL_URI
from db_model.constants import FRAMEWORK
from db_model.constants import FRAMEWORK_VERSION
from db_model.constants import GPU_TRACKING_MODE
from db_model.constants import INFRA_TYPE
from db_model.constants import LANGUAGE
from db_model.constants import LATITUDE
from db_model.constants import LAYERS_NUMBER
from db_model.constants import LICENSING
from db_model.constants import LOCATION
from db_model.constants import LONGITUDE
from db_model.constants import MANUFACTURER
from db_model.constants import MEASURED_ACCURACY
from db_model.constants import MEASUREMENT_DATETIME
from db_model.constants import MEASUREMENT_DURATION
from db_model.constants import MEASUREMENT_METHOD
from db_model.constants import MEMORY_SIZE
from db_model.constants import NB_COMPONENT
from db_model.constants import NB_REQUEST
from db_model.constants import OPTIMIZER
from db_model.constants import OS
from db_model.constants import OWNER
from db_model.constants import PARAMETERS_NUMBER
from db_model.constants import POWER_CALIBRATION_MEASUREMENT
from db_model.constants import POWER_CONSUMPTION
from db_model.constants import POWER_SOURCE
from db_model.constants import POWER_SOURCE_CARBON_INTENSITY
from db_model.constants import POWER_SUPPLIER_TYPE
from db_model.constants import PUBLISHER_DIVISION
from db_model.constants import PUBLISHER_NAME
from db_model.constants import PUBLISHER_PROJECT_NAME
from db_model.constants import QUALITY
from db_model.constants import QUANTIZATION
from db_model.constants import REPORT_DATETIME
from db_model.constants import REPORT_ID
from db_model.constants import REPORT_STATUS
from db_model.constants import SERIES
from db_model.constants import SHAPE
from db_model.constants import SHARE
from db_model.constants import SOFTWARE_VERSION
from db_model.constants import SOURCE
from db_model.constants import SOURCE_URI
from db_model.constants import TASK_DESCRIPTION
from db_model.constants import TASK_FAMILY
from db_model.constants import TASK_STAGE
from db_model.constants import TRAINING_TYPE
from db_model.constants import VERSION
from db_model.schema import AlgorithmRow
from db_model.schema import DatasetRow
from db_model.schema import InfrastructureRow
from db_model.schema import MeasureRow
from db_model.schema import ReportRow


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
    header = data.get('header', {})
    publisher = header.get('publisher', {})
    task = data.get('task', {})
    system = data.get('system', {})
    software = data.get('software', {})
    infra = data.get('infrastructure', {})
    env = data.get('environment', {})
    return ReportRow.model_validate({
        REPORT_ID: report_id,
        LICENSING: header.get('licensing'),
        FORMAT_VERSION: header.get('formatVersion'),
        FORMAT_VERSION_SPECIFICATION_URI: header.get('formatVersionSpecificationUri'),
        REPORT_DATETIME: header.get('reportDatetime'),
        REPORT_STATUS: header.get('reportStatus'),
        PUBLISHER_NAME: publisher.get('name'),
        PUBLISHER_DIVISION: publisher.get('division'),
        PUBLISHER_PROJECT_NAME: publisher.get('projectName'),
        CONFIDENTIALITY_LEVEL: publisher.get('confidentialityLevel'),
        TASK_STAGE: task.get('taskStage'),
        TASK_FAMILY: task.get('taskFamily'),
        NB_REQUEST: _clean(task.get('nbRequest')),
        MEASURED_ACCURACY: _clean(task.get('measuredAccuracy')),
        ESTIMATED_ACCURACY: task.get('estimatedAccuracy'),
        TASK_DESCRIPTION: task.get('taskDescription'),
        OS: system.get('os'),
        DISTRIBUTION: system.get('distribution'),
        DISTRIBUTION_VERSION: system.get('distributionVersion'),
        LANGUAGE: software.get('language'),
        SOFTWARE_VERSION: software.get('version'),
        INFRA_TYPE: infra.get('infraType'),
        CLOUD_PROVIDER: infra.get('cloudProvider'),
        CLOUD_INSTANCE: infra.get('cloudInstance'),
        CLOUD_SERVICE: infra.get('cloudService'),
        COUNTRY: env.get('country'),
        LATITUDE: _clean(env.get('latitude')),
        LONGITUDE: _clean(env.get('longitude')),
        LOCATION: env.get('location'),
        POWER_SUPPLIER_TYPE: env.get('powerSupplierType'),
        POWER_SOURCE: env.get('powerSource'),
        POWER_SOURCE_CARBON_INTENSITY: _clean(env.get('powerSourceCarbonIntensity')),
        QUALITY: data.get('quality'),
    })


def parse_measures(report_id: str, data: dict) -> list[MeasureRow]:
    """
    Extract one row per measure entry.
    """
    rows = []
    for m in data.get('measures', []):
        duration = m.get('measurementDuration') or m.get('duration')
        rows.append(MeasureRow.model_validate({
            REPORT_ID: report_id,
            MEASUREMENT_METHOD: m.get('measurementMethod'),
            MANUFACTURER: m.get('manufacturer'),
            VERSION: m.get('version'),
            CPU_TRACKING_MODE: m.get('cpuTrackingMode'),
            GPU_TRACKING_MODE: m.get('gpuTrackingMode'),
            AVERAGE_UTILIZATION_CPU: _clean(m.get('averageUtilizationCpu')),
            AVERAGE_UTILIZATION_GPU: _clean(m.get('averageUtilizationGpu')),
            POWER_CALIBRATION_MEASUREMENT: _clean(m.get('powerCalibrationMeasurement')),
            DURATION_CALIBRATION_MEASUREMENT: _clean(m.get('durationCalibrationMeasurement')),
            POWER_CONSUMPTION: _clean(m.get('powerConsumption')),
            MEASUREMENT_DURATION: _clean(duration),
            MEASUREMENT_DATETIME: m.get('measurementDateTime'),
        }))
    return rows


def parse_algorithms(report_id: str, data: dict) -> list[AlgorithmRow]:
    """
    Extract one row per algorithm entry.
    """
    rows = []
    for a in data.get('task', {}).get('algorithms', []):
        rows.append(AlgorithmRow.model_validate({
            REPORT_ID: report_id,
            TRAINING_TYPE: a.get('trainingType'),
            ALGORITHM_TYPE: a.get('algorithmType'),
            ALGORITHM_NAME: a.get('algorithmName'),
            ALGORITHM_URI: a.get('algorithmUri'),
            FOUNDATION_MODEL_NAME: a.get('foundationModelName'),
            FOUNDATION_MODEL_URI: a.get('foundationModelUri'),
            PARAMETERS_NUMBER: _clean(a.get('parametersNumber')),
            FRAMEWORK: a.get('framework'),
            FRAMEWORK_VERSION: a.get('frameworkVersion'),
            CLASS_PATH: a.get('classPath'),
            LAYERS_NUMBER: _clean(a.get('layersNumber')),
            EPOCHS_NUMBER: _clean(a.get('epochsNumber')),
            OPTIMIZER: a.get('optimizer'),
            QUANTIZATION: a.get('quantization'),
        }))
    return rows


def parse_datasets(report_id: str, data: dict) -> list[DatasetRow]:
    """
    Extract one row per dataset entry.
    """
    rows = []
    for d in data.get('task', {}).get('dataset', []):
        rows.append(DatasetRow.model_validate({
            REPORT_ID: report_id,
            DATA_USAGE: d.get('dataUsage'),
            DATA_TYPE: d.get('dataType'),
            DATA_FORMAT: d.get('dataFormat'),
            DATA_SIZE: _clean(d.get('dataSize')),
            DATA_QUANTITY: _clean(d.get('dataQuantity')),
            SHAPE: d.get('shape'),
            SOURCE: d.get('source'),
            SOURCE_URI: d.get('sourceUri'),
            OWNER: d.get('owner'),
            DATASET_NAME: d.get('datasetName'),
            DATASET_DESCRIPTION: d.get('datasetDescription'),
        }))
    return rows


def parse_infrastructure(report_id: str, data: dict) -> list[InfrastructureRow]:
    """
    Extract one row per hardware component entry.
    """
    rows = []
    for c in data.get('infrastructure', {}).get('components', []):
        rows.append(InfrastructureRow.model_validate({
            REPORT_ID: report_id,
            COMPONENT_NAME: c.get('componentName'),
            COMPONENT_TYPE: c.get('componentType'),
            NB_COMPONENT: c.get('nbComponent'),
            MEMORY_SIZE: _clean(c.get('memorySize')),
            MANUFACTURER: c.get('manufacturer'),
            FAMILY: c.get('family'),
            SERIES: c.get('series'),
            SHARE: _clean(c.get('share')),
            COMPONENT_DESCRIPTION: c.get('componentDescription'),
        }))
    return rows
