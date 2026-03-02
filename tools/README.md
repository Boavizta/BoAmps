# Tools Directory

This directory contains various tools to assist with the creation, validation, and transformation of Boamps reports. Below is an overview of the tools currently available and their respective functionalities.

## JSON Generator

The `json_generator` folder contains tools for automating the creation of Boamps JSON reports. Currently, it includes:

- **Bash Tool**: A shell script that simplifies the process of generating JSON reports from CSV files. This tool is designed for users who need to process large quantities of data efficiently. An example is shared for a Codecarbon formatted csv but the script can be adapted to other formats by simply modifying a configuration table.

Additional tools in other programming languages will be added soon to further enhance automation capabilities.

## Data Flattener

The `data_flattener` folder contains a Python-based tool for converting JSON data into CSV format. This tool is useful for integrating Boamps data into data lakes or for quick visualizations. Future updates may include improvements to better handle complex tables and expand its usability.

## Schema Validator

The `schema_validator` folder contains a Python script that validates Boamps reports against the defined schema. It ensures that the reports adhere to the correct format and provides detailed feedback to help users fix any errors.

## Installing Requirements for Python Tools

To use the Python-based tools (`data_flattener` and `schema_validator`), you need to install the required dependencies. It is recommended to use a virtual environment to avoid conflicts with system-wide packages. Follow these steps:

1. Ensure you have Python installed on your system.
2. Create a virtual environment by running the following command:

   ```bash
   python -m venv .venv
   ```

3. Activate the virtual environment:
   - On Windows:
     ```bash
     .venv\Scripts\activate
     ```
   - On macOS/Linux:
     ```bash
     source .venv/bin/activate
     ```

4. Install the dependencies listed in the `requirements.txt` file by running:

   ```bash
   pip install -r requirements.txt
   ```

5. Once the dependencies are installed, you can use the tools as needed. Remember to activate the virtual environment each time you work with the tools.

6. When you are done, deactivate the virtual environment by running:

   ```bash
   deactivate
   ```