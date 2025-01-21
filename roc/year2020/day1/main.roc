app [main!] {
    # pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    pf: platform "/home/antonio-pc/Antonio/roc/basic-cli/platform/main.roc",
    adventOfCode: "../../package/main.roc",
}
import pf.Stdout
import pf.Path

str_to_num = |row| Str.to_i64(row) |> Result.map_err |_| InvalidRow(row)

parse_input : Str -> Result (Set I64) [InvalidRow Str]
parse_input = |str|
    str
    |> Str.trim_end
    |> Str.split_on("\n")
    |> List.map_try(str_to_num)
    |> Result.map_ok(Set.from_list)

entries_product : Set I64, I64, I64 -> [Found I64, NotFound]
entries_product = |numbers, total, count|
    if count == 1 then
        if Set.contains(numbers, total) then
            Found(total)
        else
            NotFound
    else
        numbers
        |> Set.walk_until(
            NotFound,
            |_, elem|
                when entries_product(numbers, (total - elem), (count - 1)) is
                    Found(num) -> Break(Found((elem * num)))
                    NotFound -> Continue(NotFound),
        )

calc_answer1 : Set I64 -> Result I64 [NotFound]
calc_answer1 = |numbers|
    when entries_product(numbers, 2020, 2) is
        Found(num) -> Ok(num)
        NotFound -> Err(NotFound)

calc_answer2 : Set I64 -> Result I64 [NotFound]
calc_answer2 = |numbers|
    when entries_product(numbers, 2020, 3) is
        Found(num) -> Ok(num)
        NotFound -> Err(NotFound)

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2020/day1.txt"))?

    parsed = parse_input(input)

    answer1 = Result.try(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.try(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

# Tests

test_input =
    """
    1721
    979
    366
    299
    675
    1456
    """

expect
    value =
        test_input
        |> parse_input
        |> Result.try(calc_answer1)
    value == Ok(514_579)

expect
    value =
        test_input
        |> parse_input
        |> Result.try(calc_answer2)
    value == Ok(241_861_950)

