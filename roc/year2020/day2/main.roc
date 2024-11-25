app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/0.9.0/w8YKp2YAgQt5REYk912HfKAHBjcXsrnvtjI0CBzoAT4.tar.br",
}

import pf.Stdout
import pf.Path exposing [Path]
import parser.Parser
import parser.String

Policy : { key : U8, first : U64, second : U64 }

Entry : { policy : Policy, password : Str }

policyParser : Parser.Parser _ Policy
policyParser =
    Parser.const (\first -> \second -> \key -> { key, first, second })
    |> Parser.keep String.digits
    |> Parser.skip (String.string "-")
    |> Parser.keep String.digits
    |> Parser.skip (String.string " ")
    |> Parser.keep String.anyCodeunit

entryParser : Parser.Parser _ Entry
entryParser =
    Parser.const (\policy -> \password -> { policy, password })
    |> Parser.keep policyParser
    |> Parser.skip (String.string ": ")
    |> Parser.keep String.anyString

parseEntry : Str -> Result Entry Str
parseEntry = \str ->
    Result.mapErr (String.parseStr entryParser str) Inspect.toStr

parseInput : Str -> Result (List Entry) Str
parseInput = \str ->
    str
    |> Str.trimEnd
    |> Str.splitOn "\n"
    |> List.mapTry parseEntry

calcAnswer1 : List Entry -> U64
calcAnswer1 = \entries ->
    List.countIf entries \entry ->
        count = Str.walkUtf8 entry.password 0 \state, char ->
            if char == entry.policy.key then
                state + 1
            else
                state
        count >= entry.policy.first && count <= entry.policy.second

calcAnswer2 : List Entry -> Result U64 Str
calcAnswer2 = \entries ->
    pairs =
        List.mapTry? entries \entry ->
            passwordBytes = Str.toUtf8 entry.password

            first =
                List.get passwordBytes (entry.policy.first - 1)
                    |> Result.map \char -> char == entry.policy.key
                    |> Result.mapErr? \_ -> "Failed to get index $(Num.toStr entry.policy.first) of '$(entry.password)'"

            second =
                List.get passwordBytes (entry.policy.second - 1)
                    |> Result.map \char -> char == entry.policy.key
                    |> Result.mapErr? \_ -> "Failed to get index $(Num.toStr entry.policy.first) of '$(entry.password)'"

            Ok (first, second)

    pairs
    |> List.countIf \(first, second) -> Bool.isNotEq first second
    |> Ok

main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2020/day2.txt")

    parsed = parseInput input

    answer1 = Result.map parsed calcAnswer1
    answer2 = Result.try parsed calcAnswer2

    Stdout.line! "Answer1: $(Inspect.toStr answer1)"
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

# Tests

testInput =
    """
    1-3 a: abcde
    1-3 b: cdefg
    2-9 c: ccccccccc
    """

expect
    value =
        testInput
        |> parseInput
        |> Result.map calcAnswer1
    value == Ok 2

expect
    value =
        testInput
        |> parseInput
        |> Result.try calcAnswer2
    value == Ok 1

