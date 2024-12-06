from __future__ import annotations


class Matrix[T]:
    def __init__(self, data: list[list[T]]) -> None:
        self.data = data

    @staticmethod
    def from_list_of_list[U](data: list[list[U]]) -> Matrix[U]:
        return Matrix(data)

    def __getitem__(self, key: tuple[int, int]) -> T:
        return self.data[key[0]][key[1]]

    def __setitem__(self, key: tuple[int, int], value: T) -> None:
        self.data[key[0]][key[1]] = value

    def contains_index(self, idx: tuple[int, int]) -> bool:
        return 0 <= idx[0] < len(self.data) and 0 <= idx[1] < len(self.data[0])

    def get[D](self, key: tuple[int, int], default: D = None) -> T | D:
        if self.contains_index(key):
            return self[key]
        else:
            return default
