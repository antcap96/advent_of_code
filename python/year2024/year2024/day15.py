import copy
from dataclasses import dataclass
from enum import Enum

from year2024.utils.aoc import Solution
from year2024.utils.matrix import Matrix

type Point = tuple[int, int]


class Direction(Enum):
    North = "^"
    East = ">"
    South = "v"
    West = "<"


class Cell(Enum):
    Floor = "."
    Box = "O"
    Wall = "#"


class ExpandedCell(Enum):
    Floor = "."
    BoxLeft = "["
    BoxRight = "]"
    Wall = "#"


@dataclass
class Map:
    robot: Point
    map: Matrix[Cell]


@dataclass
class ExpandedMap:
    robot: Point
    map: Matrix[ExpandedCell]


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


def parse_direction(string: str) -> list[Direction]:
    output: list[Direction] = []
    for c in string:
        match c:
            case "\n":
                continue
            case Direction.North.value:
                output.append(Direction.North)
            case Direction.East.value:
                output.append(Direction.East)
            case Direction.South.value:
                output.append(Direction.South)
            case Direction.West.value:
                output.append(Direction.West)
            case _:
                raise ValueError(f"Unexpected char '{c}'")

    return output


def parse_map(string: str) -> Map:
    map: list[list[Cell]] = []
    robot_position = None
    for i, row in enumerate(string.splitlines()):
        map_row: list[Cell] = []
        for j, c in enumerate(row):
            match c:
                case "@":
                    robot_position = (i, j)
                    map_row.append(Cell.Floor)
                case Cell.Floor.value:
                    map_row.append(Cell.Floor)
                case Cell.Wall.value:
                    map_row.append(Cell.Wall)
                case Cell.Box.value:
                    map_row.append(Cell.Box)
                case _:
                    raise ValueError(f"Unexpected char '{c}'")

        map.append(map_row)

    assert robot_position is not None

    return Map(robot_position, Matrix.from_list_of_list(map))


def parse_input(string: str) -> tuple[Map, list[Direction]]:
    map_str, directions_str = string.strip().split("\n\n")

    return (parse_map(map_str), parse_direction(directions_str))


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


def step(map: Map, direction: Direction) -> Map:
    pos = next_position(map.robot, direction)
    match map.map.get(pos):
        case Cell.Floor:
            return Map(pos, map.map)
        case Cell.Wall:
            return map
        case None:
            raise ValueError("out of bounds")
        case Cell.Box:
            pass
    first_box = pos
    while (pos := next_position(pos, direction)) and map.map.get(pos) == Cell.Box:
        continue

    if map.map.get(pos) == Cell.Floor:
        map.map[pos] = Cell.Box
        map.map[first_box] = Cell.Floor
        return Map(first_box, map.map)
    else:
        return map


def gps_score(map: Matrix[Cell]) -> int:
    score = 0
    for i in range(map.rows):
        for j in range(map.cols):
            if map[i, j] == Cell.Box:
                score += 100 * i + j
    return score


def print_map(map: Map | ExpandedMap) -> None:
    s = ""
    for i in range(map.map.rows):
        for j in range(map.map.cols):
            if map.robot == (i, j):
                s += "@"
            else:
                s += map.map[i, j].value

        s += "\n"

    print(s)


def calculate_answer1(data: tuple[Map, list[Direction]]) -> int:
    map, directions = data
    map = copy.deepcopy(map)
    for direction in directions:
        map = step(map, direction)

    return gps_score(map.map)


def expand_map(map: Map) -> ExpandedMap:
    expanded_map: list[list[ExpandedCell]] = []
    for i in range(map.map.rows):
        row: list[ExpandedCell] = []
        for j in range(map.map.cols):
            match map.map[i, j]:
                case Cell.Floor:
                    row.append(ExpandedCell.Floor)
                    row.append(ExpandedCell.Floor)
                case Cell.Box:
                    row.append(ExpandedCell.BoxLeft)
                    row.append(ExpandedCell.BoxRight)
                case Cell.Wall:
                    row.append(ExpandedCell.Wall)
                    row.append(ExpandedCell.Wall)
        expanded_map.append(row)

    return ExpandedMap(
        (map.robot[0], 2 * map.robot[1]), Matrix.from_list_of_list(expanded_map)
    )


def step2(map: ExpandedMap, direction: Direction) -> ExpandedMap:
    pos = next_position(map.robot, direction)
    match map.map.get(pos):
        case ExpandedCell.Floor:
            return ExpandedMap(pos, map.map)
        case ExpandedCell.Wall:
            return map
        case None:
            raise ValueError("out of bounds")
        case ExpandedCell.BoxLeft:
            box_pos = pos
        case ExpandedCell.BoxRight:
            box_pos = west(pos)

    if can_move_boxes(map.map, box_pos, direction):
        move_boxes(map.map, box_pos, direction)
        return ExpandedMap(pos, map.map)
    else:
        return map


def can_move_boxes(map: Matrix[ExpandedCell], box_pos: Point, direction: Direction):
    assert map[box_pos] == ExpandedCell.BoxLeft

    pos = next_position(box_pos, direction)
    match map.get(pos):
        case None:
            raise ValueError("out of bounds")
        case ExpandedCell.Floor:
            pass
        case ExpandedCell.Wall:
            return False
        case ExpandedCell.BoxLeft:
            if not can_move_boxes(map, pos, direction):
                return False
        case ExpandedCell.BoxRight:
            if direction is not Direction.East and not can_move_boxes(
                map, west(pos), direction
            ):
                return False

    match map.get(east(pos)):
        case None:
            raise ValueError("out of bounds")
        case ExpandedCell.Floor:
            pass
        case ExpandedCell.Wall:
            return False
        case ExpandedCell.BoxLeft:
            if direction is not Direction.West and not can_move_boxes(
                map, east(pos), direction
            ):
                return False
        case ExpandedCell.BoxRight:
            # Checked above
            pass

    return True


def move_boxes(map: Matrix[ExpandedCell], box_pos: Point, direction: Direction):
    assert map[box_pos] == ExpandedCell.BoxLeft

    pos = next_position(box_pos, direction)
    match map.get(pos):
        case None:
            raise ValueError("checked before")
        case ExpandedCell.Floor:
            pass
        case ExpandedCell.Wall:
            raise ValueError("checked before")
        case ExpandedCell.BoxLeft:
            move_boxes(map, pos, direction)
        case ExpandedCell.BoxRight:
            if direction is not Direction.East:
                move_boxes(map, west(pos), direction)

    match map.get(east(pos)):
        case None:
            raise ValueError("checked before")
        case ExpandedCell.Floor:
            pass
        case ExpandedCell.Wall:
            raise ValueError("checked before")
        case ExpandedCell.BoxLeft:
            if direction is not Direction.West:
                move_boxes(map, east(pos), direction)
        case ExpandedCell.BoxRight:
            # Checked above
            pass

    map[box_pos] = ExpandedCell.Floor
    map[east(box_pos)] = ExpandedCell.Floor
    map[pos] = ExpandedCell.BoxLeft
    map[east(pos)] = ExpandedCell.BoxRight


def gps_score2(map: Matrix[ExpandedCell]) -> int:
    score = 0
    for i in range(map.rows):
        for j in range(map.cols):
            if map[i, j] == ExpandedCell.BoxLeft:
                score += 100 * i + j
    return score


def calculate_answer2(data: tuple[Map, list[Direction]]) -> int:
    map, directions = data
    map = expand_map(map)
    for direction in directions:
        map = step2(map, direction)

    return gps_score2(map.map)


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=15)
