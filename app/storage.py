
class LocalStorage:
    # TODO: add interface and type
    # TODO: could be implemented as dataclass

    def __init__(self, path: str) -> None:
        self.path = path


class StorageFactory:

    def __init__(self) -> None:
        pass

    def get_storage(self, storage_type: str, path: str):
        if storage_type == "s3":
            return self.__get_s3_storage(path)
        elif storage_type == "local":
            return self.__get_local_storage(path)
        else:
            raise ValueError("Unknown storage type! Please implement it first.")

    def __get_s3_storage(self, path: str):
        ...

    def __get_local_storage(self, path: str):
        return LocalStorage(path=path)
