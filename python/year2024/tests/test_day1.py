from year2024.day1 import solution

test_input = """
3   4
4   3
2   5
1   3
3   9
3   3
"""


def test_answer1():
    assert solution.calculate_answer1(solution.parse_input(test_input)) == "11"


def test_answer2():
    assert solution.calculate_answer2(solution.parse_input(test_input)) == "31"
