import pandas as pd
import json


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


# Example usage
with open('./examples/energy-report-llm-inference.json', 'r') as file:
    json_data = json.load(file)

flattened_data = flatten_json(json_data)
df = pd.DataFrame([flattened_data])
print(df)
df.to_csv('./examples/flattened_energy_report.csv', index=False)