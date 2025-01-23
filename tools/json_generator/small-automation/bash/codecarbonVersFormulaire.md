# Conversion entre les champs CodeCarbon et les Champs du Datamodel

## Informations

Example of a python script to extract these fields while training a regression model:

```py
import torch
import torch.nn as nn
import torch.optim as optim
from codecarbon import EmissionsTracker
import platform
import os
import requests
import time
from datetime import datetime
import pkg_resources
import csv
import psutil  # For cross-platform RAM and CPU info

# Fetch CPU model
def get_cpu_model():
    system = platform.system()
    try:
        if system == "Linux":
            if os.path.exists("/proc/cpuinfo"):
                with open("/proc/cpuinfo", "r") as f:
                    for line in f:
                        if "model name" in line:
                            return line.split(":")[1].strip()
        elif system == "Windows":
            import wmi  # Windows Management Instrumentation
            c = wmi.WMI()
            for processor in c.Win32_Processor():
                return processor.Name
        elif system == "Darwin":  # macOS
            import subprocess
            return subprocess.check_output(["sysctl", "-n", "machdep.cpu.brand_string"]).decode().strip()
    except Exception as e:
        print(f"Error fetching CPU model: {e}")
    return None

# Extract tracking fields
def extract_fields(tracker, emissions, duration):
    def get_field_or_none(obj, attr, default=None):
        return getattr(obj, attr, default)

    def get_location_info():
        try:
            response = requests.get("http://ip-api.com/json/")
            if response.status_code == 200:
                data = response.json()
                return {
                    "country_name": data.get("country"),
                    "country_iso_code": data.get("countryCode"),
                    "region": data.get("regionName"),
                    "longitude": data.get("lon"),
                    "latitude": data.get("lat"),
                }
        except Exception:
            pass
        return {"country_name": None, "country_iso_code": None, "region": None, "longitude": None, "latitude": None}

    try:
        codecarbon_version = pkg_resources.get_distribution("codecarbon").version
    except Exception:
        codecarbon_version = None

    location_info = get_location_info()
    cpu_power = get_field_or_none(tracker, "_cpu_power", 0)
    gpu_power = get_field_or_none(tracker, "_gpu_power", 0)
    ram_power = get_field_or_none(tracker, "_ram_power", 0)
    duration_hours = duration / 3600

    cpu_energy = cpu_power * duration_hours if cpu_power else None
    gpu_energy = gpu_power * duration_hours if gpu_power else None
    ram_energy = ram_power * duration_hours if ram_power else None

    # Get RAM size in GB
    ram_total_size = round(psutil.virtual_memory().total / (1024**3), 2)

    fields = {
        "run_id": get_field_or_none(tracker, "_experiment_id"),
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "project_name": "Linear Regression Training",
        "duration": duration,
        "emissions": emissions,
        "emissions_rate": emissions / duration if duration else None,
        "cpu_power": cpu_power,
        "gpu_power": gpu_power,
        "ram_power": ram_power,
        "cpu_energy": cpu_energy,
        "gpu_energy": gpu_energy,
        "ram_energy": ram_energy,
        "energy_consumed": float(get_field_or_none(tracker, "_total_energy", 0)),
        "country_name": location_info["country_name"],
        "country_iso_code": location_info["country_iso_code"],
        "region": location_info["region"],
        "cloud_provider": os.environ.get("CLOUD_PROVIDER", "None"),
        "cloud_region": os.environ.get("CLOUD_REGION", "None"),
        "os": platform.system(),
        "python_version": platform.python_version(),
        "codecarbon_version": codecarbon_version,
        "cpu_count": os.cpu_count(),
        "cpu_model": get_cpu_model(),
        "gpu_count": 0,
        "gpu_model": None,
        "longitude": location_info["longitude"],
        "latitude": location_info["latitude"],
        "ram_total_size": ram_total_size,
        "tracking_mode": get_field_or_none(tracker, "_tracking_mode"),
        "on_cloud": "Yes" if os.environ.get("CLOUD_PROVIDER") else "No",
        "pue": get_field_or_none(tracker, "_pue", 1.0),
        "extra": get_field_or_none(tracker, "_measure_power_method"),
        "kWh": "kWh",
    }
    return fields

# Generate synthetic data
torch.manual_seed(42)
n_samples = 100
X = torch.rand(n_samples, 1) * 10
true_slope = 2.5
true_intercept = 1.0
noise = torch.randn(n_samples, 1) * 2
y = true_slope * X + true_intercept + noise

# Define the linear regression model
class LinearRegressionModel(nn.Module):
    def __init__(self):
        super(LinearRegressionModel, self).__init__()
        self.linear = nn.Linear(1, 1)

    def forward(self, x):
        return self.linear(x)

# Initialize the model, loss function, and optimizer
model = LinearRegressionModel()
criterion = nn.MSELoss()
optimizer = optim.SGD(model.parameters(), lr=0.01)

# Initialize the CodeCarbon tracker
tracker = EmissionsTracker(project_name="Linear Regression Training")
tracker.start()

# Measure training start time
start_time = time.time()

# Training loop
num_epochs = 500
for epoch in range(num_epochs):
    y_pred = model(X)
    loss = criterion(y_pred, y)
    optimizer.zero_grad()
    loss.backward()
    optimizer.step()
    if (epoch + 1) % 50 == 0:
        print(f"Epoch [{epoch + 1}/{num_epochs}], Loss: {loss.item():.4f}")

# Measure training end time and stop tracker
end_time = time.time()
training_duration = end_time - start_time
emissions = tracker.stop()

# Extract tracking fields
fields = extract_fields(tracker, emissions, training_duration)

# Write tracking fields to a CSV file
csv_file = "tracking_info.csv"
with open(csv_file, mode="w", newline="") as file:
    writer = csv.DictWriter(file, fieldnames=fields.keys())
    writer.writeheader()
    writer.writerow(fields)

print(f"Tracking information saved to {csv_file}")
```

