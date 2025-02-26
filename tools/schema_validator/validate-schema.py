# Python program to validate json schema

from pathlib import Path
import json
import datetime
import sys
import jsonschema
from referencing import Registry, Resource
from jsonschema import Draft202012Validator, ValidationError
from referencing.exceptions import NoSuchResource


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

# Open json files


def open_json(path: str):
    e = open(path)
    jsonObj = json.load(e)
    e.close()
    return jsonObj


# Opening JSON file and create ressources for sub schemas
algo_sch = Resource.from_contents(
    open_json("../../model/algorithm_schema.json"))
data_sch = Resource.from_contents(open_json("../../model/dataset_schema.json"))
meas_sch = Resource.from_contents(open_json("../../model/measure_schema.json"))
hard_sch = Resource.from_contents(
    open_json("../../model/hardware_schema.json"))

# Creating a registry of all sub schema
registry = Registry().with_resources(
    [
        ("https://raw.githubusercontent.com/Boavizta/BoAmps/main/model/algorithm_schema.json", algo_sch),
        ("https://raw.githubusercontent.com/Boavizta/BoAmps/main/model/dataset_schema.json", data_sch),
        ("https://raw.githubusercontent.com/Boavizta/BoAmps/main/model/measure_schema.json", meas_sch),
        ("https://raw.githubusercontent.com/Boavizta/BoAmps/main/model/hardware_schema.json", hard_sch),
    ],

)

# Defining the usage of the tool


def Usage():
    print(f"{bcolors.FAIL}Error: Wrong number of arguments{bcolors.ENDC}")
    print("validate-schema is a tool to validate a json against BoAmps schema")
    print("Usage : ")
    print("      python3 validate-schema.py <JSON FILE to TEST>")
    print("      <JSON FILE to TEST> : json file to test")


# Check the param and get the files names for shcema and instance to test
if len(sys.argv) != 2:
    Usage()
    quit()

else:
    instance_FILENAME = str(sys.argv[1])
    print("FILENAME :", instance_FILENAME)

# Opening JSON Schema and JSON to test
schema = open_json("../../model/report_schema.json")
instance = open_json(instance_FILENAME)

# Creating the validator with the registry
validator = Draft202012Validator(schema, registry=registry,  # the critical argument, our registry from above
                                 )

# Validation of the json model
if (validator.is_valid(instance)):
    print(bcolors.OKGREEN, "Your report has the right format !", bcolors.ENDC)
else:
    print(bcolors.FAIL, "The json file does not correspond to the schema, there are ", sum(
        1 for x in validator.iter_errors(instance)), "errors :", bcolors.ENDC)
    errors = validator.iter_errors(instance)  # get all validation errors
    for err in errors:
        print("-------------------------------------------------")
        print("Error on data : ", err.json_path)
        print(bcolors.WARNING, " --> ", err.message, bcolors.ENDC)
    print("-------------------------------------------------")
