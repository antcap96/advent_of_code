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
    calc_answer1_aux(lst, 25)

calc_answer1_aux = |lst, n|
    List.sublist(lst, { start: n, len: (List.len(lst)) - n })
    |> List.walk_with_index_until(
        0,
        |_, elem, idx|
            preamble = List.sublist(lst, { start: idx, len: n }) |> Set.from_list

            when preamble_contains(preamble, elem) is
                Found -> Continue(0)
                NotFound -> Break(elem),
    )

preamble_contains = |preamble, next|
    Set.walk_until(
        preamble,
        NotFound,
        |_, elem|
            if Set.contains(preamble, Num.sub_wrap(next, elem)) then
                Break(Found)
            else
                Continue(NotFound),
    )

calc_answer2 = |lst|
    calc_answer2_aux(lst, 25)

calc_answer2_aux : List U64, U64 -> Result U64 Str
calc_answer2_aux = |lst, n|
    invalid_number = calc_answer1_aux(lst, n)
    ans = List.walk_until(
        List.range({ start: At(0), end: Before(List.len(lst)) }),
        NoSolution,
        |_, start|
            sublist = List.sublist(lst, { start, len: (List.len(lst)) - start })
            (sum, min, max) = range_sum(sublist, invalid_number)
            if sum == invalid_number then
                Break(Solution((min, max)))
            else
                Continue(NoSolution),
    )
    when ans is
        Solution((final_min, final_max)) -> Ok((final_min + final_max))
        NoSolution -> Err("failed to find solution")

range_sum = |lst, maximum|
    List.walk_until(
        lst,
        (0, Num.max_u64, 0),
        |(total, min, max), elem|
            new_min = Num.min(min, elem)
            new_max = Num.max(max, elem)
            next_total = total + elem
            if total + elem >= maximum then
                Break((next_total, new_min, new_max))
            else
                Continue((next_total, new_min, new_max)),
    )

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2020/day9.txt"))?

    parsed = parse_input(input)

    answer1 = Result.map_ok(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.try(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

test_input =
    """
    35
    20
    15
    25
    47
    40
    62
    55
    65
    95
    102
    117
    150
    182
    127
    219
    299
    277
    309
    576
    """

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(|lst| calc_answer1_aux(lst, 5))

    value == Ok(127)

expect
    value =
        test_input
        |> parse_input
        |> Result.try(|lst| calc_answer2_aux(lst, 5))

    value == Ok(62)
