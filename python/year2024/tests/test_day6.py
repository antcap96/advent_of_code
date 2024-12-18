from year2024.day6 import solution

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
    assert solution.calculate_answer1(solution.parse_input(test_input)) == "41"


def test_answer2():
    assert solution.calculate_answer2(solution.parse_input(test_input)) == "6"
