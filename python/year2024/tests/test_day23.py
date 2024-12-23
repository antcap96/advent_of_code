from year2024.day23 import solution

test_input1 = """
kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn"""


def test_answer1():
    assert solution.calculate_answer1(solution.parse_input(test_input1)) == "7"


def test_answer2():
    assert (
        solution.calculate_answer2(solution.parse_input(test_input1)) == "co,de,ka,ta"
    )
