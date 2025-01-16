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
import platform
import os
import requests
from codecarbon import EmissionsTracker
from datetime import datetime
import pkg_resources

def get_cpu_model():
    """
    Fetch the CPU model using platform or /proc/cpuinfo (Linux-specific).
    """
    try:
        # Try platform.processor (may return empty on some systems)
        cpu_model = platform.processor()
        if cpu_model:
            return cpu_model
        
        # Fallback to reading /proc/cpuinfo
        if os.path.exists("/proc/cpuinfo"):
            with open("/proc/cpuinfo", "r") as f:
                for line in f:
                    if "model name" in line:
                        return line.split(":")[1].strip()
    except Exception as e:
        print(f"Error fetching CPU model: {e}")
    return None

def extract_fields(tracker, emissions, duration):
    # Use a utility function to handle missing attributes
    def get_field_or_none(obj, attr, default=None):
        return getattr(obj, attr, default)

    # Get location information via external API
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

    # Fetch CodeCarbon version
    try:
        codecarbon_version = pkg_resources.get_distribution("codecarbon").version
    except Exception:
        codecarbon_version = None

    # Location information
    location_info = get_location_info()

    # Extract power values
    cpu_power = get_field_or_none(tracker, "_cpu_power", 0)  # kW
    gpu_power = get_field_or_none(tracker, "_gpu_power", 0)  # kW
    ram_power = get_field_or_none(tracker, "_ram_power", 0)  # kW

    # Calculate energy consumption (kWh)
    duration_hours = duration / 3600  # Convert seconds to hours
    cpu_energy = cpu_power * duration_hours if cpu_power else None
    gpu_energy = gpu_power * duration_hours if gpu_power else None
    ram_energy = ram_power * duration_hours if ram_power else None

    # Extract fields
    fields = {
        "run_id": get_field_or_none(tracker, "_experiment_id"),
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "project_name": "Linear Regression Training",
        "duration": duration,
        "emissions": emissions,
        "emissions_rate": emissions / duration if duration else None,  # Calculate manually
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
        "cpu_model": get_cpu_model(),  # Updated CPU model extraction
        "gpu_count": 0,  # No GPU detected
        "gpu_model": None,
        "longitude": location_info["longitude"],
        "latitude": location_info["latitude"],
        "ram_total_size": round(os.sysconf("SC_PAGE_SIZE") * os.sysconf("SC_PHYS_PAGES") / (1024**3), 2),
        "tracking_mode": get_field_or_none(tracker, "_tracking_mode"),
        "on_cloud": "Yes" if os.environ.get("CLOUD_PROVIDER") else "No",
        "pue": get_field_or_none(tracker, "_pue", 1.0),  # Default PUE is 1.0
        "extra": get_field_or_none(tracker, "_measure_power_method"),
        "kWh": "kWh",
    }
    return fields

# Example usage
tracker = EmissionsTracker(project_name="Linear Regression Training")
tracker.start()

# Simulate task duration and emissions
import time
time.sleep(1)  # Simulate task duration
emissions = tracker.stop()
duration = 1  # Replace with actual duration in seconds

fields = extract_fields(tracker, emissions, duration)

# Print extracted fields
for key, value in fields.items():
    print(f"{key}: {value}")
```

Output:

```
run_id: 5b0fa12a-3dd7-45bb-9766-cc326314d9f1
timestamp: 2025-01-16 10:15:55
project_name: Linear Regression Training
duration: 1
emissions: 7.412917773134365e-07
emissions_rate: 7.412917773134365e-07
cpu_power: Power(kW=0.0425)
gpu_power: Power(kW=0.0)
ram_power: Power(kW=0.0050578808784484865)
cpu_energy: Power(kW=1.1805555555555557e-05)
gpu_energy: Power(kW=0.0)
ram_energy: Power(kW=1.4049669106801352e-06)
energy_consumed: 1.3228140711173227e-05
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
