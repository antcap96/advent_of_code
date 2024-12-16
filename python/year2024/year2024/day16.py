from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass, field
from enum import Enum
import heapq

from year2024.utils.aoc import Solution
from year2024.utils.matrix import Matrix

type Point = tuple[int, int]


class Direction(Enum):
    North = "^"
    East = ">"
    South = "v"
    West = "<"

    def left(self) -> Direction:
        match self:
            case Direction.North:
                return Direction.West
            case Direction.East:
                return Direction.North
            case Direction.South:
                return Direction.East
            case Direction.West:
                return Direction.South

    def right(self) -> Direction:
        match self:
            case Direction.North:
                return Direction.East
            case Direction.East:
                return Direction.South
            case Direction.South:
                return Direction.West
            case Direction.West:
                return Direction.North

    def back(self) -> Direction:
        match self:
            case Direction.North:
                return Direction.South
            case Direction.East:
                return Direction.West
            case Direction.South:
                return Direction.North
            case Direction.West:
                return Direction.East


class Cell(Enum):
    Floor = "."
    Wall = "#"


@dataclass
class Data:
    reindeer: Point
    exit: Point
    maze: Matrix[Cell]


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


def parse_maze(string: str) -> Data:
    map: list[list[Cell]] = []
    start = None
    exit = None
    for i, row in enumerate(string.splitlines()):
        map_row: list[Cell] = []
        for j, c in enumerate(row):
            match c:
                case "S":
                    start = (i, j)
                    map_row.append(Cell.Floor)
                case Cell.Floor.value:
                    map_row.append(Cell.Floor)
                case Cell.Wall.value:
                    map_row.append(Cell.Wall)
                case "E":
                    exit = (i, j)
                    map_row.append(Cell.Floor)
                case _:
                    raise ValueError(f"Unexpected char '{c}'")

        map.append(map_row)

    assert start is not None
    assert exit is not None

    return Data(reindeer=start, exit=exit, maze=Matrix.from_list_of_list(map))


def parse_input(string: str) -> Data:
    return parse_maze(string.strip())


def next_position(point: Point, direction: Direction):
    match direction:
        case Direction.North:
            return north(point)
        case Direction.East:
            return east(point)
        case Direction.South:
            return south(point)
        case Direction.West:
            return west(point)


@dataclass(order=True)
class QueueItem:
    cost: int
    at: Point = field(compare=False)
    direction: Direction = field(compare=False)


def disjktra(maze: Matrix[Cell], start: Point, target: Point) -> int:
    queue: list[QueueItem] = []
    visited: set[tuple[Point, Direction]] = set()
    heapq.heappush(queue, QueueItem(0, start, Direction.East))

    while True:
        item = heapq.heappop(queue)

        if (item.at, item.direction) in visited:
            continue
        else:
            visited.add((item.at, item.direction))

        if item.at == target:
            return item.cost

        infront = next_position(item.at, item.direction)
        if maze.get(infront) == Cell.Floor:
            heapq.heappush(queue, QueueItem(item.cost + 1, infront, item.direction))
        heapq.heappush(
            queue, QueueItem(item.cost + 1000, item.at, item.direction.left())
        )
        heapq.heappush(
            queue, QueueItem(item.cost + 1000, item.at, item.direction.right())
        )


def exit_routine(
    visited_from: dict[tuple[Point, Direction], list[tuple[Point, Direction]]],
    last: tuple[Point, Direction],
) -> set[Point]:
    seen: set[tuple[Point, Direction]] = {last}
    queue = visited_from[last].copy()

    while len(queue) > 0:
        item = queue.pop()
        seen.add(item)
        queue.extend([x for x in visited_from[item] if x not in seen])

    return set(x[0] for x in seen)


@dataclass(order=True)
class QueueItem2:
    cost: int
    at: Point = field(compare=False)
    prev: tuple[Point, Direction] | None = field(compare=False)
    direction: Direction = field(compare=False)


def disjktra2(maze: Matrix[Cell], start: Point, target: Point) -> int:
    queue: list[QueueItem2] = []
    visited_from: defaultdict[
        tuple[Point, Direction], list[tuple[Point, Direction]]
    ] = defaultdict(list)
    visited: dict[tuple[Point, Direction], int] = {}
    heapq.heappush(queue, QueueItem2(0, start, None, Direction.East))

    while True:
        item = heapq.heappop(queue)
        print(item.cost)
        if (target, Direction.North) in visited or (
            target,
            Direction.East,
        ) in visited:
            if item.cost > min(
                visited.get((target, Direction.North), 99999999),
                visited.get((target, Direction.East), 99999999),
            ):
                return len(
                    exit_routine(visited_from, (target, Direction.North)).union(
                        exit_routine(visited_from, (target, Direction.East))
                    )
                )

        if (item.at, item.direction) in visited and item.cost > visited[
            (item.at, item.direction)
        ]:
            continue
        else:
            visited[(item.at, item.direction)] = item.cost
            if item.prev is not None:
                visited_from[(item.at, item.direction)].append(item.prev)

        infront = next_position(item.at, item.direction)
        if maze.get(infront) == Cell.Floor and (
            (infront, item.direction) not in visited
            or item.cost + 1 == visited[(infront, item.direction)]
        ):
            heapq.heappush(
                queue,
                QueueItem2(
                    item.cost + 1, infront, (item.at, item.direction), item.direction
                ),
            )
        if (
            item.at,
            item.direction.left(),
        ) not in visited or item.cost + 1000 == visited[
            (item.at, item.direction.left())
        ]:
            heapq.heappush(
                queue,
                QueueItem2(
                    item.cost + 1000,
                    item.at,
                    (item.at, item.direction),
                    item.direction.left(),
                ),
            )
        if (
            item.at,
            item.direction.right(),
        ) not in visited or item.cost + 1000 == visited[
            (item.at, item.direction.right())
        ]:
            heapq.heappush(
                queue,
                QueueItem2(
                    item.cost + 1000,
                    item.at,
                    (item.at, item.direction),
                    item.direction.right(),
                ),
            )


def calculate_answer1(data: Data) -> int:
    return disjktra(data.maze, data.reindeer, data.exit)


def calculate_answer2(data: Data) -> int:
    return disjktra2(data.maze, data.reindeer, data.exit)


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=16)
