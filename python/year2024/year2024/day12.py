from __future__ import annotations
from collections.abc import Callable
import itertools
from typing import TYPE_CHECKING

from year2024.utils.aoc import Solution
from year2024.utils.matrix import Matrix

if TYPE_CHECKING:
    import _typeshed


type Point = tuple[int, int]


def parse_input(string: str) -> Matrix[int]:
    lines = string.strip().splitlines()

    return Matrix.from_list_of_list([[ord(c) for c in line] for line in lines])


def north(point: Point) -> Point:
    return (point[0] - 1, point[1])


def east(point: Point) -> Point:
    return (point[0], point[1] + 1)


def south(point: Point) -> Point:
    return (point[0] + 1, point[1])


def west(point: Point) -> Point:
    return (point[0], point[1] - 1)


def get_region(gardens: Matrix[int], at: Point, visited: set[Point]) -> set[Point]:
    kind = gardens[at]
    visited.add(at)

    neighboors = [
        north(at),
        east(at),
        south(at),
        west(at),
    ]

    for neighboor in neighboors:
        if neighboor not in visited:
            if gardens.get(neighboor) == kind:
                get_region(gardens, neighboor, visited)

    return visited


def get_regions(gardens: Matrix[int]) -> list[set[Point]]:
    regions: list[set[Point]] = []
    visited: set[Point] = set()
    for garden in itertools.product(range(gardens.rows), range(gardens.rows)):
        if garden in visited:
            continue
        new_region = get_region(gardens, garden, set())
        visited.update(new_region)
        regions.append(new_region)

    return regions


def region_area(region: set[Point]) -> int:
    return len(region)


def region_perimiter(region: set[Point]) -> int:
    perimiter = 0

    for garden in region:
        neighboors = [
            north(garden),
            east(garden),
            south(garden),
            west(garden),
        ]
        for neighboor in neighboors:
            if neighboor not in region:
                perimiter += 1
    return perimiter


def region_sides(region: set[Point]) -> int:
    north_sides = count_region_side_in_one_direction(
        region,
        prev=west,
        facing=north,
        sort_key=lambda x: (x[0], x[1]),
    )

    east_sides = count_region_side_in_one_direction(
        region,
        prev=north,
        facing=east,
        sort_key=lambda x: (-x[1], x[0]),
    )

    south_sides = count_region_side_in_one_direction(
        region,
        prev=west,
        facing=south,
        sort_key=lambda x: (-x[0], x[1]),
    )

    west_sides = count_region_side_in_one_direction(
        region,
        prev=north,
        facing=west,
        sort_key=lambda x: (x[1], x[0]),
    )

    result = north_sides + east_sides + south_sides + west_sides

    return result


def count_region_side_in_one_direction[T: _typeshed.SupportsRichComparison](
    region: set[Point],
    prev: Callable[[Point], Point],
    facing: Callable[[Point], Point],
    sort_key: Callable[[Point], T],
) -> int:
    sorted_garderns = sorted(region, key=sort_key)

    sides = 0
    prev_garden = None
    side = False
    for garden in sorted_garderns:
        if prev_garden != prev(garden):
            if side:
                sides += 1
                side = False
        if facing(garden) in region:
            if side:
                sides += 1
                side = False
        else:
            side = True
        prev_garden = garden

    if side:
        sides += 1

    return sides


def calculate_answer1(gardens: Matrix[int]) -> int:
    regions = get_regions(gardens)

    return sum(region_area(region) * region_perimiter(region) for region in regions)


def calculate_answer2(gardens: Matrix[int]) -> int:
    regions = get_regions(gardens)

    return sum(region_area(region) * region_sides(region) for region in regions)


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=12)
