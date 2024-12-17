app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    adventOfCode: "../../package/main.roc",
}

import pf.Stdout
import pf.Path exposing [Path]

import adventOfCode.Matrix exposing [Matrix]
import adventOfCode.HeapQueue exposing [HeapQueue]

Cell : [Floor, Obstruction]
Direction : [North, East, South, West]
State : { at : (U64, U64), direction : Direction }
Data : { maze : Matrix Cell, start : (U64, U64), target : (U64, U64) }

parseInput : Str -> Result Data Str
parseInput = \str ->
    matrix =
        Str.trimEnd str
        |> Str.splitOn "\n"
        |> List.map Str.toUtf8
        |> Matrix.fromListOfList
        |> try Result.mapErr \_ -> "Inconsistent row size"

    maze = matrix |> Matrix.map \c -> if c == '#' then Obstruction else Floor

    start =
        (Matrix.findFirstIndex matrix \c -> c == 'S')
        |> try Result.mapErr \_ -> "Could not find inital position"

    target =
        (Matrix.findFirstIndex matrix \c -> c == 'E')
        |> try Result.mapErr \_ -> "Could not find target"

    Ok { maze, start, target }

right : Direction -> Direction
right = \dir ->
    when dir is
        North -> East
        East -> South
        South -> West
        West -> North

left : Direction -> Direction
left = \dir ->
    when dir is
        East -> North
        South -> East
        West -> South
        North -> West

nextPosition : (U64, U64), Direction -> (U64, U64)
nextPosition = \(i, j), direction ->
    when direction is
        North -> (Num.subWrap i 1, j)
        East -> (i, Num.addWrap j 1)
        South -> (Num.addWrap i 1, j)
        West -> (i, Num.subWrap j 1)

disjktraStep :
    {
        queue : HeapQueue { at : (U64, U64), direction : Direction, cost : U64 },
        visited : Set State,
        maze : Matrix Cell,
        finish : (U64, U64),
    }
    -> U64
disjktraStep = \{ queue, visited, maze, finish } ->
    (newQueue, maybeItem) = HeapQueue.pop queue
    when maybeItem is
        Err HeapEmpty -> Num.maxU64
        Ok item ->
            if Set.contains visited { at: item.at, direction: item.direction } then
                disjktraStep { queue: newQueue, visited, maze, finish }
            else if item.at == finish then
                item.cost
            else
                newSet = Set.insert visited { at: item.at, direction: item.direction }

                queue2 =
                    [
                        { at: nextPosition item.at item.direction, cost: item.cost + 1, direction: item.direction },
                        { at: item.at, cost: item.cost + 1000, direction: left item.direction },
                        { at: item.at, cost: item.cost + 1000, direction: right item.direction },
                    ]
                    |> List.walk newQueue \state, entry ->
                        (i, j) = entry.at
                        if Matrix.get maze i j == Ok Floor then
                            HeapQueue.insert state entry
                        else
                            state

                disjktraStep { queue: queue2, visited: newSet, maze, finish }

disjktra :
    {
        maze : Matrix Cell,
        start : (U64, U64),
        finish : (U64, U64),
    }
    -> U64
disjktra = \{ maze, start, finish } ->
    ordering = \{ cost: cost1 }, { cost: cost2 } -> Num.compare cost1 cost2
    queue = HeapQueue.empty ordering
    visited = Set.empty {}

    queue1 = HeapQueue.insert queue { cost: 0, at: start, direction: East }
    disjktraStep { queue: queue1, visited, maze, finish }

calcAnswer1 : Data -> U64
calcAnswer1 = \data ->
    disjktra { maze: data.maze, start: data.start, finish: data.target }

finalStep = \visitedFrom, finish ->
    x = Set.union
        (finalStepAux visitedFrom { at: finish, direction: North })
        (finalStepAux visitedFrom { at: finish, direction: East })

    x |> Set.map .at

finalStepAux : Dict State (List State), State -> Set State
finalStepAux = \visitedFrom, state ->
    Dict.get visitedFrom state
    |> Result.withDefault []
    |> List.walk (Set.fromList [state]) \set, elem ->
        if Set.contains set elem then
            set
        else
            Set.union set (finalStepAux visitedFrom elem)

