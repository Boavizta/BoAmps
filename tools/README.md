# Tools Directory

This directory contains various tools to assist with the creation, validation, and transformation of Boamps reports. Below is an overview of the tools currently available and their respective functionalities.

## JSON Generator

The `json_generator` folder contains tools for automating the creation of Boamps JSON reports. Currently, it includes:

- **Bash Tool**: A shell script that simplifies the process of generating JSON reports from CSV files. This tool is designed for users who need to process large quantities of data efficiently. An example is shared for a Codecarbon formatted csv but the script can be adapted to other formats by simply modifying a configuration table.

Additional tools in other programming languages will be added soon to further enhance automation capabilities.

## Data Flattener

The `data_flattener` folder contains a Python-based tool for converting JSON data into CSV format. This tool is useful for integrating Boamps data into data lakes or for quick visualizations. Future updates may include improvements to better handle complex tables and expand its usability.

## Schema Validator

The `schema_validator` folder contains a Python script (`validate-schema.py`) that validates Boamps reports against the defined schema. It ensures that the reports adhere to the correct format and provides detailed feedback to help users fix any errors.