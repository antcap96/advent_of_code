from year2024.day7 import parse_input, calculate_answer1, calculate_answer2

test_input = """
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20"""


def test_answer1():
    assert calculate_answer1(parse_input(test_input)) == 3749


def test_answer2():
    assert calculate_answer2(parse_input(test_input)) == 11387