disjktraStep2 :
    {
        queue : HeapQueue { at : (U64, U64), direction : Direction, cost : U64, from : State },
        visitedFrom : Dict State (List State),
        costs : Dict State U64,
        maze : Matrix Cell,
        finish : (U64, U64),
        finalCost : Result U64 [Unknown],
    }
    -> U64
disjktraStep2 = \{ queue, costs, visitedFrom, maze, finish, finalCost } ->
    (newQueue, maybeItem) = HeapQueue.pop queue

    when maybeItem is
        Err _ -> Num.maxU64
        Ok item ->
            if (Result.map finalCost \c -> item.cost > c) |> Result.withDefault Bool.false then
                Set.len (finalStep visitedFrom finish)
            else if
                (
                    Dict.get costs { at: item.at, direction: item.direction }
                    |> Result.map \c -> item.cost > c
                )
                |> Result.withDefault Bool.false
            then
                disjktraStep2 { queue: newQueue, visitedFrom, costs, maze, finish, finalCost }
            else
                newFinalCost =
                    if item.at == finish && Result.isErr finalCost then
                        Ok item.cost
                    else
                        finalCost

                statePair = { at: item.at, direction: item.direction }
                newVisitedFrom =
                    Dict.insert
                        visitedFrom
                        statePair
                        (
                            Dict.get visitedFrom statePair
                            |> Result.withDefault []
                            |> List.append item.from
                        )

                newCosts = Dict.insert costs statePair item.cost

                queue2 =
                    [
                        { from: statePair, at: nextPosition item.at item.direction, cost: item.cost + 1, direction: item.direction },
                        { from: statePair, at: item.at, cost: item.cost + 1000, direction: left item.direction },
                        { from: statePair, at: item.at, cost: item.cost + 1000, direction: right item.direction },
                    ]
                    |> List.walk newQueue \state, entry ->
                        (i, j) = entry.at
                        if Matrix.get maze i j == Ok Floor then
                            HeapQueue.insert state entry
                        else
                            state

                disjktraStep2 { queue: queue2, costs: newCosts, visitedFrom: newVisitedFrom, maze, finish, finalCost: newFinalCost }

disjktra2 :
    {
        maze : Matrix Cell,
        start : (U64, U64),
        finish : (U64, U64),
    }
    -> U64
disjktra2 = \{ maze, start, finish } ->
    ordering = \{ cost: cost1 }, { cost: cost2 } -> Num.compare cost1 cost2
    queue = HeapQueue.empty ordering
    costs = Dict.empty {}
    visitedFrom = Dict.empty {}

    queue1 = HeapQueue.insert queue { cost: 0, at: start, direction: East, from: { at: start, direction: East } }
    disjktraStep2 { queue: queue1, visitedFrom, costs, maze, finish, finalCost: Err Unknown }

calcAnswer2 : Data -> U64
calcAnswer2 = \data ->
    disjktra2 { maze: data.maze, start: data.start, finish: data.target }

main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2024/day16/input.txt")

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
    ###############
    #.......#....E#
    #.#.###.#.###.#
    #.....#.#...#.#
    #.###.#####.#.#
    #.#.#.......#.#
    #.#.#####.###.#
    #...........#.#
    ###.#.#####.#.#
    #...#.....#.#.#
    #.#.#.###.#.#.#
    #.....#...#.#.#
    #.###.#.#.#.#.#
    #S..#.....#...#
    ###############
    """

testInput2 =
    """
    #################
    #...#...#...#..E#
    #.#.#.#.#.#.#.#.#
    #.#.#.#...#...#.#
    #.#.#.#.###.#.#.#
    #...#.#.#.....#.#
    #.#.#.#.#.#####.#
    #.#...#.#.#.....#
    #.#.#####.#.###.#
    #.#.#.......#...#
    #.#.###.#####.###
    #.#.#...#.....#.#
    #.#.#.#####.###.#
    #.#.#.........#.#
    #.#.#.#########.#
    #S#.............#
    #################
    """

expect
    value =
        testInput1
        |> parseInput
        |> Result.map calcAnswer1

    value == Ok (7036)

expect
    value =
        testInput2
        |> parseInput
        |> Result.map calcAnswer1

    value == Ok (11048)

expect
    value =
        testInput1
        |> parseInput
        |> Result.map calcAnswer2

    value == Ok (45)
expect
    value =
        testInput2
        |> parseInput
        |> Result.map calcAnswer2

    value == Ok (64)
