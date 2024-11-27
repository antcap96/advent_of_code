app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/0.9.0/w8YKp2YAgQt5REYk912HfKAHBjcXsrnvtjI0CBzoAT4.tar.br",
}

import pf.Stdout
import pf.Path exposing [Path]

import parser.Parser
import parser.String

Mask : List [X, One, Zero]
Mem : { idx : U64, value : U64 }
Data : List [Mask Mask, Mem Mem]

# mask = XX001001X10X110X0001111001110X110101
maskParser : Parser.Parser _ Mask
maskParser =
    Parser.const \x -> x
    |> Parser.skip (String.string "mask = ")
    |> Parser.keep String.anyString
    |> Parser.map \str ->
        Str.toUtf8 str
        |> List.mapTry parseBit
    |> Parser.flatten

parseBit : U8 -> Result [One, Zero, X] Str
parseBit = \elem ->
    when elem is
        '1' -> Ok One
        '0' -> Ok Zero
        'X' -> Ok X
        _ -> Err "invalid char in mask $(Inspect.toStr (Str.fromUtf8 [elem]))"

# mem[3250] = 4436
memParser : Parser.Parser _ Mem
memParser =
    Parser.const (\idx -> \value -> { idx, value })
    |> Parser.skip (String.string "mem")
    |> Parser.keep (Parser.between String.digits (String.codeunit '[') (String.codeunit ']'))
    |> Parser.skip (String.string " = ")
    |> Parser.keep String.digits

parseRow = \row ->
    rowParser : Parser.Parser _ [Mask Mask, Mem Mem]
    rowParser = Parser.alt (Parser.map memParser Mem) (Parser.map maskParser Mask)
    Result.mapErr (String.parseStr rowParser row) Inspect.toStr

parseInput : Str -> Result Data Str
parseInput = \str ->
    Str.trimEnd str
    |> Str.splitOn "\n"
    |> List.mapTry parseRow

andIntMask = \mask ->
    mask
    |> List.reverse
    |> List.walkWithIndex 0 \state, elem, idx ->
        if elem == Zero then
            state + Num.powInt 2 idx
        else
            state
    |> Num.bitwiseNot

orIntMask = \mask ->
    mask
    |> List.reverse
    |> List.walkWithIndex 0 \state, elem, idx ->
        if elem == One then
            state + Num.powInt 2 idx
        else
            state

applyMask = \num, mask ->
    num
    |> Num.bitwiseAnd (andIntMask mask)
    |> Num.bitwiseOr (orIntMask mask)

calcAnswer1 : Data -> U64
calcAnswer1 = \lst ->
    List.walk lst { mem: Dict.empty {}, mask: [] } \{ mem, mask }, elem ->
        when elem is
            Mask newMask -> { mem, mask: newMask }
            Mem { idx, value } ->
                maskedValue = applyMask value mask
                { mem: Dict.insert mem idx maskedValue, mask }
    |> .mem
    |> Dict.values
    |> List.sum

# expandMask : Mask -> List Mask
expandMask = \mask ->
    when List.findFirstIndex mask \elem -> elem == X is
        Err NotFound -> [mask]
        Ok idx ->
            List.concat
                (expandMask (List.replace mask idx Zero).list)
                (expandMask (List.replace mask idx One).list)

replaceZeroWithKeep : Mask -> List [Zero, One, X, Keep]
replaceZeroWithKeep = \lst ->
    List.map lst \elem ->
        when elem is
            Zero -> Keep
            One -> One
            X -> X

calcAnswer2 : Data -> U64
calcAnswer2 = \lst ->
    List.walk lst { mem: Dict.empty {}, mask: [] } \{ mem, mask }, elem ->
        when elem is
            Mask newMask -> { mem, mask: replaceZeroWithKeep newMask }
            Mem { idx, value } ->
                masks = expandMask mask
                newMem = List.walk masks mem \state, usedMask ->
                    adress = applyMask idx usedMask
                    Dict.insert state adress value
                { mem: newMem, mask }
    |> .mem
    |> Dict.values
    |> List.sum

main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2020/day14.txt")

    parsed = parseInput input

    answer1 = Result.map parsed calcAnswer1
    Stdout.line! "Answer1: $(Inspect.toStr answer1)"

    answer2 = Result.map parsed calcAnswer2
    Stdout.line! "Answer2: $(Inspect.toStr answer2)"

readFileToStr : Path -> Task Str [ReadFileErr Str]
readFileToStr = \path ->
    path
    |> Path.readUtf8
    |> Task.mapErr # Make a nice error message
        \fileReadErr ->
            pathStr = Path.display path

            when fileReadErr is
                FileReadErr _ readErr ->
                    readErrStr = Inspect.toStr readErr
                    ReadFileErr "Failed to read file:\n\t$(pathStr)\nWith error:\n\t$(readErrStr)"

                FileReadUtf8Err _ _ ->
                    ReadFileErr "I could not read the file:\n\t$(pathStr)\nIt contains characters that are not valid UTF-8."

testInput1 =
    """
    mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
    mem[8] = 11
    mem[7] = 101
    mem[8] = 0
    """

expect
    value =
        testInput1
        |> parseInput
        |> Result.map calcAnswer1

    value == Ok (165)

testInput2 =
    """
    mask = 000000000000000000000000000000X1001X
    mem[42] = 100
    mask = 00000000000000000000000000000000X0XX
    mem[26] = 1
    """

expect
    value =
        testInput2
        |> parseInput
        |> Result.map calcAnswer2

    value == Ok (208)
