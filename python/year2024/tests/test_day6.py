from year2024.day6 import parse_input, calculate_answer1, calculate_answer2

test_input = """
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."""


def test_answer1():
    assert calculate_answer1(parse_input(test_input)) == 41


def test_answer2():
    assert calculate_answer2(parse_input(test_input)) == 6
