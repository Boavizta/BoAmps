from enum import Enum


class ReportStatus(str, Enum):
    draft = 'draft'
    final = 'final'
    corrective = 'corrective'
    other = 'other'


class ConfidentialityLevel(str, Enum):
    public = 'public'
    internal = 'internal'
    confidential = 'confidential'
    secret = 'secret'


class Quality(str, Enum):
    high = 'high'
    medium = 'medium'
    low = 'low'


class DataUsage(str, Enum):
    input = 'input'
    output = 'output'


class DataType(str, Enum):
    tabular = 'tabular'
    audio = 'audio'
    boolean = 'boolean'
    image = 'image'
    video = 'video'
    object = 'object'
    text = 'text'
    token = 'token'
    word = 'word'
    other = 'other'


class DataSource(str, Enum):
    public = 'public'
    private = 'private'
    other = 'other'


class InfraType(str, Enum):
    publicCloud = 'publicCloud'
    privateCloud = 'privateCloud'
    onPremise = 'onPremise'
    other = 'other'


class PowerSupplierType(str, Enum):
    public = 'public'
    private = 'private'
    internal = 'internal'
    other = 'other'


class PowerSource(str, Enum):
    solar = 'solar'
    wind = 'wind'
    nuclear = 'nuclear'
    hydroelectric = 'hydroelectric'
    gas = 'gas'
    coal = 'coal'
    other = 'other'
