
import unittest
from .flattener import BoAmpsFlattener

class BoAmpsFlattenerTest(unittest.TestCase):

    def testGetSpace(self):
        """Tests flattener.
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
        out = flattener.get_raw()
        expected = [ {'foo': 10, 'bar': 20, 'nested.foo.0': 3, 'nested.foo.1': 2, 'nested.foo.2': 1, 'nested.bar.0.0.x': True, 'nested.bar.0.1.y': False} ]
        print(str(out))
        self.assertEqual(out == expected, True)
