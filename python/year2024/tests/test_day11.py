from year2024.day11 import solution

test_input = "125 17"


def test_answer1():
    assert solution.calculate_answer1(solution.parse_input(test_input)) == 55312


def test_answer2():
    assert (
        solution.calculate_answer2(solution.parse_input(test_input)) == 65601038650482
    )
