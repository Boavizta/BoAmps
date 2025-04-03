##############################################################
# BoAmps - an open-data initiative hosted by Boavizta        #
# (A)I (M)easures of (P)ower consumption (S)haring           #
##############################################################

import unittest
from .validator import BoAmpsValidator
from .filesystem import open_json
import os
import json


class BoAmpsValidatorTest(unittest.TestCase):

    def testvalidator(self):
        """
            Tests validator.
        """
        with open(os.sep.join(['..', 'examples', 'energy-report-llm-inference.json'])) as f:
            obj = json.load(f)
            validator = BoAmpsValidator()
            self.assertEqual(validator.is_valid(obj), True)
