from __future__ import annotations

import functools
import heapq
from collections import defaultdict
from dataclasses import dataclass, field
from enum import Enum
from typing import TYPE_CHECKING

from year2024.utils.aoc import Solution
from year2024.utils.matrix import Matrix

if TYPE_CHECKING:
    import _typeshed

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


class HeapQueue[T: _typeshed.SupportsDunderLT]:
    """HeapQueue based on heapq"""

    def __init__(self) -> None:
        self.queue: list[T] = []

    def pop(self) -> T:
        return heapq.heappop(self.queue)

    def push(self, value: T) -> None:
        return heapq.heappush(self.queue, value)


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
    queue: HeapQueue[QueueItem] = HeapQueue()
    visited: set[tuple[Point, Direction]] = set()
    queue.push(QueueItem(0, start, Direction.East))

    while True:
        item = queue.pop()

        if (item.at, item.direction) in visited:
            continue
        else:
            visited.add((item.at, item.direction))

        if item.at == target:
            return item.cost

        infront = next_position(item.at, item.direction)
        if maze.get(infront) == Cell.Floor:
            queue.push(QueueItem(item.cost + 1, infront, item.direction))
        queue.push(QueueItem(item.cost + 1000, item.at, item.direction.left()))
        queue.push(QueueItem(item.cost + 1000, item.at, item.direction.right()))


def visited_points(
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
    queue: HeapQueue[QueueItem2] = HeapQueue()
    visited_from: defaultdict[
        tuple[Point, Direction], list[tuple[Point, Direction]]
    ] = defaultdict(list)
    cost_map: dict[tuple[Point, Direction], int] = {}
    queue.push(QueueItem2(0, start, None, Direction.East))

    target_cost = None

    while True:
        item = queue.pop()
        print(item.cost)
        if target_cost is not None and item.cost > target_cost:
            # Finished searching
            valid_tagets = [(target, direction) for direction in list(Direction)]
            return len(
                functools.reduce(
                    set.union, [visited_points(visited_from, t) for t in valid_tagets]
                )
            )

        at_pair = (item.at, item.direction)
        if at_pair in cost_map and item.cost > cost_map[at_pair]:
            continue

        cost_map[at_pair] = item.cost
        if item.prev is not None:
            visited_from[at_pair].append(item.prev)

        if item.at == target:
            target_cost = item.cost
            continue

        next_ = [
            QueueItem2(item.cost + 1, next_position(*at_pair), at_pair, item.direction),
            QueueItem2(item.cost + 1000, item.at, at_pair, item.direction.left()),
            QueueItem2(item.cost + 1000, item.at, at_pair, item.direction.right()),
        ]

        for next_item in next_:
            next_pair = (next_item.at, next_item.direction)
            if maze.get(next_item.at) == Cell.Floor and (
                next_pair not in cost_map or next_item.cost <= cost_map[next_pair]
            ):
                cost_map[next_pair] = next_item.cost
                queue.push(next_item)


def calculate_answer1(data: Data) -> int:
    return disjktra(data.maze, data.reindeer, data.exit)


def calculate_answer2(data: Data) -> int:
    return disjktra2(data.maze, data.reindeer, data.exit)


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=16)
