# Python program to validate json schema

from pathlib import Path
import json
import datetime
import jsonschema
from referencing import Registry, Resource
from jsonschema import Draft202012Validator, ValidationError
from referencing.exceptions import NoSuchResource
import sys, getopt, os
import shutil

def open_json(path: str):
    e = open(path)
    jsonObj = json.load(e)
    e.close()
    return jsonObj

# Opening JSON file and create ressources for sub schemas
algo_sch = Resource.from_contents(open_json("../../model/algorithm_schema.json"))
data_sch = Resource.from_contents(open_json("../../model/dataset_schema.json"))
meas_sch = Resource.from_contents(open_json("../../model/measure_schema.json"))
hard_sch = Resource.from_contents(open_json("../../model/hardware_schema.json"))
infe_sch = Resource.from_contents(open_json("../../model/inference_schema.json"))

# Creating a registry of all sub schema
registry = Registry().with_resources([
    ("https://raw.githubusercontent.com/Boavizta/ai-power-measures-sharing/main/model/algorithm_schema.json", algo_sch),
    ("https://raw.githubusercontent.com/Boavizta/ai-power-measures-sharing/main/model/dataset_schema.json", data_sch),
    ("https://raw.githubusercontent.com/Boavizta/ai-power-measures-sharing/main/model/measure_schema.json", meas_sch),
    ("https://raw.githubusercontent.com/Boavizta/ai-power-measures-sharing/main/model/hardware_schema.json", hard_sch),
    ("https://raw.githubusercontent.com/Boavizta/ai-power-measures-sharing/main/model/inference_schema.json", infe_sch)
])


def main(argv):

    # params
    mode = None     # records are in a file or in a document db (mongo)
    filename = None # file path to json file, if mode=file
    target = None   # target output format

    # handle CLI parameters
    try:
        opts, args = getopt.getopt(argv,'hm:f:t:', ['help', 'mode=', 'filename=', 'target='])
    except getopt.GetoptError as err:
        sys.exit(1)
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            print('Help will come soon.')
            sys.exit(0)
        elif opt in ('-m', '--mode'):
            mode = arg
        elif opt in ('-f', '--filename'):
            filename = arg
        elif opt in ('-t', '--target'):
            target = arg
               

    # Opening JSON Schema and JSON to test
    if filename is not None:
        schema = open_json("../../model/report_schema.json")
        instance = open_json(filename)
        validator = Draft202012Validator(schema, registry=registry)

        if (validator.is_valid(instance)):
            pass # conversion will happen here
        else:
            print('Invalid object. Aborted.')

if __name__ == '__main__':
    main(sys.argv[1:])
