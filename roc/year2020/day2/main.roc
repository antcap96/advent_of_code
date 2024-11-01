app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br" }

import pf.Stdout
import pf.Path exposing [Path]

Policy : { key : U8, first : U64, second : U64 }

Entry : { policy : Policy, password : Str }

strToNum = \str -> Result.mapErr (Str.toU64 str) \_ -> "Failed to parse number '$(str)'"

parsePolicy : Str -> Result Policy Str
parsePolicy = \str ->
    when Str.split str " " is
        [range, keyStr] ->
            key = keyStr |> Str.toUtf8 |> List.first |> Result.mapErr? \_ -> "Empty key in '$(str)'"
            when Str.split range "-" is
                [firstStr, secondStr] ->
                    first = strToNum? firstStr
                    second = strToNum? secondStr
                    Ok { key, first, second }

                _ -> Err "Unexpected split of range '$(range)'"

        _ -> Err "Unexpected split of policy '$(str)'"

parseEntry : Str -> Result Entry Str
parseEntry = \str ->
    when Str.split str ": " is
        [policyStr, password] ->
            Result.map (parsePolicy policyStr) \policy -> { policy, password }

        _ -> Err "Unexpected split of row '$(str)'"

parseInput : Str -> Result (List Entry) Str
parseInput = \str ->
    str
    |> Str.trimEnd
    |> Str.split ("\n")
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

