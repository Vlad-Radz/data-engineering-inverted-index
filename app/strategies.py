"""
Strategy pattern used.
"""

from abc import ABC, abstractmethod

from pyspark.context import SparkContext

from utils import flatten


NOT_IMPLEMENTED = "You should implement this."


class InvertedIndexStrategy(ABC):

    def __init__(self,
                    storage: object):
        self.storage = storage

    @abstractmethod
    def index_data(self):
        raise NotImplementedError(NOT_IMPLEMENTED)

    @abstractmethod
    def print_output(self) -> None:
        raise NotImplementedError(NOT_IMPLEMENTED)

    @abstractmethod
    def reindex_data(self) -> None:
        raise NotImplementedError(NOT_IMPLEMENTED)


class PysparkStrategy(InvertedIndexStrategy):

    def __init__(self, storage: object):
        super(PysparkStrategy, self).__init__(storage)
        self.sc = SparkContext('local', 'inverted_index')  # name of the app and execution mode should go to variables

    def index_data(self):
        # TODO: partition by letter - less shuffling (right?)
        # TODO: no need to parallelize - or?

        rdd_files_contents = self.sc.wholeTextFiles(self.storage.path)

        self.rdd = rdd_files_contents.\
                mapValues(lambda k: k.split("\n")).\
                flatMap(lambda x: [(x[0], w) for w in x[1]]).\
                map(lambda x: (x[1], x[0])).\
                reduceByKey(lambda a,b: [a, b]).\
                map(lambda x: (x[0], flatten(x[1]))).\
                map(lambda x: (x[0], flatten(x[1]))).\
                map(lambda x: (x[0], flatten(x[1]))).\
                map(lambda x: (x[0], [n.split("/")[2] for n in x[1]]))
        # TODO: quick fix: flattening needs to be done 3x - function needs to be adjusted

    def print_output(self) -> None:
        for i, x in enumerate(self.rdd.collect()):
            print(x)

    def reindex_data():
        ...


class DaskStrategy(InvertedIndexStrategy):
    # Just an example of what other implementation could exist
    ...


class RedisBitmapStrategy(InvertedIndexStrategy):
    # This possible implementation is described in README.md
    ...