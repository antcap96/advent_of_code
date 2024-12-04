from year2024.day2 import parse_input, calculate_answer1, calculate_answer2

test_input = """
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"""


def test_answer1():
    assert calculate_answer1(parse_input(test_input)) == 2


def test_answer2():
    assert calculate_answer2(parse_input(test_input)) == 4


def test_answer2_extra():
    # All correct
    assert calculate_answer2(parse_input("1 2 3 4 5")) == 1
    assert calculate_answer2(parse_input("5 4 3 2 1")) == 1
    # One number wrong with 2 wrong deltas
    assert calculate_answer2(parse_input("1 2 10 3 4")) == 1
    assert calculate_answer2(parse_input("4 3 10 2 1")) == 1
    # Incorrect first
    assert calculate_answer2(parse_input("0 3 2 1 0")) == 1
    # Incorrect last
    assert calculate_answer2(parse_input("4 3 2 1 10")) == 1
    # One number wrong with 1 wrong delta
    assert calculate_answer2(parse_input("4 3 1 1 0")) == 1
    # Two numbers wrong
    assert calculate_answer2(parse_input("1 2 10 3 10")) == 0
    assert calculate_answer2(parse_input("4 3 10 2 10")) == 0
    # Two numbers wrong with only 2 wrong deltas
    assert calculate_answer2(parse_input("4 3 3 1 1 0")) == 0
    # Removing wrong delta doesn't help
    assert calculate_answer2(parse_input("1 2 6 7 8 9")) == 0
