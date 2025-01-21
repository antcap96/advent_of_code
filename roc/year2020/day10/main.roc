app [main!] {
    # pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    pf: platform "/home/antonio-pc/Antonio/roc/basic-cli/platform/main.roc",
}
import pf.Stdout
import pf.Path

parse_input : Str -> Result (List U64) Str
parse_input = |str|
    str
    |> Str.trim_end
    |> Str.split_on("\n")
    |> List.map_try(parse_row)

parse_row = |str|
    Str.to_u64(str) |> Result.map_err(|_| "invalid number '${str}'")

calc_answer1 = |lst|
    { one: one_count, three: three_count } =
        List.sort_asc(lst)
        |> List.walk(
            { one: 0, three: 0, prev: 0 },
            |{ one, three, prev }, elem|
                if elem - prev == 1 then
                    { one: one + 1, three, prev: elem }
                else if elem - prev == 3 then
                    { one, three: three + 1, prev: elem }
                else
                    { one, three, prev: elem },
        )

    one_count * (three_count + 1)

calc_answer2 : List U64 -> Result U64 Str
calc_answer2 = |lst|
    max = List.max(lst) |> Result.map_err?(|_| "empty list")
    (_, ans) = calc_answer2_cache((Set.from_list(lst) |> Set.insert(0)), Dict.empty({}), 0, (max + 3))
    Ok(ans)

calc_answer2_cache = |set, cache, elem, stop|
    if elem == stop then
        (cache, 1)
    else if !(Set.contains(set, elem)) then
        (cache, 0)
    else
        when Dict.get(cache, elem) is
            Ok(count) -> (cache, count)
            Err(KeyNotFound) ->
                (cache1, possibilities1) = calc_answer2_cache(set, cache, (elem + 1), stop)
                (cache2, possibilities2) = calc_answer2_cache(set, cache1, (elem + 2), stop)
                (cache3, possibilities3) = calc_answer2_cache(set, cache2, (elem + 3), stop)
                possibilities = possibilities1 + possibilities2 + possibilities3
                (cache3 |> Dict.insert(elem, possibilities), possibilities)

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2020/day10.txt"))?

    parsed = parse_input(input)

    answer1 = Result.map_ok(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.try(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

test_input =
    """
    16
    10
    15
    5
    1
    11
    7
    19
    6
    12
    4
    """

test_input2 =
    """
    28
    33
    18
    42
    31
    14
    46
    20
    48
    47
    24
    23
    49
    45
    19
    38
    39
    11
    1
    32
    25
    35
    8
    17
    7
    9
    4
    2
    34
    10
    3
    """

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok((7 * 5))

expect
    value =
        test_input2
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok((22 * 10))

expect
    value =
        test_input
        |> parse_input
        |> Result.try(calc_answer2)

    value == Ok(8)

expect
    value =
        test_input2
        |> parse_input
        |> Result.try(calc_answer2)

    value == Ok(19208)
