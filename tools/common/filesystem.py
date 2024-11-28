import json

def open_json(path:str):
    with open(path) as e:
        return json.load(e)

