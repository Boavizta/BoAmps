# Contribute energy data to BoAmps

You can help build the [open BoAmps dataset](https://huggingface.co/datasets/boavizta/open_data_BoAmps) by measuring an AI workload and sharing the resulting report. A single report is useful; you do not need a perfect experimental setup. If you have questions or cannot complete a field, email us at [tristan+boamps@coignion.fr](mailto:tristan+boamps@coignion.fr).

## 1. Install CodeCarbon

In the Python environment that runs your workload, install a recent version of [CodeCarbon](https://docs.codecarbon.io/):

```bash
python -m pip install --upgrade 'codecarbon>=3.3.3'
```

CodeCarbon can export BoAmps JSON directly. You can also use a different measurement tool, but you'll have to convert the measurements to the BoAmps format yourself.

## 2. Measure your workload

Start the tracker immediately before the work you want to measure and stop it afterwards. Adapt this example to your code:

```python
from codecarbon import OfflineEmissionsTracker, OutputMethod

tracker = OfflineEmissionsTracker(
    country_iso_code="FRA",  # Replace with your machine's 3-letter country code
    output_dir=".",
    output_methods=[OutputMethod.CSV, OutputMethod.BOAMPS],
    tracking_mode="machine",
    metadata={"boamps": {"task": {
        "taskStage": "inference",  # Or "training"
        "taskFamily": "classification",  # Replace with your task
        "algorithms": [{"algorithmName": "my_model"}],  # Replace with your model
        "dataset": [{"dataUsage": "input", "dataType": "text", "source": "other"}],  # Adapt to your input
    }}},
)
tracker.start()
try:
    run_your_workload()  # Replace with your own training or inference code
finally:
    tracker.stop()
```

Replace the placeholders, including the country code. This offline example does not need an internet connection to obtain the location. `tracker.stop()` writes `boamps_report_<run_id>.json` and `emissions.csv` in `output_dir`. See the [CodeCarbon BoAmps output documentation](https://docs.codecarbon.io/latest/reference/output/#boamps) for configuration and metadata options. Check that the report was actually created; if the workload failed or was interrupted, say so when sharing it.

Use one report per run or observation window. If the model, dataset or hardware changes, make separate reports where practical. For a long-running service, a daily window is another possible choice.

**For a continuously running service:** choose a representative, bounded observation window (for example, one hour) rather than trying to measure the whole lifetime of the service. Start and stop the tracker around that window; do not restart the service solely to fit the example. Record the start/end time and time zone, request and, where applicable, token counts, and describe the traffic, number of replicas or machines, and whether model loading and warm-up are included. If practical, measure separate windows for different traffic levels. Measure each machine separately and avoid counting the same machine twice; explain any missing machines. Do not treat total window energy as the energy of one request without explaining the allocation.

**For more useful measurements, when feasible:**

- Run on an otherwise idle machine. If other workloads run at the same time, describe them in the report's comments or in the accompanying message. Machine mode includes activity from other processes; it does not isolate your workload.
- Measure idle separately with the same hardware, measurement settings and a comparable duration, and describe whether the model/service is loaded or unloaded. Send the idle report alongside the workload report. Keep both original measurements: do not silently subtract idle energy.
- Use a window long enough for multiple power samples; very short runs can be unreliable. Repeat runs where practical.

CodeCarbon reports component energy using a mix of hardware readings and estimates, depending on the machine; it does not necessarily measure whole-system energy at the wall. Hardware support, permissions and tracking mode affect coverage and accuracy. Note which components use readings or estimates when known. BoAmps seeks measurements grounded in actual energy or power readings, rather than consumption calculated solely from a theoretical model. If you are unsure whether your measurement qualifies, contact us. See [CodeCarbon's documentation](https://docs.codecarbon.io/) for details.

## 3. Review and share

Check that the report's task, hardware and measurement information look right.

### Recommended context

CodeCarbon cannot automatically know everything about your workload. To make your measurements easier to understand and compare, please share the following **when known**:

- **What was run:** task, model name or link, and dataset or input type.
- **How much work was completed:** for example, requests, input and output tokens, examples, epochs or training steps.
- **What was measured:** whether loading and warm-up were included, any concurrent workloads or failures, and which idle report corresponds to the workload, if available.
- **Other useful details:** framework and version, batch size, precision or quantization, known measurement limitations, and any quality or performance results.

These details are recommendations and are not required: share what you know and do not guess. Put them in the report where supported, or simply include them in your email or `source_info.md`. You do not need to edit the JSON manually.

For descriptions of the available fields, see the [BoAmps report schema documentation](https://boavizta.github.io/BoAmps/model/report/) and its pages for [algorithms](https://boavizta.github.io/BoAmps/model/algorithm/), [datasets](https://boavizta.github.io/BoAmps/model/dataset/), [hardware](https://boavizta.github.io/BoAmps/model/hardware/) and [measurements](https://boavizta.github.io/BoAmps/model/measure/). The [JSON schemas](model/) are also available in this repository. For how to pass metadata to CodeCarbon, see its [BoAmps output documentation](https://docs.codecarbon.io/latest/reference/output/#boamps).

A [sample report](examples/energy-report-llm-inference.json) is available in this repository. It is an older, enriched example, not a template you need to fill in or an exact match for current CodeCarbon output.

Please, do not guess missing values. Remove secrets, personal data, private inputs or outputs, precise locations and other information you are not allowed to publish. Check that you have the right to share the remaining information. Reports accepted into the dataset are intended to be public.

**Choose one way to send your report:**

1. **Email:** attach the BoAmps JSON report(s) and your short context message to [tristan+boamps@coignion.fr](mailto:tristan+boamps@coignion.fr). If you cannot generate a report, get in touch and we can help.
2. **Hugging Face:** create a [pull request on the dataset](https://huggingface.co/datasets/boavizta/open_data_boamps/discussions?new_pr=true), then follow Hugging Face's instructions to clone the repository, add your files, commit and push your changes, and publish the proposed branch. A Hugging Face account is needed. Maintainers review the proposal; if this is inconvenient, use email instead.

For a Hugging Face submission, create a uniquely named source folder under `data/`, for example:

```text
data/my-organisation-my-experiment/
├── reports/            # Required: BoAmps JSON report(s)
├── source_info.md      # Required: brief provenance and notes
├── source_data/        # Optional: original data, e.g. CodeCarbon CSV
└── conversion.py       # Optional: conversion script, if used
```

In `source_info.md`, briefly identify the data and original authors or organisation, the person who converted the data (if applicable), and any missing information or conversion issues. A few sentences are enough. Add the workload and measurement context above there as well, especially if it applies to several reports. For example:

```markdown
# Source information
- Data: CodeCarbon measurements of [task and model]; [what each report covers].
- Original data by: [name or organisation]; conversion by: [name, or not applicable].
- Context: [amount of work, measurement boundaries, concurrent workloads].
- Limitations or conversion issues: [known issues, or none known].
```

If available, include the corresponding CodeCarbon CSV as supplementary source data, after the same privacy review. It does not replace the BoAmps JSON report. Include a conversion script only if one was used; the source data and script can help regenerate reports if the model changes.
