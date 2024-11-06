app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br" }

import pf.Stdout
import pf.Path exposing [Path]

BagInfo : { name : Str, contains : List { name : Str, amount : U64 } }

parseBegin = \begining ->
    Ok (begining |> Str.dropSuffix " bags")

parseAfter : Str -> Result (List { name : Str, amount : U64 }) Str
parseAfter = \after ->
    noDotAfter = Str.dropSuffix after "."
    if noDotAfter == "no other bags" then
        Ok []
    else
        noDotAfter
            |> Str.split ", "
            |> List.mapTry \elem ->
                when Str.splitFirst elem " " is
                    Ok { before: numStr, after: rest } ->
                        amount = Str.toU64 numStr |> Result.mapErr? \_ -> "failed to parse num $(numStr)"
                        name = rest |> Str.dropSuffix " bags" |> Str.dropSuffix " bag"
                        Ok { name, amount }

                    Err NotFound -> Err "failed to parse containing '$(elem)'"

parseRow : Str -> Result BagInfo Str
parseRow = \row ->
    when row |> Str.splitFirst " contain " is
        Ok { before, after } ->
            Result.map2 (parseBegin before) (parseAfter after) \name, contains ->
                { name, contains }

        # name = parseBegin? before
        # contains = parseAfter? after
        # OK {name, contains}
        Err NotFound -> Err "row doesn't contain ' contain ' $(row)"

parseInput : Str -> Result (List BagInfo) Str
parseInput = \str ->
    str
    |> Str.trimEnd
    |> Str.split "\n"
    |> List.mapTry parseRow

Cache : Dict Str Bool

canContainShinyGold : Cache, List BagInfo, BagInfo -> (Cache, Bool)
canContainShinyGold = \cache, bags, bagInfo ->
    List.walk bagInfo.contains (cache, Bool.false) \(newCache, ans), { name, amount: _ } ->
        (newNewCache, newAns) = canContainShinyGoldAux newCache bags name
        (newNewCache, newAns || ans)

canContainShinyGoldAux : Cache, List BagInfo, Str -> (Cache, Bool)
canContainShinyGoldAux = \cache, bags, name ->
    when Dict.get cache name is
        Ok found -> (cache, found)
        Err KeyNotFound ->
            # ignoreRepeated = Dict.insert cache name Bool.false
            dbg Dict.len cache

            dbg name

            if name == "shiny gold" then
                (cache, Bool.true)
            else
                when List.findFirst bags \bag -> bag.name == name is
                    Ok bag ->
                        answer = List.walk bag.contains (cache, Bool.false) \(newCache, ans), { name: innerName, amount: _ } ->
                            ignoreRepeated = Dict.insert newCache name Bool.false

                            (updatedCache, newAns) = canContainShinyGoldAux ignoreRepeated bags innerName
                            (updatedCache |> Dict.insert innerName newAns |> Dict.remove name, newAns || ans)

                        answer

                    Err NotFound -> crash "unexpected bag name '$(name)'"

calcAnswer1 : List BagInfo -> U64
calcAnswer1 = \lst ->
    List.walk lst (Dict.empty {}, 0) \(cache, amount), bagInfo ->
        (newCache, contains) = canContainShinyGold cache lst bagInfo
        (newCache, if contains then amount + 1 else amount)
    |> \(_, count) -> count

bagsInBag : List BagInfo, Str -> U64
bagsInBag = \bags, name ->
    firstElem : Result (List {
        amount : U64,
        name : Str,
    }) [NotFound]
    firstElem = Result.map (List.findFirst bags \bag -> bag.name == name) \x -> x.contains
    when firstElem is
        OK contains ->
            
            List.map contains \{name: childName, amount} ->
                amount * (bagsInBag bags childName)
            |> List.sum

        Err NotFound -> crash "unexpected bag '$(name)"

calcAnswer2 = \lst ->
    1
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

expect
    value = parseInput testInput
    value
    == Ok [
        { name: "light red", contains: [{ amount: 1, name: "bright white" }, { amount: 2, name: "muted yellow" }] },
        { name: "dark orange", contains: [{ amount: 3, name: "bright white" }, { amount: 4, name: "muted yellow" }] },
        { name: "bright white", contains: [{ amount: 1, name: "shiny gold" }] },
        { name: "muted yellow", contains: [{ amount: 2, name: "shiny gold" }, { amount: 9, name: "faded blue" }] },
        { name: "shiny gold", contains: [{ amount: 1, name: "dark olive" }, { amount: 2, name: "vibrant plum" }] },
        { name: "dark olive", contains: [{ amount: 3, name: "faded blue" }, { amount: 4, name: "dotted black" }] },
        { name: "vibrant plum", contains: [{ amount: 5, name: "faded blue" }, { amount: 6, name: "dotted black" }] },
        { name: "faded blue", contains: [] },
        { name: "dotted black", contains: [] },
    ]

expect
    value =
        testInput
        |> parseInput
        |> Result.map calcAnswer1

    value == Ok 4
