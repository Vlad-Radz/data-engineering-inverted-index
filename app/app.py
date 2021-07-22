from typing import Type

from storage import StorageFactory
from strategies import InvertedIndexStrategy, PysparkStrategy



class Context:

    def __init__(self) -> None:
        pass

    def set_strategy(self, strategy: Type[InvertedIndexStrategy]):
        self.strategy = strategy

    def execute_strategy(self):
        self.strategy.index_data()
        self.strategy.print_output()


# app itself

input_path = 'file:///words_index/'
storage_type = 'local'

storage_factory = StorageFactory()
storage = storage_factory.get_storage(storage_type=storage_type, path=input_path)

strategy = PysparkStrategy(storage=storage)

context = Context()
context.set_strategy(strategy=strategy)
context.execute_strategy()
