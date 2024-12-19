app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    adventOfCode: "../../package/main.roc",
}

import pf.Stdout
import pf.Path exposing [Path]

Data : {
    patterns : List (List U8),
    designs : List (List U8),
}

parsePatterns = \str ->
    Str.splitOn str ", " |> List.map Str.toUtf8

parseDesigns = \str ->
    Str.splitOn str "\n" |> List.map Str.toUtf8

parseInput : Str -> Result Data Str
parseInput = \str ->
    chunks =
        Str.trimEnd str
        |> Str.splitOn "\n\n"
    when chunks is
        [patternsStr, designsStr] ->
            Ok {
                patterns: parsePatterns patternsStr,
                designs: parseDesigns designsStr,
            }

        _ -> Err "Unexpected number of chunks $(Num.toStr (List.len chunks))"

countPossibilities : List U8, List (List U8), Dict (List U8) U64 -> (U64, Dict (List U8) U64)
countPossibilities = \design, patterns, cache ->
    when Dict.get cache design is
        Ok result -> (result, cache)
        Err KeyNotFound ->
            (result, newCache) = countPossibilitiesCache design patterns cache
            (result, newCache |> Dict.insert design result)

countPossibilitiesCache : List U8, List (List U8), Dict (List U8) U64 -> (U64, Dict (List U8) U64)
countPossibilitiesCache = \design, patterns, oldCache ->
    if List.len (design) == 0 then
        (1, oldCache)
    else
        patterns
        |> List.walk (0, oldCache) \(count, cache), pattern ->
            if List.startsWith design pattern then
                newDesign = List.dropFirst design (List.len pattern)
                (extraCount, newCache) = countPossibilities newDesign patterns cache
                (count + extraCount, newCache)
            else
                (count, cache)

calcAnswer1 : Data -> U64
calcAnswer1 = \data ->
    List.walk data.designs { count: 0, cache: Dict.empty {} } \{ count, cache }, design ->
        (x, newCache) = countPossibilities design data.patterns cache
        { count: count + if x > 0 then 1 else 0, cache: newCache }
    |> .count

calcAnswer2 : Data -> U64
calcAnswer2 = \data ->
    List.walk data.designs { count: 0, cache: Dict.empty {} } \{ count, cache }, design ->
        (x, newCache) = countPossibilities design data.patterns cache
        { count: count + x, cache: newCache }
    |> .count

main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2024/day19/input.txt")

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

testInput =
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
        testInput
        |> parseInput
        |> Result.map calcAnswer1

    value == Ok (6)

expect
    value =
        testInput
        |> parseInput
        |> Result.map calcAnswer2

    value == Ok (16)
