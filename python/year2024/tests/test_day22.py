from year2024.day22 import next_secret, solution

test_input1 = """
1
10
100
2024"""

test_input2 = """
1
2
3
2024"""


def test_answer1():
    assert solution.calculate_answer1(solution.parse_input(test_input1)) == str(
        8685429 + 4700978 + 15273692 + 8667524
    )


def test_answer1_1():
    next = [
        15887950,
        16495136,
        527345,
        704524,
        1553684,
        12683156,
        11100544,
        12249484,
        7753432,
        5908254,
    ]
    secret = 123
    for test in next:
        secret = next_secret(secret)
        assert secret == test


def test_answer2():
    assert solution.calculate_answer2(solution.parse_input(test_input2)) == "23"
