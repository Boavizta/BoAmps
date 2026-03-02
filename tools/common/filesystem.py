##############################################################
# BoAmps - an open-data initiative hosted by Boavizta        #
# (A)I (M)easures of (P)ower consumption (S)haring           #
##############################################################

import json

def open_json(path:str):
    with open(path) as e:
        return json.load(e)

