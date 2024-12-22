import itertools

import tqdm
from year2024.utils.aoc import Solution


def parse_input(string: str) -> list[int]:
    return [int(line) for line in string.strip().splitlines()]


def prune(number: int) -> int:
    return number % 16777216


def mix(number: int, secret: int) -> int:
    return number ^ secret


def next_secret(secret: int) -> int:
    secret = prune(mix(secret * 64, secret))
    secret = prune(mix(secret // 32, secret))
    secret = prune(mix(secret * 2048, secret))

    return secret


def nth_secret(secret: int, n: int) -> int:
    for _ in range(n):
        secret = next_secret(secret)

    return secret


def calculate_answer1(secrets: list[int]) -> str:
    return str(sum(nth_secret(secret, 2000) for secret in secrets))


def mapping(secret: int) -> dict[tuple[int, int, int, int], int]:
    bananas = []

    for _ in range(2000):
        secret = next_secret(secret)
        bananas.append(secret % 10)

    l4 = bananas[1] - bananas[0]
    l3 = bananas[2] - bananas[1]
    l2 = bananas[3] - bananas[2]
    l1 = bananas[4] - bananas[3]

    output = {(l4, l3, l2, l1): bananas[4]}

    for prev_banana, banana in zip(bananas[4:], bananas[5:]):
        l4, l3, l2, l1 = l3, l2, l1, banana - prev_banana
        if (l4, l3, l2, l1) not in output:
            output[(l4, l3, l2, l1)] = banana

    return output


def score(mappings: list[dict[tuple[int, int, int, int], int]]) -> int:
    best = 0
    for i in tqdm.tqdm(
        itertools.product(range(-9, 10), range(-9, 10), range(-9, 10), range(-9, 10)),
        total=19 ** 4,
    ):
        this = sum(mapping.get(i, 0) for mapping in mappings)
        if this > best:
            best = this

    return best


def calculate_answer2(secrets: list[int]) -> str:
    mappings = [mapping(secret) for secret in tqdm.tqdm(secrets)]
    return str(score(mappings))


solution = Solution(
    parse_input,
    calculate_answer1,
    calculate_answer2,
    day=22,
)
