# Conversion entre les champs CodeCarbon et les Champs du Datamodel

## Informations

Version : v0.1

Etat : Travail

RAF :

- Détailler les elemetns
- Affiner les réponses 
- Choisir les numeros d'item judicieusement
- ...

## Contenu

Dans la suite les champs du datamodel son exprimé en fonction des éléments et valeurs du fichier form_example.txt

**run_id** : [header]reportId= H4  

**timestamp** :

- \[header]├reportDatetime= H5
- ET
- \[measures](measures.1)measurementDateTime= M114

**project_name** :

**duration** : \[measures](measures.1)measurementDuration = M113

**emissions** :

**emissions_rate** :

**cpu_power** :

**gpu_power** :

**ram_power** :

**cpu_energy** :

**gpu_energy** :

**ram_energy** :

**energy_consumed** : \[measures](measures.1)powerConsumption = M112

**country_name** : \[environment]country = E1

**country_iso_code** :

**region** :

**cloud_provider** : \[infrastructure]cloudProvider = I2

**cloud_region** :

**os** : \[system]os = S1

**python_version** : A METTRE DASN SOFTWARE ?

**codecarbon_version** : \[measures](measures.1)version = M13

**cpu_count** : \[infrastructure](components.1)nbComponent =  IC12  = "Intel(R) Xeon(R) Gold 6226R CPU @ 2.90GHz" ?

**cpu_model** : \[infrastructure](components.1)componentName = IC11

**gpu_count** : \[infrastructure](components.2)nbComponent= IC12

**gpu_model** : \[infrastructure](components.2)componentName= IC11 = "2 x Tesla V100S-PCIE-32GB"

**longitude** : \[environment]longitude = E3

**latitude** : \[environment]latitude = E2

**ram_total_size** : \[infrastructure](components.3)memorySize = IC13

**tracking_mode** : \[measures](measures.1)

- cpuTrackingMode = M14
- OU
- gpuTrackingMode= M15 ?

**on_cloud** :

**pue** :

**Extra** : 
codecarbon ==> \[measures](measures.*)measurementMethod = M11

**kWh** ==> \[measures](measures.*)unit= M19



Example of a python script to extract these fields:

```py
import torch
import torch.nn as nn
import torch.optim as optim
from codecarbon import EmissionsTracker
import platform
import os
import time
from datetime import datetime
import pkg_resources

# Generate synthetic data
torch.manual_seed(42)
n_samples = 100
X = torch.rand(n_samples, 1) * 10
true_slope = 2.5
true_intercept = 1.0
noise = torch.randn(n_samples, 1) * 2
y = true_slope * X + true_intercept + noise

# Define linear regression model
class LinearRegressionModel(nn.Module):
    def __init__(self):
        super(LinearRegressionModel, self).__init__()
        self.linear = nn.Linear(1, 1)

    def forward(self, x):
        return self.linear(x)

# Initialize model, loss, and optimizer
model = LinearRegressionModel()
criterion = nn.MSELoss()
optimizer = optim.SGD(model.parameters(), lr=0.01)

# Initialize CodeCarbon tracker
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

# Measure training end time
end_time = time.time()
training_duration = end_time - start_time

# Stop tracker
emissions = tracker.stop()

# Field extraction
def get_field_or_none(obj, attr, default=None):
    return getattr(obj, attr, default)

try:
    codecarbon_version = pkg_resources.get_distribution("codecarbon").version
except Exception:
    codecarbon_version = None

fields = {
    "run_id": get_field_or_none(tracker, "_experiment_id"),
    "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    "project_name": "Linear Regression Training",
    "duration": training_duration,
    "emissions": emissions,
    "emissions_rate": None,  # Emissions rate is not directly available
    "cpu_power": get_field_or_none(tracker, "_cpu_power"),
    "gpu_power": get_field_or_none(tracker, "_gpu_power"),
    "ram_power": get_field_or_none(tracker, "_ram_power"),
    "cpu_energy": get_field_or_none(tracker, "_cpu_energy"),
    "gpu_energy": get_field_or_none(tracker, "_gpu_energy"),
    "ram_energy": get_field_or_none(tracker, "_ram_energy"),
    "energy_consumed": float(get_field_or_none(tracker, "_total_energy", 0)),
    "country_name": None,  # Country name not directly available
    "country_iso_code": None,  # Country ISO code not directly available
    "region": None,  # Region not directly available
    "cloud_provider": os.environ.get("CLOUD_PROVIDER", "None"),
    "cloud_region": os.environ.get("CLOUD_REGION", "None"),
    "os": platform.system(),
    "python_version": platform.python_version(),
    "codecarbon_version": codecarbon_version,
    "cpu_count": os.cpu_count(),
    "cpu_model": platform.processor(),
    "gpu_count": 0,  # CodeCarbon doesn't provide GPU count in this setup
    "gpu_model": None,  # GPU model not provided in CPU-only runs
    "longitude": None,  # Longitude not directly available
    "latitude": None,  # Latitude not directly available
    "ram_total_size": round(os.sysconf("SC_PAGE_SIZE") * os.sysconf("SC_PHYS_PAGES") / (1024**3), 2),
    "tracking_mode": get_field_or_none(tracker, "_tracking_mode"),
    "on_cloud": "Yes" if os.environ.get("CLOUD_PROVIDER") else "No",
    "pue": get_field_or_none(tracker, "_pue"),
    "extra": get_field_or_none(tracker, "_measure_power_method"),
    "kWh": "kWh"  # Assumed as the default unit for power consumption
}

# Print extracted fields
for key, value in fields.items():
    print(f"{key}: {value}")
```

Tested on CPU only:
Some fields were not found including

- emissions_rate
- cpu_energy
- ram_energy
- country_name
- country_iso_code
- region
- cloud_provider
- cloud_region
- cpu_model
- longitude
- latitude
- on_cloud (No because uses global var but can hardly be extracted)
- extra
