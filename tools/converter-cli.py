##############################################################
# BoAmps - an open-data initiative hosted by Boavizta        #
# (A)I (M)easures of (P)ower consumption (S)haring           #
##############################################################

# Python command line to perform various conversions

import sys, getopt
from common.validator import BoAmpsValidator
from common.filesystem import open_json


def main(argv):

    # params
    mode = None     # records are in a file or in a document db (mongo)
    filename = None # file path to json file, if mode=file
    target = None   # target output format

    # handle CLI parameters
    try:
        opts, args = getopt.getopt(argv,'hm:f:t:', ['help', 'mode=', 'filename=', 'target='])
    except getopt.GetoptError as err:
        sys.exit(1)
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            print('Help will come soon.')
            sys.exit(0)
        elif opt in ('-m', '--mode'):
            mode = arg
        elif opt in ('-f', '--filename'):
            filename = arg
        elif opt in ('-t', '--target'):
            target = arg
               

    # Opening JSON Schema and JSON to test
    if filename is not None:
 
        instance = open_json(filename)
        validator = BoAmpsValidator()

        if (validator.is_valid(instance)):

            print('Your report has the right format!')
            # TODO

        else:

            errors = list(validator.iter_errors(instance))
            print( ''.join([
                        'The json file does not correspond to the schema, there are ', 
                        str(len(errors)), 
                        " errors:"
                    ])
            )
            
            # get all validation errors
            for err in errors:
                if err is None or not hasattr(err, 'json_path') or not hasattr(err, 'message'):
                    continue
                print(''.join([ 'Error on data: ', err.json_path, ' --> ', err.message ]))

if __name__ == '__main__':
    main(sys.argv[1:])
