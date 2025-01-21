app [main!] {
    # pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    pf: platform "/home/antonio-pc/Antonio/roc/basic-cli/platform/main.roc",
    adventOfCode: "../../package/main.roc",
    parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/0.9.0/w8YKp2YAgQt5REYk912HfKAHBjcXsrnvtjI0CBzoAT4.tar.br",
}

import pf.Stdout
import pf.Path
import parser.Parser
import parser.String

Policy : { key : U8, first : U64, second : U64 }

Entry : { policy : Policy, password : Str }

policy_parser : Parser.Parser _ Policy
policy_parser =
    Parser.const(|first| |second| |key| { key, first, second })
    |> Parser.keep(String.digits)
    |> Parser.skip(String.string("-"))
    |> Parser.keep(String.digits)
    |> Parser.skip(String.string(" "))
    |> Parser.keep(String.anyCodeunit)

entry_parser : Parser.Parser _ Entry
entry_parser =
    Parser.const(|policy| |password| { policy, password })
    |> Parser.keep(policy_parser)
    |> Parser.skip(String.string(": "))
    |> Parser.keep(String.anyString)

parse_entry : Str -> Result Entry Str
parse_entry = |str|
    Result.map_err(String.parseStr(entry_parser, str), Inspect.to_str)

parse_input : Str -> Result (List Entry) Str
parse_input = |str|
    str
    |> Str.trim_end
    |> Str.split_on("\n")
    |> List.map_try(parse_entry)

calc_answer1 : List Entry -> U64
calc_answer1 = |entries|
    List.count_if(
        entries,
        |entry|
            count = Str.walk_utf8(
                entry.password,
                0,
                |state, char|
                    if char == entry.policy.key then
                        state + 1
                    else
                        state,
            )
            count >= entry.policy.first and count <= entry.policy.second,
    )

calc_answer2 : List Entry -> Result U64 Str
calc_answer2 = |entries|
    pairs =
        List.map_try(
            entries,
            |entry|
                password_bytes = Str.to_utf8(entry.password)

                get_index = |idx|
                    List.get(password_bytes, idx)
                    |> Result.map_err(|_| "Failed to get index ${Num.to_str(entry.policy.first)} of '${entry.password}'")

                first =
                    get_index(entry.policy.first - 1)? == entry.policy.key

                second =
                    get_index(entry.policy.second - 1)? == entry.policy.key

                Ok((first, second)),
        )?

    pairs
    |> List.count_if(|(first, second)| first != second)
    |> Ok

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2020/day2.txt"))?

    parsed = parse_input(input)

    answer1 = Result.map_ok(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.try(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

# Tests

test_input =
    """
    1-3 a: abcde
    1-3 b: cdefg
    2-9 c: ccccccccc
    """

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer1)
    value == Ok(2)

expect
    value =
        test_input
        |> parse_input
        |> Result.try(calc_answer2)
    value == Ok(1)

