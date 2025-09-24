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
./scripts/gen_form.sh -a ./data/conf/boamps_auto_prefill_codecarbon.csv ./data/conf/config_nb_fields_boamps.conf ./data/input/codecarbon_file.csv 2 > data/output/form_prefilled.txt
#########################################
# Test for form2json.sh
#########################################
./scripts/form2json.sh -a ./data/conf/boamps_auto_prefill_codecarbon.csv ./data/output/form_prefilled.txt > ./data/output/boamps_report.json

#########################################
# Validate schema knowing that errors are expected but not inside code carbon datas
#########################################
cd ..\..\schema_validator\ 
python ./validate-schema.py ..\json_generator\bash\data\output\boamps_report.json