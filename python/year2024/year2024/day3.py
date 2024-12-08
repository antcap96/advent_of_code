import functools

from year2024.utils.aoc import Solution


def parse_input(string: str) -> str:
    return string.strip()


def parse_num(string: str, max_digits: int = 3) -> tuple[str, int | None]:
    digits = 0
    while digits < max_digits:
        if len(string) <= digits or not string[digits].isdecimal():
            break
        digits += 1

    if digits == 0:
        return string, None

    return string[digits:], int(string[:digits])


def parse_exact(string: str, pattern: str) -> tuple[str, bool]:
    if string.startswith(pattern):
        return string[len(pattern) :], True
    return string, False


def parse_mul(string: str) -> tuple[str, tuple[int, int] | None]:
    remainder = string

    remainder, found = parse_exact(remainder, "mul(")
    if not found:
        return string, None
    remainder, num1 = parse_num(remainder)
    if num1 is None:
        return string, None
    remainder, found = parse_exact(remainder, ",")
    if not found:
        return string, None
    remainder, num2 = parse_num(remainder)
    if num2 is None:
        return string, None
    remainder, found = parse_exact(remainder, ")")
    if not found:
        return string, None

    return remainder, (num1, num2)


def parse_string1(string: str) -> list[tuple[int, int]]:
    output: list[tuple[int, int]] = []
    while len(string) > 0:
        string, result = parse_mul(string)
        if result is not None:
            output.append(result)
            continue

        string = string[1:]

    return output


def calculate_answer1(string: str) -> int:
    pairs = parse_string1(string)
    return sum(a * b for a, b in pairs)


parse_do = functools.partial(parse_exact, pattern="do()")
parse_dont = functools.partial(parse_exact, pattern="don't()")


def parse_string2(string: str) -> list[tuple[int, int]]:
    do = True
    output: list[tuple[int, int]] = []
    while len(string) > 0:
        string, found = parse_do(string)
        if found:
            do = True
            continue
        string, found = parse_dont(string)
        if found:
            do = False
            continue
        string, result = parse_mul(string)
        if result is not None:
            if do:
                output.append(result)
            continue

        string = string[1:]

    return output


def calculate_answer2(string: str) -> int:
    pairs = parse_string2(string)
    return sum(a * b for a, b in pairs)


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=3)


if __name__ == "__main__":
    solution.solve(None)
