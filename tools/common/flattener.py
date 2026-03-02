##############################################################
# BoAmps - an open-data initiative hosted by Boavizta        #
# (A)I (M)easures of (P)ower consumption (S)haring           #
##############################################################

import flatdict
import pandas as pd

SEPARATOR = '.'


class BoAmpsFlattener:

    __raw: list[dict] = None

    __denumerated: list[dict] = None

    def __init__(self, obj=None):
        """
            The initial object can be a single item or a list of items
        """
        if obj is None:
            self.__raw = []
            return
        if type(obj) == dict:
            self.__raw = [dict(flatdict.FlatterDict(obj, delimiter=SEPARATOR))]
        elif type(obj) == list:
            self.__raw = [dict(flatdict.FlatterDict(
                elt, delimiter=SEPARATOR)) for elt in obj]
        else:
            raise Exception('Bad object type')

    def add(self, obj):
        if obj is None:
            return
        self.__raw.append(dict(flatdict.FlatterDict(obj, delimiter=SEPARATOR)))

    def get_raw(self) -> pd.DataFrame:
        if self.__raw is None:
            self.__denumerated = []
            return None
        return pd.DataFrame(self.__raw)

    def get_denumerated(self) -> pd.DataFrame:
        """
            Convert the raw list into a list without digits in the key and detect ambiguous occurrences
        """
        if self.__raw is None:
            self.__denumerated = []
            return None
        errors = []
        self.__denumerated = []
        for i in range(len(self.__raw)):
            keys = self.__raw[i].keys()
            keys_denumerated = [SEPARATOR.join([
                elt for elt in str(key).split(SEPARATOR) if not elt.isnumeric()
            ]) for key in keys]  # remove numeric elements from substrings
            keys_denumerated_unique = list(set(keys_denumerated))
            if len(keys_denumerated_unique) < len(keys_denumerated):
                diff = list(set(keys).difference(set(keys_denumerated)))
                ambiguous = list(set([SEPARATOR.join([
                    elt for elt in str(key).split(SEPARATOR) if not elt.isnumeric()
                ]) for key in diff]))
                errors.append('At line {} ambiguous denumerated keys:\n\n{}\n\nfrom raw keys:\n\n{}\n'.format(
                    str(i),
                    '\n'.join(sorted(ambiguous)),
                    '\n'.join(sorted(diff))
                ))
                continue
            self.__denumerated.append(
                dict(zip(keys_denumerated, self.__raw[i].values())))
        print('Processed correctly {} lines out of {}'.format(
            str(len(self.__denumerated)), str(len(self.__raw))))
        for err in errors:
            print('Error: {}'.format(err))
        return pd.DataFrame(self.__denumerated)
