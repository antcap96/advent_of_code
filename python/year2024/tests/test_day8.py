from year2024.day8 import solution

test_input = """
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............"""


def test_answer1():
    assert solution.calculate_answer1(solution.parse_input(test_input)) == "14"


def test_answer2():
    assert solution.calculate_answer2(solution.parse_input(test_input)) == "34"
