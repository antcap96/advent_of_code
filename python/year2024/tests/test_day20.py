from year2024.day20 import solution, count_shorcuts

test_input1 = """
###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############"""


def test_answer1():
    assert count_shorcuts(
        solution.parse_input(test_input1), shortcut_distance=2, min_score=1
    ) == str(14 + 14 + 2 + 2 + 4 + 3 + 1 * 5)


def test_answer2():
    assert count_shorcuts(
        solution.parse_input(test_input1), shortcut_distance=20, min_score=50
    ) == str(32 + 31 + 29 + 39 + 25 + 23 + 20 + 19 + 12 + 14 + 12 + 22 + 4 + 3)
