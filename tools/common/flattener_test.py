##############################################################
# BoAmps - an open-data initiative hosted by Boavizta        #
# (A)I (M)easures of (P)ower consumption (S)haring           #
##############################################################

import unittest
from .flattener import BoAmpsFlattener
import os
import json

class BoAmpsFlattenerTest(unittest.TestCase):

    def testGetRaw(self):
        """
            Tests flattener.
        """
        obj = { 
            'foo': 10, 
            'bar': 20, 
            'nested': { 
                'foo': [ 3, 2, 1 ], 
                'bar': [ [ 
                    { 'x': True }, 
                    { 'y': False } 
                ] ]
            } 
        }
        flattener = BoAmpsFlattener(obj=obj)
        out = flattener.get_raw().to_dict(orient='records')
        expected = [{
            'foo': 10, 
            'bar': 20, 
            'nested.foo.0': 3, 
            'nested.foo.1': 2, 
            'nested.foo.2': 1, 
            'nested.bar.0.0.x': True, 
            'nested.bar.0.1.y': False
        }]
        print(str(out))
        self.assertEqual(out == expected, True)


    def testGetDenumeratedAmbiguous(self):
        """
            Tests flattener with denumerated columns.
        """
        obj = { 
            'foo': 10, 
            'bar': 20, 
            'nested': { 
                'foo': [ 3, 2, 1 ], 
                'bar': [ [ 
                    { 'x': True }, 
                    { 'y': False } 
                ] ]
            } 
        }
        flattener = BoAmpsFlattener(obj=obj)
        out = flattener.get_denumerated().to_dict(orient='records')
        expected = []
        print(str(out))
        self.assertEqual(out == expected, True)

    def testGetDenumeratedNonAmbiguous(self):
        """
            Tests flattener with denumerated columns.
        """
        obj = { 
            'foo': 10, 
            'bar': 20, 
            'nested': { 
                'bar': [ [ 
                    { 'x': True }, 
                    { 'y': False } 
                ] ]
            } 
        }
        flattener = BoAmpsFlattener(obj=obj)
        out = flattener.get_denumerated().to_dict(orient='records')
        expected = [{
            'foo': 10, 
            'bar': 20, 
            'nested.bar.x': True, 
            'nested.bar.y': False
        }]
        print(str(out))
        self.assertEqual(out == expected, True)

    def testGetDenumeratedAmbiguousLong(self):
        """
            Tests flattener with denumerated columns.
        """
        with open(os.sep.join([ '..', 'examples', 'energy-report-example-1.json'])) as f:            
            obj = json.load(f)
            flattener = BoAmpsFlattener(obj=obj)
            out = flattener.get_denumerated().to_dict(orient='records')
            self.assertEqual(len(out) > 0, True)
