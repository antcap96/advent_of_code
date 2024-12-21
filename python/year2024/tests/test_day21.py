from year2024.day21 import solution

test_input1 = """
029A
980A
179A
456A
379A"""


def test_answer1():
    assert solution.calculate_answer1(solution.parse_input(test_input1)) == "126384"
