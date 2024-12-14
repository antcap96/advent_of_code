from collections import Counter
from dataclasses import dataclass
import functools
import operator
from typing import Iterator
from year2024.utils.aoc import Solution


type Point = tuple[int, int]


@dataclass
class Robot:
    position: Point
    velocity: Point

    def move(self, n: int, shape: Point) -> Point:
        next_x = (self.position[0] + n * self.velocity[0]) % shape[0]
        next_y = (self.position[1] + n * self.velocity[1]) % shape[1]

        return (next_x, next_y)


def parse_point(string: str) -> Point:
    x, y = string.split(",")
    return int(x), int(y)


def parse_robot(line: str) -> Robot:
    position_str, velocity_str = line.split(" ")
    return Robot(
        parse_point(position_str.removeprefix("p=")),
        parse_point(velocity_str.removeprefix("v=")),
    )


def parse_input(string: str) -> list[Robot]:
    lines = string.strip().splitlines()
    return [parse_robot(line) for line in lines]


def step(robots: list[Robot], n: int, shape: Point) -> list[Point]:
    return [robot.move(n, shape) for robot in robots]


def count_quadrants(positions: list[Point], shape: Point) -> tuple[int, int, int, int]:
    middle_x = shape[0] // 2
    middle_y = shape[1] // 2

    print(f"{middle_x=}")
    print(f"{middle_y=}")

    q1 = sum(
        1 if point[0] < middle_x and point[1] < middle_y else 0 for point in positions
    )
    q2 = sum(
        1 if point[0] < middle_x and point[1] > middle_y else 0 for point in positions
    )
    q3 = sum(
        1 if point[0] > middle_x and point[1] < middle_y else 0 for point in positions
    )
    q4 = sum(
        1 if point[0] > middle_x and point[1] > middle_y else 0 for point in positions
    )

    return (q1, q2, q3, q4)


def calculate_answer1(robots: list[Robot], shape: Point = (101, 103)) -> int:
    positions = step(robots, 100, shape)

    quadrants = count_quadrants(positions, shape)

    return functools.reduce(operator.mul, quadrants)


def print_image(positions: list[Point], shape: Point) -> None:
    img = [["."] * shape[0] for _ in range(shape[1])]
    for x, y in positions:
        img[y][x] = "O"

    print("\n".join("".join(row) for row in img))


def calculate_answer2(robots: list[Robot], shape: Point = (101, 103)) -> int:
    x_start, y_start = recurring_pattern(robots, shape)

    i = None
    for i in range(shape[0] * shape[1]):
        if (x_start + shape[0] * i) % shape[1] == y_start:
            break
    assert i is not None
    at = x_start + shape[0] * i

    positions = step(robots, at, shape)
    print_image(positions, shape)

    return at


def recurring_pattern(robots: list[Robot], shape: Point) -> tuple[int, int]:
    steps = [step(robots, i, shape) for i in range(max(shape))]
    x_max = most_clustered_index(
        map(lambda x: x[0], points) for points in steps[:shape[0]]
    )
    y_max = most_clustered_index(
        map(lambda x: x[1], points) for points in steps[:shape[1]]
    )

    return x_max, y_max


def most_clustered_index(list_of_indexes: Iterator[Iterator[int]]) -> int:
    max_index = 0
    max_cluster_count = 0
    for i, indexes in enumerate(list_of_indexes):
        counter = Counter(point for point in indexes)
        cluster_count = sum(sorted(counter.values(), reverse=True)[:10])
        if cluster_count > max_cluster_count:
            max_cluster_count = cluster_count
            max_index = i

    return max_index


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=14)
