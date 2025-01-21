app [main!] {
    # pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    pf: platform "/home/antonio-pc/Antonio/roc/basic-cli/platform/main.roc",
    parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/0.9.0/w8YKp2YAgQt5REYk912HfKAHBjcXsrnvtjI0CBzoAT4.tar.br",
    adventOfCode: "../../package/main.roc",
}

import pf.Stdout
import pf.Path

import parser.Parser
import parser.String

Mask : List [X, One, Zero]
Mem : { idx : U64, value : U64 }
Data : List [Mask Mask, Mem Mem]

# mask = XX001001X10X110X0001111001110X110101
mask_parser : Parser.Parser _ Mask
mask_parser =
    Parser.const(|x| x)
    |> Parser.skip (String.string ("mask = "))
    |> Parser.keep(String.anyString)
    |> Parser.map(
        |str|
            Str.to_utf8(str)
            |> List.map_try(parse_bit),
    )
    |> Parser.flatten

parse_bit : U8 -> Result [One, Zero, X] Str
parse_bit = |elem|
    when elem is
        '1' -> Ok(One)
        '0' -> Ok(Zero)
        'X' -> Ok(X)
        _ -> Err("invalid char in mask ${Inspect.to_str(Str.from_utf8([elem]))}")

# mem[3250] = 4436
mem_parser : Parser.Parser _ Mem
mem_parser =
    Parser.const(|idx| |value| { idx, value })
    |> Parser.skip(String.string("mem"))
    |> Parser.keep(Parser.between(String.digits, String.codeunit('['), String.codeunit(']')))
    |> Parser.skip (String.string (" = "))
    |> Parser.keep(String.digits)

parse_row = |row|
    row_parser : Parser.Parser _ [Mask Mask, Mem Mem]
    row_parser = Parser.alt(Parser.map(mem_parser, Mem), Parser.map(mask_parser, Mask))
    String.parseStr(row_parser, row)

parse_input : Str -> Result Data _
parse_input = |str|
    Str.trim_end(str)
    |> Str.split_on("\n")
    |> List.map_try(parse_row)

and_int_mask = |mask|
    mask
    |> List.reverse
    |> List.walk_with_index(
        0,
        |state, elem, idx|
            if elem == Zero then
                state + Num.pow_int(2, idx)
            else
                state,
    )
    |> Num.bitwise_not

or_int_mask = |mask|
    mask
    |> List.reverse
    |> List.walk_with_index(
        0,
        |state, elem, idx|
            if elem == One then
                state + Num.pow_int(2, idx)
            else
                state,
    )

apply_mask = |num, mask|
    num
    |> Num.bitwise_and(and_int_mask(mask))
    |> Num.bitwise_or(or_int_mask(mask))

calc_answer1 : Data -> U64
calc_answer1 = |lst|
    List.walk(
        lst,
        { mem: Dict.empty({}), mask: [] },
        |{ mem, mask }, elem|
            when elem is
                Mask(new_mask) -> { mem, mask: new_mask }
                Mem({ idx, value }) ->
                    masked_value = apply_mask(value, mask)
                    { mem: Dict.insert(mem, idx, masked_value), mask },
    )
    |> .mem
    |> Dict.values
    |> List.sum

# expandMask : Mask -> List Mask
expand_mask = |mask|
    when List.find_first_index(mask, |elem| elem == X) is
        Err(NotFound) -> [mask]
        Ok(idx) ->
            List.concat(
                expand_mask((List.replace(mask, idx, Zero)).list),
                expand_mask((List.replace(mask, idx, One)).list),
            )

replace_zero_with_keep : Mask -> List [Zero, One, X, Keep]
replace_zero_with_keep = |lst|
    List.map(
        lst,
        |elem|
            when elem is
                Zero -> Keep
                One -> One
                X -> X,
    )

calc_answer2 : Data -> U64
calc_answer2 = |lst|
    List.walk(
        lst,
        { mem: Dict.empty({}), mask: [] },
        |{ mem, mask }, elem|
            when elem is
                Mask(new_mask) -> { mem, mask: replace_zero_with_keep(new_mask) }
                Mem({ idx, value }) ->
                    masks = expand_mask(mask)
                    new_mem = List.walk(
                        masks,
                        mem,
                        |state, used_mask|
                            adress = apply_mask(idx, used_mask)
                            Dict.insert(state, adress, value),
                    )
                    { mem: new_mem, mask },
    )
    |> .mem
    |> Dict.values
    |> List.sum

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2020/day14.txt"))?

    parsed = parse_input(input)

    answer1 = Result.map_ok(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.map_ok(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

test_input1 =
    """
    mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
    mem[8] = 11
    mem[7] = 101
    mem[8] = 0
    """

expect
    value =
        test_input1
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok(165)

test_input2 =
    """
    mask = 000000000000000000000000000000X1001X
    mem[42] = 100
    mask = 00000000000000000000000000000000X0XX
    mem[26] = 1
    """

expect
    value =
        test_input2
        |> parse_input
        |> Result.map_ok(calc_answer2)

    value == Ok(208)
