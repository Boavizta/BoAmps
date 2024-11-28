import flatdict


class BoAmpsFlattener:

    __raw:list[dict] = None

    def __init__(self, obj=None):
        """
            The initial object can be a single item or a list of items
        """
        if obj is None:
            self.__raw = []
            return
        if type(obj) == dict:
            self.__raw = [ dict(flatdict.FlatterDict(obj, delimiter='.')) ]
        elif type(obj) == list:
            self.__raw = [ dict(flatdict.FlatterDict(elt, delimiter='.')) for elt in obj ]
        else:
            raise Exception('Bad object type')

    def add(self, obj):
        self.__raw.append(dict(flatdict.FlatterDict(obj, delimiter='.')))

    def get_raw(self) -> list[dict]:
        return self.__raw
    
    def get_denumerated(self) -> list[dict]:
        """
            Convert the raw list into a list without digits in the key and detect ambiguous occurrences
        """
        pass
        # TODO



