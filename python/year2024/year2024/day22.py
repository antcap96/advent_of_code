import functools
from concurrent.futures import ThreadPoolExecutor

import tqdm

from year2024.utils.aoc import Solution


def parse_input(string: str) -> list[int]:
    return [int(line) for line in string.strip().splitlines()]


def prune(number: int) -> int:
    return number % 16777216


def mix(number: int, secret: int) -> int:
    return number ^ secret


def next_secret(secret: int) -> int:
    secret = prune(mix(secret << 6, secret))
    secret = prune(mix(secret >> 5, secret))
    secret = prune(mix(secret << 11, secret))

    return secret


def nth_secret(secret: int, n: int) -> int:
    for _ in range(n):
        secret = next_secret(secret)

    return secret


def calculate_answer1(secrets: list[int]) -> str:
    with ThreadPoolExecutor() as pool:
        secrets2000 = pool.map(functools.partial(nth_secret, n=2000), secrets)
    return str(sum(secrets2000))


def mapping(secret: int) -> dict[tuple[int, int, int, int], int]:
    bananas: list[int] = []

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
        tpl = (l4, l3, l2, l1)
        if tpl not in output:
            output[tpl] = banana

    return output


def score_aux(
    mappings: list[dict[tuple[int, int, int, int], int]], key: tuple[int, int, int, int]
) -> int:
    return sum(mapping.get(key, 0) for mapping in mappings)


def score(mappings: list[dict[tuple[int, int, int, int], int]]) -> int:
    keys = functools.reduce(set.union, [set(mapping.keys()) for mapping in mappings])

    with ThreadPoolExecutor() as pool:
        func = functools.partial(score_aux, mappings)
        return max(tqdm.tqdm(pool.map(func, keys), total=len(keys)))


def calculate_answer2(secrets: list[int]) -> str:
    with ThreadPoolExecutor() as pool:
        mappings = list(tqdm.tqdm(pool.map(mapping, secrets), total=len(secrets)))
    return str(score(mappings))


solution = Solution(
    parse_input,
    calculate_answer1,
    calculate_answer2,
    day=22,
)
