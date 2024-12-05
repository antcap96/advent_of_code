from year2024.day5 import parse_input, calculate_answer1, calculate_answer2

test_input = """
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47"""


def test_answer1():
    assert calculate_answer1(parse_input(test_input)) == 143


def test_answer2():
    assert calculate_answer2(parse_input(test_input)) == 123
