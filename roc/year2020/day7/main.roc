app [main!] {
    # pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    pf: platform "/home/antonio-pc/Antonio/roc/basic-cli/platform/main.roc",
    parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/0.9.0/w8YKp2YAgQt5REYk912HfKAHBjcXsrnvtjI0CBzoAT4.tar.br",
}

import pf.Stdout
import pf.Path

import parser.Parser
import parser.String

Contains : List { name : Str, amount : U64 }
BagData : Dict Str Contains

bag_name_parser : Parser.Parser _ Str
bag_name_parser =
    bag_suffix_parser = Parser.alt(
        String.string(" bags"),
        String.string(" bag"),
    )

    Parser.const(|first| |second| "${String.strFromUtf8(first)} ${String.strFromUtf8(second)}")
    |> Parser.keep(Parser.chompUntil(' '))
    |> Parser.skip(String.codeunit(' '))
    |> Parser.keep(Parser.chompUntil(' '))
    |> Parser.skip(bag_suffix_parser)

begining_parser : Parser.Parser _ Str
begining_parser =
    Parser.const(|x| x)
    |> Parser.keep(bag_name_parser)
    |> Parser.skip(String.string(" contain "))

contains_parser : Parser.Parser _ Contains
contains_parser =
    no_bags_parser = Parser.const(|_| []) |> Parser.keep(String.string("no other bags"))

    with_bags_parser =
        element_parser
        |> Parser.sepBy1(String.string(", "))

    element_parser =
        Parser.const(|amount| |name| { amount, name })
        |> Parser.keep(String.digits)
        |> Parser.skip(String.codeunit(' '))
        |> Parser.keep(bag_name_parser)

    Parser.alt(no_bags_parser, with_bags_parser)
    |> Parser.skip(String.codeunit('.'))

row_parser : Parser.Parser _ (Str, Contains)
row_parser =
    Parser.const(|name| |contains| (name, contains))
    |> Parser.keep(begining_parser)
    |> Parser.keep(contains_parser)

parse_row : Str -> Result (Str, Contains) Str
parse_row = |row|
    Result.map_err(String.parseStr(row_parser, row), Inspect.to_str)

parse_input : Str -> Result BagData Str
parse_input = |str|
    str
    |> Str.trim_end
    |> Str.split_on("\n")
    |> List.map_try(parse_row)
    |> Result.map_ok(Dict.from_list)

Cache : Dict Str Bool
can_contain_shiny_gold : Cache, BagData, Contains -> (Cache, Bool)
can_contain_shiny_gold = |original_cache, bags, contains|
    List.walk(
        contains,
        (original_cache, Bool.false),
        |(cache, ans), { name, amount: _ }|
            (updated_cache, new_ans) = can_contain_shiny_gold_aux_cache(cache, bags, name)
            (updated_cache, new_ans or ans),
    )

can_contain_shiny_gold_aux_cache : Cache, BagData, Str -> (Cache, Bool)
can_contain_shiny_gold_aux_cache = |cache, bags, name|
    if name == "shiny gold" then
        (cache, Bool.true)
    else
        when Dict.get(cache, name) is
            Ok(found) -> (cache, found)
            Err(KeyNotFound) ->
                fail_on_repeated = cache |> Dict.insert(name, Bool.false)
                (newcache, ans) = can_contain_shiny_gold_aux(fail_on_repeated, bags, name)
                (newcache |> Dict.insert(name, ans), ans)

can_contain_shiny_gold_aux : Cache, BagData, Str -> (Cache, Bool)
can_contain_shiny_gold_aux = |original_cache, data, name|
    when Dict.get(data, name) is
        Ok(contains) ->
            List.walk(
                contains,
                (original_cache, Bool.false),
                |(cache, ans), { name: inner_name, amount: _ }|
                    (updated_cache, new_ans) =
                        can_contain_shiny_gold_aux_cache(cache, data, inner_name)
                    (updated_cache, new_ans or ans),
            )

        Err(KeyNotFound) -> crash("unexpected bag name '${name}'")

calc_answer1 : BagData -> U64
calc_answer1 = |data|
    (_finalCache, count) = Dict.walk(
        data,
        (Dict.empty({}), 0),
        |(cache, amount), _name, contains|
            (new_cache, it_contains) = can_contain_shiny_gold(cache, data, contains)
            (new_cache, if it_contains then amount + 1 else amount),
    )
    count

bags_in_bag : BagData, Str -> U64
bags_in_bag = |data, name|
    when Dict.get(data, name) is
        Ok(contains) ->
            1
            + (
                List.map(
                    contains,
                    |{ name: child_name, amount }|
                        amount * (bags_in_bag(data, child_name)),
                )
                |> List.sum
            )

        Err(KeyNotFound) -> crash("unexpected bag '${name}")

calc_answer2 : BagData -> U64
calc_answer2 = |data|
    # -1 to remove the shiny gold bag from the total count
    (bags_in_bag(data, "shiny gold")) - 1

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2020/day7.txt"))?

    parsed = parse_input(input)

    answer1 = Result.map_ok(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.map_ok(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

test_input =
    """
    light red bags contain 1 bright white bag, 2 muted yellow bags.
    dark orange bags contain 3 bright white bags, 4 muted yellow bags.
    bright white bags contain 1 shiny gold bag.
    muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
    shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
    dark olive bags contain 3 faded blue bags, 4 dotted black bags.
    vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
    faded blue bags contain no other bags.
    dotted black bags contain no other bags.
    """

test_input2 =
    """
    shiny gold bags contain 2 dark red bags.
    dark red bags contain 2 dark orange bags.
    dark orange bags contain 2 dark yellow bags.
    dark yellow bags contain 2 dark green bags.
    dark green bags contain 2 dark blue bags.
    dark blue bags contain 2 dark violet bags.
    dark violet bags contain no other bags.
    """

expect
    value = parse_input(test_input)
    value
    == Ok(
        Dict.from_list(
            [
                ("light red", [{ amount: 1, name: "bright white" }, { amount: 2, name: "muted yellow" }]),
                ("dark orange", [{ amount: 3, name: "bright white" }, { amount: 4, name: "muted yellow" }]),
                ("bright white", [{ amount: 1, name: "shiny gold" }]),
                ("muted yellow", [{ amount: 2, name: "shiny gold" }, { amount: 9, name: "faded blue" }]),
                ("shiny gold", [{ amount: 1, name: "dark olive" }, { amount: 2, name: "vibrant plum" }]),
                ("dark olive", [{ amount: 3, name: "faded blue" }, { amount: 4, name: "dotted black" }]),
                ("vibrant plum", [{ amount: 5, name: "faded blue" }, { amount: 6, name: "dotted black" }]),
                ("faded blue", []),
                ("dotted black", []),
            ],
        ),
    )

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok(4)

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer2)

    value == Ok(32)

expect
    value =
        test_input2
        |> parse_input
        |> Result.map_ok(calc_answer2)

    value == Ok(126)
