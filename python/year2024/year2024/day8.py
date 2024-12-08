from __future__ import annotations

import functools
import itertools
from collections import defaultdict
from collections.abc import Callable
from dataclasses import dataclass
from typing import Generator

from year2024.utils.aoc import Solution


@dataclass(unsafe_hash=True)
class Vector:
    x: int
    y: int

    def __add__(self, other: object) -> Vector:
        if isinstance(other, Vector):
            return Vector(self.x + other.x, self.y + other.y)
        else:
            return NotImplemented

    def __sub__(self, other: object) -> Vector:
        if isinstance(other, Vector):
            return Vector(self.x - other.x, self.y - other.y)
        else:
            return NotImplemented

    def __mul__(self, factor: object) -> Vector:
        if isinstance(factor, int):
            return Vector(self.x * factor, self.y * factor)
        else:
            return NotImplemented


def is_inside(a: Vector, b: Vector) -> bool:
    assert b.x > 0 and b.y > 0

    return 0 <= a.x < b.x and 0 <= a.y < b.y


@dataclass
class Data:
    antennas: dict[str, list[Vector]]
    size: Vector


def is_antenna(c: str) -> bool:
    return "0" <= c <= "9" or "a" <= c <= "z" or "A" <= c <= "Z"


def parse_input(string: str) -> Data:
    lines = string.strip().splitlines()
    output: defaultdict[str, list[Vector]] = defaultdict(list)
    for i, line in enumerate(lines):
        for j, c in enumerate(line):
            if is_antenna(c):
                output[c].append(Vector(i, j))

    return Data(output, Vector(len(lines), len(lines[0])))


def antinodes1(antennas: list[Vector], size: Vector) -> Generator[Vector]:
    for a, b in itertools.product(antennas, antennas):
        if a == b:
            continue
        point = a + (b - a) * 2
        if is_inside(point, size):
            yield point


def count_antinodes(
    data: Data, antinodes: Callable[[list[Vector], Vector], Generator[Vector]]
):
    solutions: set[Vector] = set()

    for antennas in data.antennas.values():
        solutions.update(antinodes(antennas, data.size))

    return len(solutions)


def antinodes2(antennas: list[Vector], size: Vector) -> Generator[Vector]:
    for a, b in itertools.product(antennas, antennas):
        if a == b:
            continue
        delta = b - a
        i = 0
        while is_inside(point := b + delta * i, size):
            i += 1
            yield point


solution = Solution(
    parse_input,
    calculate_answer1=functools.partial(count_antinodes, antinodes=antinodes1),
    calculate_answer2=functools.partial(count_antinodes, antinodes=antinodes2),
    day=8,
)


if __name__ == "__main__":
    solution.solve(None)
