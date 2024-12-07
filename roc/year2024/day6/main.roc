app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    adventOfCode: "../../package/main.roc",
}

import pf.Stdout
import pf.Path exposing [Path]

import adventOfCode.Matrix exposing [Matrix]

Cell : [Floor, Obstruction]
Direction : [North, East, South, West]
State : { position : (U64, U64), direction : Direction }
Data : { map : Matrix Cell, startPosition : (U64, U64) }

initialPosition : Matrix U8 -> Result (U64, U64) Str
initialPosition = \matrix ->
    Matrix.walkWithIndexUntil matrix (Err NotFound) \_, elem, i, j ->
        if elem == '^' then
            Break (Ok (i, j))
        else
            Continue (Err NotFound)
    |> Result.mapErr \_ -> "Could not find inital position"

parseInput : Str -> Result Data Str
parseInput = \str ->
    matrix =
        Str.trimEnd str
        |> Str.splitOn "\n"
        |> List.map Str.toUtf8
        |> Matrix.fromListOfList
        |> try Result.mapErr \_ -> "Inconsistent row size"

    map = matrix |> Matrix.map \c -> if c == '#' then Obstruction else Floor

    startPosition = try initialPosition matrix

    Ok { map, startPosition }

rotate : Direction -> Direction
rotate = \dir ->
    when dir is
        North -> East
        East -> South
        South -> West
        West -> North

nextPosition : State -> (U64, U64)
nextPosition = \{ position: (i, j), direction } ->
    when direction is
        North -> (Num.subWrap i 1, j)
        East -> (i, Num.addWrap j 1)
        South -> (Num.addWrap i 1, j)
        West -> (i, Num.subWrap j 1)

step : Matrix Cell, State -> [Next State, Exited]
step = \map, state ->
    (i, j) = nextPosition state

    when Matrix.get map i j is
        Err OutOfBounds -> Exited
        Ok Floor -> Next { state & position: (i, j) }
        Ok Obstruction -> Next { state & direction: rotate state.direction }

run : Matrix Cell, State, Set State -> [Exited (Set State), Looping]
run = \map, state, visited ->
    when step map state is
        Exited -> Exited visited
        Next newState ->
            if Set.contains visited newState then
                Looping
            else
                run map newState (Set.insert visited newState)

calcAnswer1 : Data -> Result U64 Str
calcAnswer1 = \data ->
    state = { position: data.startPosition, direction: North }

    when run data.map state (Set.fromList [state]) is
        Looping -> Err "looped in answer1"
        Exited set -> Set.map set .position |> Set.len |> Ok

isLoopWithObstacle : Matrix Cell, State, Set State -> Bool
isLoopWithObstacle = \matrix, state, visited ->
    (i, j) = nextPosition state
    { matrix: newMatrix } = Matrix.replace matrix i j Obstruction

    when run newMatrix state visited is
        Looping -> Bool.true
        _ -> Bool.false

run2 : Matrix Cell, State, Set State, Set (U64, U64), U64 -> U64
run2 = \matrix, state, visited, visitedPosition, count ->
    when step matrix state is
        Exited -> count
        Next nextState ->
            nextVisited = Set.insert visited nextState
            nextVisitedPosition = Set.insert visitedPosition nextState.position
            # No short-circuit in roc apparently
            if Set.contains visitedPosition nextState.position then
                run2 matrix nextState nextVisited nextVisitedPosition count
            else if isLoopWithObstacle matrix state visited then
                run2 matrix nextState nextVisited nextVisitedPosition (count + 1)
            else
                run2 matrix nextState nextVisited nextVisitedPosition count

calcAnswer2 : Data -> U64
calcAnswer2 = \data ->
    state = { position: data.startPosition, direction: North }
    run2 data.map state (Set.empty {}) (Set.empty {}) 0

main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2024/day6/input.txt")

    parsed = parseInput input

    answer1 = Result.try parsed calcAnswer1
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
    ....#.....
    .........#
    ..........
    ..#.......
    .......#..
    ..........
    .#..^.....
    ........#.
    #.........
    ......#...
    """

expect
    value =
        testInput
        |> parseInput
        |> Result.try calcAnswer1

    value == Ok (41)

expect
    value =
        testInput
        |> parseInput
        |> Result.map calcAnswer2

    value == Ok (6)
