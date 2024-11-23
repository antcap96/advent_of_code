app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/0.8.0/PCkJq9IGyIpMfwuW-9hjfXd6x-bHb1_OZdacogpBcPM.tar.br",
}

import pf.Stdout
import pf.Path exposing [Path]

import parser.Parser
import parser.String

Contains : List { name : Str, amount : U64 }
BagData : Dict Str Contains

bagNameParser : Parser.Parser _ Str
bagNameParser =
    bagSuffixParser = Parser.alt
        (String.string " bags")
        (String.string " bag")

    Parser.const (\first -> \second -> "$(String.strFromUtf8 first) $(String.strFromUtf8 second)")
    |> Parser.keep (Parser.chompUntil ' ')
    |> Parser.skip (String.codeunit ' ')
    |> Parser.keep (Parser.chompUntil ' ')
    |> Parser.skip bagSuffixParser

beginingParser : Parser.Parser _ Str
beginingParser =
    Parser.const (\x -> x)
    |> Parser.keep bagNameParser
    |> Parser.skip (String.string " contain ")

containsParser : Parser.Parser _ Contains
containsParser =
    noBagsParser = Parser.const (\_ -> []) |> Parser.keep (String.string "no other bags")

    withBagsParser =
        elementParser
        |> Parser.sepBy1 (String.string ", ")

    elementParser =
        Parser.const (\amount -> \name -> { amount, name })
        |> Parser.keep String.digits
        |> Parser.skip (String.codeunit ' ')
        |> Parser.keep bagNameParser

    Parser.alt noBagsParser withBagsParser
    |> Parser.skip (String.codeunit '.')

rowParser : Parser.Parser _ (Str, Contains)
rowParser =
    Parser.const (\name -> \contains -> (name, contains))
    |> Parser.keep beginingParser
    |> Parser.keep containsParser

parseRow : Str -> Result (Str, Contains) Str
parseRow = \row ->
    Result.mapErr (String.parseStr rowParser row) Inspect.toStr

parseInput : Str -> Result BagData Str
parseInput = \str ->
    str
    |> Str.trimEnd
    |> Str.split "\n"
    |> List.mapTry parseRow
    |> Result.map Dict.fromList

Cache : Dict Str Bool
canContainShinyGold : Cache, BagData, Contains -> (Cache, Bool)
canContainShinyGold = \originalCache, bags, contains ->
    List.walk contains (originalCache, Bool.false) \(cache, ans), { name, amount: _ } ->
        (updatedCache, newAns) = canContainShinyGoldAuxCache cache bags name
        (updatedCache, newAns || ans)

canContainShinyGoldAuxCache : Cache, BagData, Str -> (Cache, Bool)
canContainShinyGoldAuxCache = \cache, bags, name ->
    if name == "shiny gold" then
        (cache, Bool.true)
    else
        when Dict.get cache name is
            Ok found -> (cache, found)
            Err KeyNotFound ->
                failOnRepeated = cache |> Dict.insert name Bool.false
                (newcache, ans) = canContainShinyGoldAux failOnRepeated bags name
                (newcache |> Dict.insert name ans, ans)

canContainShinyGoldAux : Cache, BagData, Str -> (Cache, Bool)
canContainShinyGoldAux = \originalCache, data, name ->
    when Dict.get data name is
        Ok contains ->
            List.walk
                contains
                (originalCache, Bool.false)
                \(cache, ans), { name: innerName, amount: _ } ->
                    (updatedCache, newAns) =
                        canContainShinyGoldAuxCache cache data innerName
                    (updatedCache, newAns || ans)

        Err KeyNotFound -> crash "unexpected bag name '$(name)'"

calcAnswer1 : BagData -> U64
calcAnswer1 = \data ->
    (_finalCache, count) = Dict.walk
        data
        (Dict.empty {}, 0)
        \(cache, amount), _name, contains ->
            (newCache, itContains) = canContainShinyGold cache data contains
            (newCache, if itContains then amount + 1 else amount)
    count

bagsInBag : BagData, Str -> U64
bagsInBag = \data, name ->
    when Dict.get data name is
        Ok contains ->
            1
            + (
                List.map contains \{ name: childName, amount } ->
                    amount * (bagsInBag data childName)
                |> List.sum
            )

        Err KeyNotFound -> crash "unexpected bag '$(name)"

calcAnswer2 : BagData -> U64
calcAnswer2 = \data ->
    # -1 to remove the shiny gold bag from the total count
    (bagsInBag data "shiny gold") - 1

main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2020/day7.txt")

    parsed = parseInput input

    answer1 = Result.map parsed calcAnswer1
    answer2 = Result.map parsed calcAnswer2

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

testInput =
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

testInput2 =
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
    value = parseInput testInput
    value
    == Ok
        (
            Dict.fromList [
                ("light red", [{ amount: 1, name: "bright white" }, { amount: 2, name: "muted yellow" }]),
                ("dark orange", [{ amount: 3, name: "bright white" }, { amount: 4, name: "muted yellow" }]),
                ("bright white", [{ amount: 1, name: "shiny gold" }]),
                ("muted yellow", [{ amount: 2, name: "shiny gold" }, { amount: 9, name: "faded blue" }]),
                ("shiny gold", [{ amount: 1, name: "dark olive" }, { amount: 2, name: "vibrant plum" }]),
                ("dark olive", [{ amount: 3, name: "faded blue" }, { amount: 4, name: "dotted black" }]),
                ("vibrant plum", [{ amount: 5, name: "faded blue" }, { amount: 6, name: "dotted black" }]),
                ("faded blue", []),
                ("dotted black", []),
            ]
        )

expect
    value =
        testInput
        |> parseInput
        |> Result.map calcAnswer1

    value == Ok 4

expect
    value =
        testInput
        |> parseInput
        |> Result.map calcAnswer2

    value == Ok 32

expect
    value =
        testInput2
        |> parseInput
        |> Result.map calcAnswer2

    value == Ok 126
