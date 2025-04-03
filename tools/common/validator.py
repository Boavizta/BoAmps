##############################################################
# BoAmps - an open-data initiative hosted by Boavizta        #
# (A)I (M)easures of (P)ower consumption (S)haring           #
##############################################################

# Python program to validate json schema

import os
from referencing import Registry, Resource
from jsonschema import Draft202012Validator
from .filesystem import open_json

URL_PREFIX = 'https://raw.githubusercontent.com/Boavizta/ai-power-measures-sharing/main/model/'
FILE_SUFFIX = '_schema.json'
MODEL_LOCAL_PATH = os.sep.join(['..', 'model', ''])
REPORT = 'report'
RESOURCES = ['algorithm', 'dataset', 'measure', 'hardware']


class BoAmpsValidator(Draft202012Validator):

    def __init__(self, *args, **kwargs):

        schema = open_json(''.join([MODEL_LOCAL_PATH, REPORT, FILE_SUFFIX]))
        registry = Registry().with_resources(pairs=[
            (
                ''.join([URL_PREFIX, resource, FILE_SUFFIX]),
                Resource.from_contents(
                    open_json(''.join([MODEL_LOCAL_PATH, resource, FILE_SUFFIX])))
            ) for resource in RESOURCES
        ])
        super().__init__(schema=schema, registry=registry)
