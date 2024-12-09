from year2024.day9 import solution

test_input = "2333133121414131402"


def test_answer1():
    assert solution.calculate_answer1(solution.parse_input(test_input)) == 1928


def test_answer2():
    assert solution.calculate_answer2(solution.parse_input(test_input)) == 2858
