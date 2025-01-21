app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    adventOfCode: "../../package/main.roc",
}

import pf.Stdout
import pf.Path

Data : {
    patterns : List (List U8),
    designs : List (List U8),
}

parse_patterns = |str|
    Str.split_on(str, ", ") |> List.map(Str.to_utf8)

parse_designs = |str|
    Str.split_on(str, "\n") |> List.map(Str.to_utf8)

parse_input : Str -> Result Data Str
parse_input = |str|
    chunks =
        Str.trim_end(str)
        |> Str.split_on("\n\n")
    when chunks is
        [patterns_str, designs_str] ->
            Ok(
                {
                    patterns: parse_patterns(patterns_str),
                    designs: parse_designs(designs_str),
                },
            )

        _ -> Err("Unexpected number of chunks ${Num.to_str(List.len(chunks))}")

count_possibilities : List U8, List (List U8), Dict (List U8) U64 -> (U64, Dict (List U8) U64)
count_possibilities = |design, patterns, cache|
    when Dict.get(cache, design) is
        Ok(result) -> (result, cache)
        Err(KeyNotFound) ->
            (result, new_cache) = count_possibilities_cache(design, patterns, cache)
            (result, new_cache |> Dict.insert(design, result))

count_possibilities_cache : List U8, List (List U8), Dict (List U8) U64 -> (U64, Dict (List U8) U64)
count_possibilities_cache = |design, patterns, old_cache|
    if List.len(design) == 0 then
        (1, old_cache)
    else
        patterns
        |> List.walk(
            (0, old_cache),
            |(count, cache), pattern|
                if List.starts_with(design, pattern) then
                    new_design = List.drop_first(design, List.len(pattern))
                    (extra_count, new_cache) = count_possibilities(new_design, patterns, cache)
                    (count + extra_count, new_cache)
                else
                    (count, cache),
        )

calc_answer1 : Data -> U64
calc_answer1 = |data|
    List.walk(
        data.designs,
        { count: 0, cache: Dict.empty({}) },
        |{ count, cache }, design|
            (x, new_cache) = count_possibilities(design, data.patterns, cache)
            { count: count + if x > 0 then 1 else 0, cache: new_cache },
    )
    |> .count

calc_answer2 : Data -> U64
calc_answer2 = |data|
    List.walk(
        data.designs,
        { count: 0, cache: Dict.empty({}) },
        |{ count, cache }, design|
            (x, new_cache) = count_possibilities(design, data.patterns, cache)
            { count: count + x, cache: new_cache },
    )
    |> .count

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2024/day19/input.txt"))?

    parsed = parse_input(input)

    answer1 = Result.map_ok(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.map_ok(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

test_input =
    """
    r, wr, b, g, bwu, rb, gb, br

    brwrr
    bggr
    gbbr
    rrbgbr
    ubwu
    bwurrg
    brgr
    bbrgwb
    """

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok(6)

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer2)

    value == Ok(16)
