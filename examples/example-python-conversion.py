# THIS SCRIPT CAN NOT BE EXECUTED AS IS,
# It is meant to be integrated in a program or notebook where you have a dataframe (polars or pandas) containing your energy data. Each row of the dataframe should correspond to one report.

import json
import datetime
import polars # Can work with pandas
import os

###
# Functions for every section of the report
# The static fields of the reports should be adapted to your measures (e.g. organization,
###

def make_header():  
    return {  
        "licensing": "Creative Commons 4.0",  
        "formatVersion": "0.1",  
        "reportId": f"{datetime.datetime.now().isoformat()}-{str(uuid.uuid4())}",  
        "reportStatus": "final",  # draft, final, corrective, other  
        "reportDatetime": datetime.datetime.now().isoformat(),  
        "publisher": {  
            "name": "Inria",
            "confidentialityLevel": "public",  
        },  
    }  
  
  
def make_algorithm(row): 
    return {  
        "algorithmType": "llm",  
        "foundationModelName": row["model"],  
        "framework": "vllm",  
        "frameworkVersion": "0.7.3",  
        "parametersNumber": row["parameters"],  
    }  
  
  
def make_dataset(row):  
    input = {  
        "dataUsage": "input",  
        "dataType": "token",  
        "dataQuantity": row["prompt_tokens"],  
        "source": "public",  
        "sourceUri": "https://huggingface.co/datasets/evalplus/evalperf",  
        "owner": "evalplus",  
    }  
    output = {  
        "dataUsage": "output",  
        "dataType": "token",  
        "dataQuantity": row["output_tokens"],  
        "source": "public",  
        "sourceUri": "https://huggingface.co/datasets/evalplus/evalperf",  
        "owner": "evalplus",  
    }  
    return [input, output]  
  
  
def make_task(row):  
    if row["iteration"] == 0:  
        description = "Code generation from EvalPerf prompts"  
    elif row["iteration"] > 0:  
        description = "Code optimization"  
    else:  
        raise Error("Incorrect iteration")  
  
    description += " - Continuous batching"  
    return {  
        "taskStage": "inference",  
        "taskFamily": "code generation",  
        "nbRequest": row["nb_requests"],  
        "algorithms": [make_algorithm(row)],  
        "dataset": make_dataset(row),  
        "taskDescription": description,  
    }  
  
  
def j_to_kwh(j):  
    return j / 3600 / 1000  
  
  
def make_measures(row):  
    return [  
        {  
            "measurementMethod": "perf",  
            "version": "5.10.237",  
            "cpuTrackingMode": "rapl",  
            "powerCalibrationMeasurement": j_to_kwh(row["energy_idle_cpu"]),  
            "durationCalibrationMeasurement": row["idle_time"],  
            "powerConsumption": j_to_kwh(row["energy_cpu"]),  
            "measurementDuration": row["gen_time"],  
            "measurementDateTime": row["date"].isoformat(),  
        },  
        {  
            "measurementMethod": "nvidia-smi",  
            "version": "v535.183.06",  
            "gpuTrackingMode": "nvml",  
            "powerCalibrationMeasurement": j_to_kwh(row["energy_idle_gpu"]),  
            "durationCalibrationMeasurement": row["idle_time"],  
            "powerConsumption": j_to_kwh(row["energy_gpu"]),  
            "measurementDuration": row["gen_time"],  
            "measurementDateTime": row["date"].isoformat(),  
        },  
    ]  
  
  
def make_system():  
    return {"os": "Linux", "distribution": "Debian", "distributionVersion": "11"}  
  
  
def make_software():  
    return {"language": "python", "version": "3.12.5"}  
  
  
def make_infrastructure():  
    return {  
        "infraType": "publicCloud",  
        "cloudProvider": "grid5000",  
        "cloudInstance": "chuc",  
        "components": [  
            {  
                "componentName": "Nvidia A100-SXM4-40GB",  
                "componentType": "gpu",  
                "nbComponent": 4,  
                "memorySize": 40,  
                "manufacturer": "Nvidia",  
                "share": 1,  
            },  
            {  
                "componentName": "AMD EPYC 7513 (Zen 3)",  
                "componentType": "cpu",  
                "nbComponent": 1,  
                "manufacturer": "AMD",  
                "share": 1,  
            },  
            {"componentName": "ram", "componentType": "ram", "nbComponent": 1, "memorySize": 512},  
        ],  
    }  
  
  
def make_environment():  
    return {  
        "country": "france",  
        "location": "lille",  
    }  
  
###
# Bringing all the sections together in one report
###

def make_report(row):  
    return {  
        "header": make_header(),  
        "task": make_task(row),  
        "measures": make_measures(row),  
        "system": make_system(),  
        "software": make_software(),  
        "infrastructure": make_infrastructure(),  
        "environment": make_environment(),  
        "quality": "high",  
    }  

def make_name(report):  
    #report_<publisher>_<taskStage>_<taskFamily>_<infraType>_<reportID>.json  
    return f"report_{report['header']['publisher']['name']}_{report['task']['taskStage']}_{report['task']['taskFamily']}_{report['infrastructure']['infraType']}_{report['header']['reportId']}.json"  
return make_name, make_report

REPORT_DIR = "./reports"

# For every row in `my_energy_dataframe`, creates a report and saves it.
# Assumes row has columns date, gen_time, idle_time, energy_gpu, energy_idle_gpu, energy_cpu, energy_idle_cpu, nb_requests, output_tokens, prompt_tokens, parameters, model
for _row in my_energy_dataframe.iter_rows(): # use iterrows if using pandas 
    report = make_report(_row)  
    name = make_name(report)  
    json.dump(report, open(os.path.join(REPORT_DIR, name), "w"), indent="\t")
