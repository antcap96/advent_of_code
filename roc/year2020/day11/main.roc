app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br" }

import pf.Stdout
import pf.Path exposing [Path]

Seat : [Floor, Empty, Occupied]

Matrix a := { rows : U64, cols : U64, data : List (List a) } implements [Eq, Inspect]

matrixNRows : Matrix a -> U64
matrixNRows = \@Matrix m -> m.rows

matrixNCols : Matrix a -> U64
matrixNCols = \@Matrix m -> m.cols

matrixGet : Matrix a, U64, U64 -> Result a [OutOfBounds]
matrixGet = \@Matrix m, i, j ->
    List.get m.data i |> Result.try (\l -> List.get l j)

fromListOfList : List (List a) -> Result (Matrix a) [InconsistentColumns]
fromListOfList = \lst ->
    rows = List.len lst
    colsTest = List.walk lst Empty \state, elem ->
        cols = List.len elem
        when state is
            Empty -> All cols
            All soFar -> if soFar == cols then All soFar else Inconsistent
            Inconsistent -> Inconsistent

    when colsTest is
        Empty -> Ok (@Matrix { rows, cols: 0, data: lst })
        All cols -> Ok (@Matrix { rows, cols, data: lst })
        Inconsistent -> Err InconsistentColumns

matrixMap : Matrix a, (a -> b) -> Matrix b
matrixMap = \@Matrix m, func ->
    newData = List.map m.data \row ->
        List.map row \elem -> func elem

    @Matrix { cols: m.cols, rows: m.rows, data: newData }

matrixMapWithIndex : Matrix a, (a, U64, U64 -> b) -> Matrix b
matrixMapWithIndex = \@Matrix m, func ->
    newData = List.mapWithIndex m.data \row, i ->
        List.mapWithIndex row \elem, j -> func elem i j

    @Matrix { cols: m.cols, rows: m.rows, data: newData }

matrixWalk : Matrix a, state, (state, a -> state) -> state
matrixWalk = \@Matrix m, state, func ->
    List.walk m.data state \newState, row ->
        List.walk row newState func

parseInput : Str -> Result (Matrix Seat) Str
parseInput = \str ->
    str
        |> Str.trimEnd
        |> Str.split "\n"
        |> List.mapTry? parseRow
        |> fromListOfList
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
        when matrixGet matrix i j is
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
    matrixMapWithIndex matrix \elem, i, j ->
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
    matrixWalk finalMatrix 0 \state, elem ->
        if elem == Occupied then
            state + 1
        else
            state

isOcupiedInDirection2 : Matrix Seat, (U64, U64), (U64, U64) -> Bool
isOcupiedInDirection2 = \matrix, (atI, atJ), (dirI, dirJ) ->
    nextI = Num.addWrap atI dirI
    nextJ = Num.addWrap atJ dirJ
    when matrixGet matrix nextI nextJ is
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
    matrixMapWithIndex matrix \elem, i, j ->
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
    matrixWalk finalMatrix 0 \state, elem ->
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
