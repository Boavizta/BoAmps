#!/bin/bash

##########################################
# Script for testing the two scripts
# Author : dfovet
# Version : 0.1
# Date : 20250717
#########################################

#########################################
# Test for gen_form.sh
#########################################
./gen_form.sh -a Ref_CodeCarbon.csv CodeCarbonCSV.conf sample_emissions.csv 2 > test/form_test1.txt

#########################################
# Test for form2json.sh
#########################################
./form2json.sh -a Ref_CodeCarbon.csv form_test1.txt > test/test1.json

#########################################
# Validate schema knowing that errors are expected but not inside code carbon datas
#########################################
cd ../../schema_validator/
python3 validate-schema.py ../json_generator/small-automation/bash/test/test1.json
cd ../json_generator/bash/