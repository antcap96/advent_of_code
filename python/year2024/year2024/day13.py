from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction

from year2024.utils.aoc import Solution


@dataclass
class Machine:
    botton_a: Point
    botton_b: Point
    prize: Point


type Point = tuple[int, int]


def parse_botton(string: str, name: str) -> Point:
    x, y = string.removeprefix(f"Button {name}: ").split(", ")
    return int(x.removeprefix("X")), int(y.removeprefix("Y"))


def parse_prize(string: str) -> Point:
    x, y = string.removeprefix("Prize: ").split(", ")
    return int(x.removeprefix("X=")), int(y.removeprefix("Y="))


def parse_machine(string: str) -> Machine:
    button_a_str, button_b_str, prize_str = string.splitlines()

    button_a = parse_botton(button_a_str, "A")
    button_b = parse_botton(button_b_str, "B")
    prize = parse_prize(prize_str)

    return Machine(button_a, button_b, prize)


def parse_input(string: str) -> list[Machine]:
    machines = string.strip().split("\n\n")

    return [parse_machine(machine) for machine in machines]


def colinear_counts_with_priority(
    x_cheap: int, x_expensive: int, xp: int
) -> tuple[int, int] | None:
    for i in range(x_cheap):
        count_cheap = (xp - i * x_expensive) // x_cheap
        rem = xp - count_cheap * x_cheap
        if rem % x_expensive == 0:
            count_expensive = rem // x_expensive
            return count_cheap, count_expensive

    return None


def required_tokens_colinear(xa: int, xb: int, xp: int) -> int | None:
    if xa // xb >= 3:
        counts = colinear_counts_with_priority(xa, xb, xp)
        if counts is None:
            return None
        else:
            return counts[0] * 3 + counts[1]
    else:
        counts = colinear_counts_with_priority(xb, xa, xp)
        if counts is None:
            return None
        else:
            return counts[1] * 3 + counts[0]


def required_tokens(machine: Machine) -> int | None:
    xa = machine.botton_a[0]
    ya = machine.botton_a[1]
    xb = machine.botton_b[0]
    yb = machine.botton_b[1]
    xp = machine.prize[0]
    yp = machine.prize[1]

    if Fraction(ya, xa) == Fraction(yb, xb) == Fraction(yp, xp):
        return required_tokens_colinear(xa, xb, xp)

    num1 = Fraction(yb, yp)
    num2 = Fraction(xb, xp)
    den1 = Fraction(xa - xb, xp)
    den2 = Fraction(ya - yb, yp)

    try:
        ratio = (num1 - num2) / (den1 - den2)
        count = xp / (xa * ratio + xb * (1 - ratio))
    except ZeroDivisionError:
        return None

    count_a = count * ratio
    count_b = count * (1 - ratio)

    if count_a >= 0 and count_a.is_integer() and count_b >= 0 and count_b.is_integer():
        return int(count_a) * 3 + int(count_b)
    else:
        return None


def calculate_answer1(machines: list[Machine]) -> str:
    result = sum(required_tokens(machine) or 0 for machine in machines)
    return str(result)


def calculate_answer2(machines: list[Machine]) -> str:
    corrected_machines = [
        Machine(
            m.botton_a,
            m.botton_b,
            (m.prize[0] + 10_000_000_000_000, m.prize[1] + 10_000_000_000_000),
        )
        for m in machines
    ]
    return calculate_answer1(corrected_machines)


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=13)
