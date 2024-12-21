from collections.abc import Generator
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


numeric_pad: dict[Point, Numeric] = {
    (0, 0): Numeric.N7,
    (0, 1): Numeric.N8,
    (0, 2): Numeric.N9,
    (1, 0): Numeric.N4,
    (1, 1): Numeric.N5,
    (1, 2): Numeric.N6,
    (2, 0): Numeric.N1,
    (2, 1): Numeric.N2,
    (2, 2): Numeric.N3,
    (3, 1): Numeric.N0,
    (3, 2): Numeric.A,
}

reverse_numeric_pad = {v: k for k, v in numeric_pad.items()}

directional_pad: dict[Point, Direction] = {
    (0, 1): Direction.Up,
    (0, 2): Direction.A,
    (1, 0): Direction.Left,
    (1, 1): Direction.Down,
    (1, 2): Direction.Right,
}
reverse_directional_pad = {v: k for k, v in directional_pad.items()}


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


def paths_aux(start: Point, end: Point, deny: list[Point]) -> list[list[Direction]]:
    output: list[list[Direction]] = []
    if start == end:
        return [[]]
    if end[0] > start[0]:
        if north(end) not in deny:
            paths = paths_aux(start, north(end), deny)
            for path in paths:
                path.append(Direction.Down)
            output.extend(paths)
    elif end[0] < start[0]:
        if south(end) not in deny:
            paths = paths_aux(start, south(end), deny)
            for path in paths:
                path.append(Direction.Up)
            output.extend(paths)
    if end[1] > start[1]:
        if west(end) not in deny:
            paths = paths_aux(start, west(end), deny)
            for path in paths:
                path.append(Direction.Right)
            output.extend(paths)
    elif end[1] < start[1]:
        if east(end) not in deny:
            paths = paths_aux(start, east(end), deny)
            for path in paths:
                path.append(Direction.Left)
            output.extend(paths)

    return output


def add_a(x: list[Direction]):
    x.append(Direction.A)
    return x


def numeric_to_directional_aux(
    digit1: Numeric,
    digit2: Numeric,
) -> Generator[list[Direction]]:
    start = reverse_numeric_pad[digit1]
    end = reverse_numeric_pad[digit2]

    yield from map(add_a, paths_aux(start, end, deny=[(3, 0)]))


def directional_to_directional_aux(
    direction1: Direction,
    direction2: Direction,
) -> Generator[list[Direction]]:
    start = reverse_directional_pad[direction1]
    end = reverse_directional_pad[direction2]

    yield from map(add_a, paths_aux(start, end, deny=[(0, 0)]))


@cache
def directional_to_directional_aux_cost(
    direction1: Direction, direction2: Direction, level: int
) -> int:
    paths = directional_to_directional_aux(direction1, direction2)
    if level == 0:
        return min(len(path) for path in paths)

    min_cost = None
    for path in paths:
        cost = 0
        for direction1, direction2 in zip(itertools.chain([Direction.A], path), path):
            cost += directional_to_directional_aux_cost(
                direction1, direction2, level - 1
            )
        if min_cost is None or cost < min_cost:
            min_cost = cost

    assert min_cost is not None

    return min_cost


def chunk2(digit1: Numeric, digit2: Numeric, depth: int) -> int:
    part1 = numeric_to_directional_aux(digit1, digit2)

    min_cost = None
    for path in part1:
        cost = 0
        for direction1, direction2 in zip(itertools.chain([Direction.A], path), path):
            cost += directional_to_directional_aux_cost(
                direction1, direction2, depth - 1
            )
        if min_cost is None or cost < min_cost:
            min_cost = cost

    assert min_cost is not None

    return min_cost


def do_thing2(digits: list[Numeric], depth: int) -> int:
    output = 0
    for digit1, digit2 in zip(itertools.chain([Numeric.A], digits), digits):
        output += chunk2(digit1, digit2, depth)

    return output


def numeric_of_code(code: list[Numeric]) -> int:
    num_str = "".join(c.value for c in code if c != Numeric.A)
    return int(num_str)


def complexity2(code: list[Numeric], depth: int) -> int:
    return numeric_of_code(code) * do_thing2(code, depth)


def calculate_answer1(codes: list[list[Numeric]]) -> str:
    return str(sum(complexity2(code, depth=2) for code in codes))


def calculate_answer2(codes: list[list[Numeric]]) -> str:
    return str(sum(complexity2(code, depth=25) for code in codes))


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=21)
