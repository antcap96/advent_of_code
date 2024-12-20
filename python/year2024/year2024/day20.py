from collections import deque
from collections.abc import Generator
from dataclasses import dataclass
import functools
from year2024.utils.aoc import Solution
from year2024.utils.matrix import Matrix

type Point = tuple[int, int]


@dataclass
class Data:
    maze: Matrix[bool]
    start: Point
    end: Point


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


def parse_input(string: str) -> Data:
    lines = string.strip().splitlines()
    start = None
    end = None

    maze = []
    for i, line in enumerate(lines):
        maze_row = []
        for j, c in enumerate(line):
            match c:
                case "S":
                    start = (i, j)
                    maze_row.append(False)
                case "E":
                    end = (i, j)
                    maze_row.append(False)
                case ".":
                    maze_row.append(False)
                case "#":
                    maze_row.append(True)
                case _:
                    raise ValueError(f"Unexpected char {c}")
            pass
        maze.append(maze_row)

    assert start is not None
    assert end is not None

    return Data(Matrix.from_list_of_list(maze), start, end)


# @dataclass(unsafe_hash=True, frozen=True)
# class State:
#     at: Point
#     cheat: int


@dataclass
class Path:
    score: int
    cheat: tuple[Point, Point]


def bfs(maze: Matrix[bool], start: Point) -> Matrix[int | None]:
    # Typing is sad
    x: list[None | int] = [None]
    distances: Matrix[int | None] = Matrix(
        x * maze.cols * maze.rows, maze.rows, maze.cols
    )
    distances[start] = 0

    to_visit: list[Point] = [start]
    distance = 1
    while len(to_visit) > 0:
        next_to_visit = []
        for at in to_visit:
            neighboors = [
                east(at),
                west(at),
                north(at),
                south(at),
            ]

            for neighboor in neighboors:
                if maze.get(neighboor) is False and distances[neighboor] is None:
                    next_to_visit.append(neighboor)
                    distances[neighboor] = distance

        to_visit = next_to_visit
        distance += 1

    return distances


def ashortcuts(
    distances: Matrix[int | None],
    start: Point,
    max_distance: int,
    min_score: int = 100,
) -> Generator[int]:
    queue = deque([start])
    while len(queue) > 0:
        start = queue.pop()
        score = distances[start]
        assert score is not None

        # for d1, d2 in itertools.combinations_with_replacement(directions, 2):
        for point, distance in within(start, max_distance):
            distance_shortcut = distances.get(point)
            if (
                distance_shortcut is not None
                and distance_shortcut - score - distance >= min_score
            ):
                yield distance_shortcut - score - distance

        directions = [north, east, south, west]
        for direction in directions:
            next = direction(start)
            if distances.get(next) == score - 1:
                queue.append(next)


def within(point: Point, distance: int) -> Generator[tuple[Point, int]]:
    for i in range(-distance, distance + 1):
        for j in range(-distance + abs(i), distance + 1 - abs(i)):
            yield ((point[0] + i, point[1] + j), abs(i) + abs(j))


def count_shorcuts(data: Data, shortcut_distance: int, min_score: int) -> str:
    distances = bfs(data.maze, start=data.end)
    shortcuts = ashortcuts(distances, data.start, shortcut_distance, min_score)

    return str(len(list(shortcuts)))


solution = Solution(
    parse_input,
    functools.partial(count_shorcuts, shortcut_distance=2, min_score=100),
    functools.partial(count_shorcuts, shortcut_distance=20, min_score=100),
    day=20,
)
