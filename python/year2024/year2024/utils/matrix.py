from __future__ import annotations


class Matrix[T]:
    def __init__(self, data: list[T], rows: int, cols: int) -> None:
        self.data = data
        self.rows = rows
        self.cols = cols

    @staticmethod
    def from_list_of_list[U](data: list[list[U]]) -> Matrix[U]:
        flatten: list[U] = []
        for row in data:
            flatten.extend(row)

        return Matrix(flatten, len(data), len(data[0]))

    def _unsafe_getitem(self, key: tuple[int, int]) -> T:
        return self.data[key[0] * self.cols + key[1]]

    def __getitem__(self, key: tuple[int, int]) -> T:
        if self.contains_index(key):
            return self._unsafe_getitem(key)
        else:
            raise IndexError(f"Matrix doesn't contain index {key}")

    def __setitem__(self, key: tuple[int, int], value: T) -> None:
        if self.contains_index(key):
            self.data[key[0] * self.cols + key[1]] = value
        else:
            raise IndexError(f"Matrix doesn't contain index {key}")

    def contains_index(self, idx: tuple[int, int]) -> bool:
        return 0 <= idx[0] < self.rows and 0 <= idx[1] < self.cols

    def get[D](self, key: tuple[int, int], default: D = None) -> T | D:
        if self.contains_index(key):
            return self._unsafe_getitem(key)
        else:
            return default
