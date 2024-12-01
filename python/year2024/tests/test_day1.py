from year2024.day1 import parse_input, calculate_answer1, calculate_answer2

test_input = """
3   4
4   3
2   5
1   3
3   9
3   3
"""

def test_answer1():
    assert calculate_answer1(parse_input(test_input)) == 11

def test_answer2():
    assert calculate_answer2(parse_input(test_input)) == 31