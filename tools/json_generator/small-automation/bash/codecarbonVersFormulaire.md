# Automatically fetch data from CodeCarbon

## Information

`example-carbon.py` trains a regression model and saves Carbon data in a BoAmps compatible csv using the [https://github.com/lukalafaye/BoAmps_Carbon](https://github.com/lukalafaye/BoAmps_Carbon) package.
It will outputs a csv file containing these fields:

```
run_id: 5b0fa12a-3dd7-45bb-9766-cc326314d9f1
timestamp: 2025-01-16 10:25:02
project_name: Linear Regression Training
duration: 0.1512455940246582
emissions: 1.1263528505851737e-07
emissions_rate: 7.447177934991875e-07
cpu_power: Power(kW=0.0425)
gpu_power: Power(kW=0.0)
ram_power: Power(kW=0.0050578808784484865)
cpu_energy: Power(kW=1.785538262791104e-06)
gpu_energy: Power(kW=0.0)
ram_energy: Power(kW=2.1249505499080597e-07)
energy_consumed: 2.0099445932032577e-06
country_name: France
country_iso_code: FR
region: Île-de-France
cloud_provider: None
os: Linux
python_version: 3.13.1
codecarbon_version: 2.8.2
cpu_count: 12
cpu_model: AMD Ryzen 5 7530U with Radeon Graphics
gpu_count: 0
gpu_model: None
longitude: 2.2463
latitude: 48.7144
ram_total_size: 13.49
tracking_mode: machine
on_cloud: No
pue: 1.0
kWh: kWh
```

## Tracking Fields Documentation

This table provides a comprehensive explanation of how each key-value pair is extracted and what it represents in the context of the `CodeCarbon` emissions tracking script.

---

## Table of Key-Value Pairs

| Key                 | What It Represents                                                              | Path                                          |
|---------------------|----------------------------------------------------------------------------------|-----------------------------------------------|
| **run_id**          | A unique identifier for the current run, generated by the CodeCarbon tracker.   | Could be used for optional measure_id  in [measures]               |
| **timestamp**       | The current date and time when the tracking data was extracted.                 | `[header]reportDatetime`                  |
| **project_name**    | The name of the project being tracked (e.g., "Linear Regression Training").     | Could be used for optional measure_name in [measures]            |
| **duration**        | The total time (in seconds) taken for the training process.                     | `[measures](measures.1)measurementDuration` |
| **emissions**       | The total carbon emissions (in kg of CO₂) produced during the training.         |  NTBA  [measures](measures.1)     |
| **emissions_rate**  | The rate of carbon emissions (in kg of CO₂ per second) during the training.     | NTBA  [measures](measures.1)             |
| **cpu_power**       | The power consumption (in kW) of the CPU during the training.                   | NTBA [measures](measures.1)cpu_powerConsumption         |
| **gpu_power**       | The power consumption (in kW) of the GPU during the training.                   | NTBA [measures](measures.1)gpu_powerConsumption         |
| **ram_power**       | The power consumption (in kW) of the RAM during the training.                   |  NTBA [measures](measures.1)ram_powerConsumption |
| **cpu_energy**      | The total energy consumed (in kWh) by the CPU during the training.              |  NTBA [measures](measures.1)cpu_energy         |
| **gpu_energy**      | The total energy consumed (in kWh) by the GPU during the training.              |  NTBA [measures](measures.1)gpu_energy     |
| **ram_energy**      | The total energy consumed (in kWh) by the RAM during the training.              |  NTBA [measures](measures.1)ram_energy    |
| **energy_consumed** | The total energy consumed (in kWh) by the system during the training.           | `[measures](measures.1)powerConsumption` |
| **country_name**    | The name of the country where the training was executed.                        | `[environment]country`                   |
| **country_iso_code**| The ISO code of the country where the training was executed.                    | NTBA                                              |
| **region**          | The region (e.g., state or province) where the training was executed.           | NTBA [environment]region                                |
| **cloud_region**    | The region of the cloud provider used for the training (if applicable).         | `[environment]country`       |
| **os**              | The operating system on which the training was executed.                       | `[system]os`                             |
| **python_version**  | The version of Python used to run the script.                                   | [software]version and automatically fill [software]language to Python|
| **codecarbon_version** | The version of the CodeCarbon library used for tracking.                     | `[measures](measures.1)version`        |
| **cpu_count**       | The number of CPU cores available on the system.                                | `[infrastructure](components.1)nbComponent` |
| **cpu_model**       | The model name of the CPU used for the training.                                | `[infrastructure](components.1)componentName` |
| **gpu_count**       | The number of GPUs available on the system.                                     | `[infrastructure](components.2)nbComponent` |
| **gpu_model**       | The model name of the GPU used for the training (if applicable).                | `[infrastructure](components.2)componentName` |
| **longitude**       | The longitude of the location where the training was executed.                  | `[environment]longitude`                |
| **latitude**        | The latitude of the location where the training was executed.                   | `[environment]latitude`                 |
| **ram_total_size**  | The total size of the RAM (in GB) available on the system.                      | `[infrastructure](components.3)memorySize` |
| **tracking_mode**   | The mode used by CodeCarbon for tracking (e.g., "machine" for local tracking).  | `[measures](measures.1)cpuTrackingMode`<br>`[measures](measures.1)gpuTrackingMode` |
| **pue**             | The Power Usage Effectiveness (PUE) of the data center (if applicable).         | NTBA?                                              |
| **kWh**             | The unit of energy measurement (kilowatt-hours).                                | `[measures](measures.*)unit = M19`           |

The table will be soon be updated with paths to variables in the report.txt generated using the bash script.
---

## How Each Key-Value Pair is Extracted

1. **`run_id`**: Extracted from the `CodeCarbon` tracker object using `get_field_or_none(tracker, "_experiment_id")`.
2. **`timestamp`**: Generated using `datetime.now().strftime("%Y-%m-%d %H:%M:%S")`.
3. **`project_name`**: Hardcoded as "Linear Regression Training".
4. **`duration`**: Calculated as the difference between the training start and end times.
5. **`emissions`**: Retrieved directly from the `CodeCarbon` tracker after stopping it.
6. **`emissions_rate`**: Calculated as `emissions / duration`.
7. **`cpu_power`**: Extracted from the tracker using `get_field_or_none(tracker, "_cpu_power")`.
8. **`gpu_power`**: Extracted from the tracker using `get_field_or_none(tracker, "_gpu_power")`.
9. **`ram_power`**: Extracted from the tracker using `get_field_or_none(tracker, "_ram_power")`.
10. **`cpu_energy`**: Calculated as `cpu_power * (duration / 3600)`.
11. **`gpu_energy`**: Calculated as `gpu_power * (duration / 3600)`.
12. **`ram_energy`**: Calculated as `ram_power * (duration / 3600)`.
13. **`energy_consumed`**: Extracted from the tracker using `get_field_or_none(tracker, "_total_energy")`.
14. **`country_name`**: Retrieved from the `ip-api.com` JSON response.
15. **`country_iso_code`**: Retrieved from the `ip-api.com` JSON response.
16. **`region`**: Retrieved from the `ip-api.com` JSON response.
19. **`os`**: Retrieved using `platform.system()`.
20. **`python_version`**: Retrieved using `platform.python_version()`.
21. **`codecarbon_version`**: Retrieved using `pkg_resources.get_distribution("codecarbon").version`.
22. **`cpu_count`**: Retrieved using `os.cpu_count()`.
23. **`cpu_model`**: Retrieved using the `get_cpu_model()` function.
24. **`gpu_count`**: Hardcoded as `0` (no GPU used in this example).
25. **`gpu_model`**: Hardcoded as `None` (no GPU used in this example).
26. **`longitude`**: Retrieved from the `ip-api.com` JSON response.
27. **`latitude`**: Retrieved from the `ip-api.com` JSON response.
28. **`ram_total_size`**: Calculated using `os.sysconf("SC_PAGE_SIZE") * os.sysconf("SC_PHYS_PAGES") / (1024**3)`.
29. **`tracking_mode`**: Extracted from the tracker using `get_field_or_none(tracker, "_tracking_mode")`.
31. **`pue`**: Extracted from the tracker using `get_field_or_none(tracker, "_pue")`.
33. **`kWh`**: Hardcoded as "kWh" (unit of energy measurement).

---

## Run python example

### Prerequisities

Install the required Python packages using `pip`:

```bash
pip install requirements.txt
git clone https://github.com/lukalafaye/BoAmps_Carbon
cd BoAmps_Carbon
pip install .
```

Run python script:
```py
python example-carbon.py
```

---

### Operating System Dependencies

- **Linux**: No additional dependencies required.
- **Windows**: The `wmi` library requires the `pywin32` package, which is installed automatically with `wmi`.
- **macOS**: No additional dependencies required.

---

## Remarks

- NTBA in table means needs to be added in report, lots of variables need to be added as new fields in generated reports by bash script
- How are measures tied to tasks? Maybe add an optional id_measure in each task to create that connection?
- Measures should have a new field measure_name to explain what kind of task they are measuring...
- Maybe add `emissions` and `emissions_rate` fields in measure objects for carbon emissions? or do these belong in powerSourceCarbonIntensity?
- In measure objects, powerConsumption should be replaced by cpu, gpu, and ram consumption fields as cpu, gpu, and ram work on a task at the same time... 
- ├averageUtilizationCpu and ├averageUtilizationGpu can be fetched using Carbon maybe?
- region NTBA in [environment] as well as all the other NTBA...
- The environment might be different for different measures -> on top of global variable for it in report, add measure_environment fields in each measure object...

Lots of objects depend on a single measure ([system], [software], [infrastructure], [environment]...) ideally tasks should include measures as sub sections, which should include [system], [software], [infrastructure], [environment] as sub sections... 
