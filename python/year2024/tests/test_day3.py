from year2024.day3 import parse_input, calculate_answer1, calculate_answer2

test_input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"


def test_answer1():
    assert calculate_answer1(parse_input(test_input)) == 161


test_input2 = (
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
)


def test_answer2():
    assert calculate_answer2(parse_input(test_input2)) == 48
