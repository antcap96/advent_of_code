app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    adventOfCode: "../../package/main.roc",
}

import pf.Stdout
import pf.Path exposing [Path]
import adventOfCode.Matrix exposing [Matrix]

Seat : [Floor, Empty, Occupied]

parseInput : Str -> Result (Matrix Seat) Str
parseInput = \str ->
    str
        |> Str.trimEnd
        |> Str.split "\n"
        |> List.mapTry? parseRow
        |> Matrix.fromListOfList
        |> Result.mapErr \_ -> "Input isn't a square"

parseRow = \str ->
    List.mapTry (Str.toUtf8 str) \elem ->
        when elem is
            '.' -> Ok Floor
            'L' -> Ok Empty
            '#' -> Ok Occupied
            _ -> Err "Invalid char '$(Inspect.toStr (Str.fromUtf8 [elem]))'"

countOcuppiedAround1 : Matrix Seat, U64, U64 -> U64
countOcuppiedAround1 = \matrix, row, col ->
    around = [
        (Num.addWrap row 1, Num.addWrap col 1),
        (Num.addWrap row 1, col),
        (Num.addWrap row 1, Num.subWrap col 1),
        (row, Num.addWrap col 1),
        (row, Num.subWrap col 1),
        (Num.subWrap row 1, Num.addWrap col 1),
        (Num.subWrap row 1, col),
        (Num.subWrap row 1, Num.subWrap col 1),
    ]
    List.map around \(i, j) ->
        when Matrix.get matrix i j is
            Ok Occupied -> 1
            _ -> 0
    |> List.sum

seatRules1 = \state, adjacentOcuppied ->
    when state is
        Floor -> Floor
        Empty if adjacentOcuppied == 0 -> Occupied
        Empty -> Empty
        Occupied if adjacentOcuppied >= 4 -> Empty
        Occupied -> Occupied

step1 : Matrix Seat -> Matrix Seat
step1 = \matrix ->
    Matrix.mapWithIndex matrix \elem, i, j ->
        adjacent = countOcuppiedAround1 matrix i j
        seatRules1 elem adjacent

run1 : Matrix Seat -> Matrix Seat
run1 = \matrix ->
    newMatrix = step1 matrix

    if matrix == newMatrix then
        matrix
    else
        run1 newMatrix

calcAnswer1 : Matrix Seat -> U64
calcAnswer1 = \matrix ->
    finalMatrix = run1 matrix
    Matrix.walk finalMatrix 0 \state, elem ->
        if elem == Occupied then
            state + 1
        else
            state

isOcupiedInDirection2 : Matrix Seat, (U64, U64), (U64, U64) -> Bool
isOcupiedInDirection2 = \matrix, (atI, atJ), (dirI, dirJ) ->
    nextI = Num.addWrap atI dirI
    nextJ = Num.addWrap atJ dirJ
    when Matrix.get matrix nextI nextJ is
        Ok Occupied -> Bool.true
        Ok Floor -> isOcupiedInDirection2 matrix (nextI, nextJ) (dirI, dirJ)
        _ -> Bool.false

countOcuppiedAround2 : Matrix Seat, U64, U64 -> U64
countOcuppiedAround2 = \matrix, row, col ->
    around = [
        (1, 1),
        (1, 0),
        (1, Num.maxU64),
        (0, 1),
        (0, Num.maxU64),
        (Num.maxU64, 1),
        (Num.maxU64, 0),
        (Num.maxU64, Num.maxU64),
    ]
    List.countIf around \dir ->
        isOcupiedInDirection2 matrix (row, col) dir

seatRules2 = \state, adjacentOcuppied ->
    when state is
        Floor -> Floor
        Empty if adjacentOcuppied == 0 -> Occupied
        Empty -> Empty
        Occupied if adjacentOcuppied >= 5 -> Empty
        Occupied -> Occupied

step2 : Matrix Seat -> Matrix Seat
step2 = \matrix ->
    Matrix.mapWithIndex matrix \elem, i, j ->
        adjacent = countOcuppiedAround2 matrix i j
        seatRules2 elem adjacent

run2 : Matrix Seat -> Matrix Seat
run2 = \matrix ->
    newMatrix = step2 matrix

    if matrix == newMatrix then
        matrix
    else
        run2 newMatrix

calcAnswer2 : Matrix Seat -> U64
calcAnswer2 = \matrix ->
    finalMatrix = run2 matrix
    Matrix.walk finalMatrix 0 \state, elem ->
        if elem == Occupied then
            state + 1
        else
            state
main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2020/day11.txt")

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
    L.LL.LL.LL
    LLLLLLL.LL
    L.L.L..L..
    LLLL.LL.LL
    L.LL.LL.LL
    L.LLLLL.LL
    ..L.L.....
    LLLLLLLLLL
    L.LLLLLL.L
    L.LLLLL.LL
    """

expect
    value =
        testInput
        |> parseInput
        |> Result.map calcAnswer1

    value == Ok (37)

expect
    value =
        testInput
        |> parseInput
        |> Result.map calcAnswer2

    value == Ok (26)
