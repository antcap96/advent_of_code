from year2024.day12 import solution

test_input = """
RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
"""


def test_answer1():
    assert solution.calculate_answer1(solution.parse_input(test_input)) == "1930"


def test_answer2():
    assert solution.calculate_answer2(solution.parse_input(test_input)) == "1206"
