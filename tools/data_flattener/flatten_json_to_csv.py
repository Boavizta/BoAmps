import pandas as pd
import json
import sys


class bcolors:
    FAIL = '\033[91m'
    ENDC = '\033[0m'

# Open json files


def open_json(path: str):
    e = open(path)
    jsonObj = json.load(e)
    e.close()
    return jsonObj


def flatten_json(y):
    out = {}

    def flatten(x, name=''):
        if type(x) is dict:
            for a in x:
                flatten(x[a], name + a + '_')
        elif type(x) is list:
            i = 0
            for a in x:
                flatten(a, name + str(i) + '_')
                i += 1
        else:
            out[name[:-1]] = x

    flatten(y)
    return out

# Defining the usage of the tool


def Usage():
    print(f"{bcolors.FAIL}Error: Wrong number of arguments{bcolors.ENDC}")
    print("flatenning script to transform a json file to a csv")
    print("Usage : ")
    print("python flatten_json_to_csv.py <JSON FILE to transform> <path+filename of the CSV to create")


# Check the params and get the json file name
if len(sys.argv) != 3:
    Usage()
    quit()

else:
    json_FILENAME = str(sys.argv[1])

# Opening JSON Schema and JSON to test
json_data = open_json(json_FILENAME)

flattened_data = flatten_json(json_data)
df = pd.DataFrame([flattened_data])
print(df)
df.to_csv(str(sys.argv[2]), index=False)
