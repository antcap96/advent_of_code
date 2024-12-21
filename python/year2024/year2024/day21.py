from collections.abc import Callable, Iterator
from dataclasses import dataclass
from enum import Enum
from functools import cache
import itertools
from year2024.utils.aoc import Solution

type Point = tuple[int, int]


class Numeric(Enum):
    A = "A"
    N0 = "0"
    N1 = "1"
    N2 = "2"
    N3 = "3"
    N4 = "4"
    N5 = "5"
    N6 = "6"
    N7 = "7"
    N8 = "8"
    N9 = "9"


class Direction(Enum):
    A = "A"
    Left = "<"
    Right = ">"
    Up = "^"
    Down = "v"


@dataclass
class KeyPad[T]:
    map: dict[T, Point]
    inside: Callable[[Point], bool]


numeric_pad = KeyPad(
    {
        Numeric.N7: (0, 0),
        Numeric.N8: (0, 1),
        Numeric.N9: (0, 2),
        Numeric.N4: (1, 0),
        Numeric.N5: (1, 1),
        Numeric.N6: (1, 2),
        Numeric.N1: (2, 0),
        Numeric.N2: (2, 1),
        Numeric.N3: (2, 2),
        Numeric.N0: (3, 1),
        Numeric.A: (3, 2),
    },
    lambda x: x != (3, 0),
)


directional_pad = KeyPad(
    {
        Direction.Up: (0, 1),
        Direction.A: (0, 2),
        Direction.Left: (1, 0),
        Direction.Down: (1, 1),
        Direction.Right: (1, 2),
    },
    lambda x: x != (0, 0),
)


def parse_numeric(string: str) -> Numeric:
    return Numeric(string)


def parse_input(string: str) -> list[list[Numeric]]:
    lines = string.strip().splitlines()
    return [list(map(parse_numeric, line)) for line in lines]


def north(point: Point) -> Point:
    i, j = point
    return (i - 1, j)


def east(point: Point) -> Point:
    i, j = point
    return (i, j + 1)


def south(point: Point) -> Point:
    i, j = point
    return (i + 1, j)


def west(point: Point) -> Point:
    i, j = point
    return (i, j - 1)


def paths_aux(
    start: Point, end: Point, inside: Callable[[Point], bool]
) -> list[list[Direction]]:
    output: list[list[Direction]] = []
    if start == end:
        return [[]]

    def extend(next: Point, direction: Direction) -> None:
        if inside(next):
            paths = paths_aux(start, next, inside)
            for path in paths:
                path.append(direction)
            output.extend(paths)

    if end[0] > start[0]:
        extend(north(end), Direction.Down)
    elif end[0] < start[0]:
        extend(south(end), Direction.Up)
    if end[1] > start[1]:
        extend(west(end), Direction.Right)
    elif end[1] < start[1]:
        extend(east(end), Direction.Left)

    return output


def directions[T](keypad: KeyPad[T], start: T, end: T) -> list[list[Direction]]:
    start_point = keypad.map[start]
    end_point = keypad.map[end]

    paths = paths_aux(start_point, end_point, inside=keypad.inside)
    for path in paths:
        path.append(Direction.A)

    return paths


def numeric_iterate_pair(numeric: list[Numeric]) -> Iterator[tuple[Numeric, Numeric]]:
    return zip(itertools.chain([Numeric.A], numeric), numeric)


def directional_iterate_pairs(
    directions: list[Direction],
) -> Iterator[tuple[Direction, Direction]]:
    return zip(itertools.chain([Direction.A], directions), directions)


@cache
def cost_pair[T: Direction | Numeric](t1: T, t2: T, depth: int) -> int:
    if isinstance(t1, Direction) and isinstance(t2, Direction):
        paths = directions(directional_pad, t1, t2)
    elif isinstance(t1, Numeric) and isinstance(t2, Numeric):
        paths = directions(numeric_pad, t1, t2)
    else:
        raise ValueError("t1 and t2 must be of the same type")
    if depth == 0:
        return min(len(path) for path in paths)

    min_cost = None
    for path in paths:
        cost = 0
        for direction1, direction2 in directional_iterate_pairs(path):
            cost += cost_pair(direction1, direction2, depth - 1)
        if min_cost is None or cost < min_cost:
            min_cost = cost

    assert min_cost is not None

    return min_cost


def total_cost(digits: list[Numeric], depth: int) -> int:
    output = 0
    for digit1, digit2 in numeric_iterate_pair(digits):
        output += cost_pair(digit1, digit2, depth)

    return output


def numeric_of_code(code: list[Numeric]) -> int:
    num_str = "".join(c.value for c in code if c != Numeric.A)
    return int(num_str)


def complexity(code: list[Numeric], depth: int) -> int:
    return numeric_of_code(code) * total_cost(code, depth)


def calculate_answer1(codes: list[list[Numeric]]) -> str:
    return str(sum(complexity(code, depth=2) for code in codes))


def calculate_answer2(codes: list[list[Numeric]]) -> str:
    return str(sum(complexity(code, depth=25) for code in codes))


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=21)