Outputs a csv file containing these fields:

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
cloud_region: None
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
extra: None
kWh: kWh
```

Tested on CPU only:
Some fields were not found including

- cloud_provider -> fetched using CLOUD_PROVIDER OK?
- cloud_region How is this different from region? Since we already have the on_cloud field? currently fetched using CLOUD_REGION if different?
- cpu_model -> fetched on my Linux system but needs to be updated for other platforms in python code
- on_cloud  -> yes if CLOUD_PROVIDER found, OK?
- extra -> what is this?
- tracking mode is a field in code carbon _tracking_mode, should we use this or M14/M15?

# CodeCarbon Tracking Fields Documentation

This document provides a comprehensive explanation of how each key-value pair is extracted and what it represents in the context of the `CodeCarbon` emissions tracking script.

---

## Table of Key-Value Pairs

| **Key**               | **What It Represents**                                                                 |
|------------------------|---------------------------------------------------------------------------------------|
| `run_id`              | A unique identifier for the current run, generated by the `CodeCarbon` tracker.       |
| `timestamp`           | The current date and time when the tracking data was extracted.                       |
| `project_name`        | The name of the project being tracked (e.g., "Linear Regression Training").           |
| `duration`            | The total time (in seconds) taken for the training process.                           |
| `emissions`           | The total carbon emissions (in kg of CO₂) produced during the training.               |
| `emissions_rate`      | The rate of carbon emissions (in kg of CO₂ per second) during the training.           |
| `cpu_power`           | The power consumption (in kW) of the CPU during the training.                         |
| `gpu_power`           | The power consumption (in kW) of the GPU during the training.                         |
| `ram_power`           | The power consumption (in kW) of the RAM during the training.                         |
| `cpu_energy`          | The total energy consumed (in kWh) by the CPU during the training.                    |
| `gpu_energy`          | The total energy consumed (in kWh) by the GPU during the training.                    |
| `ram_energy`          | The total energy consumed (in kWh) by the RAM during the training.                    |
| `energy_consumed`     | The total energy consumed (in kWh) by the system during the training.                 |
| `country_name`        | The name of the country where the training was executed.                              |
| `country_iso_code`    | The ISO code of the country where the training was executed.                          |
| `region`              | The region (e.g., state or province) where the training was executed.                 |
| `cloud_provider`      | The cloud provider used for the training (if applicable).                             |
| `cloud_region`        | The region of the cloud provider used for the training (if applicable).               |
| `os`                  | The operating system on which the training was executed.                              |
| `python_version`      | The version of Python used to run the script.                                         |
| `codecarbon_version`  | The version of the `CodeCarbon` library used for tracking.                            |
| `cpu_count`           | The number of CPU cores available on the system.                                      |
| `cpu_model`           | The model name of the CPU used for the training.                                      |
| `gpu_count`           | The number of GPUs available on the system.                                           |
| `gpu_model`           | The model name of the GPU used for the training (if applicable).                      |
| `longitude`           | The longitude of the location where the training was executed.                        |
| `latitude`            | The latitude of the location where the training was executed.                         |
| `ram_total_size`      | The total size of the RAM (in GB) available on the system.                            |
| `tracking_mode`       | The mode used by `CodeCarbon` for tracking (e.g., "machine" for local tracking).      |
| `on_cloud`            | Indicates whether the training was executed on a cloud provider (Yes/No).            |
| `pue`                 | The Power Usage Effectiveness (PUE) of the data center (if applicable).               |
| `extra`               | Additional information about the power measurement method used by `CodeCarbon`.       |
| `kWh`                 | The unit of energy measurement (kilowatt-hours).                                      |

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
17. **`cloud_provider`**: Retrieved from the environment variable `CLOUD_PROVIDER`.
18. **`cloud_region`**: Retrieved from the environment variable `CLOUD_REGION`.
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
30. **`on_cloud`**: Determined by checking if the `CLOUD_PROVIDER` environment variable is set.
31. **`pue`**: Extracted from the tracker using `get_field_or_none(tracker, "_pue")`.
32. **`extra`**: Extracted from the tracker using `get_field_or_none(tracker, "_measure_power_method")`.
33. **`kWh`**: Hardcoded as "kWh" (unit of energy measurement).

---

## Requirements

To run this script, you need the following dependencies installed:

---

### Python Packages

Install the required Python packages using `pip`:

```bash
pip install torch codecarbon psutil wmi
```

---

### Package Versions

Here are the recommended versions of the packages:

| **Package**   | **Version** | **Description**                                                                 |
|---------------|-------------|---------------------------------------------------------------------------------|
| `torch`       | `>=2.0.0`   | PyTorch library for deep learning.                                              |
| `codecarbon`  | `>=2.0.0`   | Library for tracking carbon emissions.                                          |
| `psutil`      | `>=5.8.0`   | Cross-platform library for retrieving system information (CPU, RAM, etc.).     |
| `wmi`         | `>=1.5.1`   | Windows Management Instrumentation library (required only on Windows).         |

---

### Operating System Dependencies

- **Linux**: No additional dependencies required.
- **Windows**: The `wmi` library requires the `pywin32` package, which is installed automatically with `wmi`.
- **macOS**: No additional dependencies required.


---
