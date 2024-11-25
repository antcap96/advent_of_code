app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br" }

import pf.Stdout
import pf.Path exposing [Path]

BoardingPass : { row : U64, col : U64 }

parseRow : List U8 -> Result U64 Str
parseRow = \lst ->
    List.reverse lst
    |> List.mapWithIndex \elem, index -> (elem, index)
    |> List.walkTry 0 \state, (elem, index) ->
        when elem is
            'B' -> Ok (state + (Num.powInt 2 index))
            'F' -> Ok state
            _ -> Err "invalid character in row '$(Num.toStr elem)'"

parseCol : List U8 -> Result U64 Str
parseCol = \lst ->
    List.reverse lst
    |> List.mapWithIndex \elem, index -> (elem, index)
    |> List.walkTry 0 \state, (elem, index) ->
        when elem is
            'R' -> Ok (state + (Num.powInt 2 index))
            'L' -> Ok state
            _ -> Err "invalid character in row '$(Num.toStr elem)'"

parseBoardingPass : Str -> Result BoardingPass Str
parseBoardingPass = \str ->
    Str.toUtf8 str
        |> List.splitAt 7
        |> \{ before, others } ->
            row = parseRow? before
            col = parseCol? others
            Ok { row, col }

parseInput : Str -> Result (List BoardingPass) Str
parseInput = \str ->
    str
    |> Str.trimEnd
    |> Str.splitOn "\n"
    |> List.mapTry parseBoardingPass

boardingPassId : BoardingPass -> U64
boardingPassId = \pass -> pass.row * 8 + pass.col

calcAnswer1 : List BoardingPass -> Result U64 Str
calcAnswer1 = \lst ->
    lst
    |> List.map boardingPassId
    |> List.max
    |> Result.mapErr \_ -> "List was empty"

calcAnswer2 : List BoardingPass -> Result U64 Str
calcAnswer2 = \lst ->
    solutions =
        lst
        |> List.map boardingPassId
        |> List.walk (Dict.empty {}) addNewSeen
        |> Dict.keepIf \(_, state) -> state == TwoNeighboors
        |> Dict.toList

    when solutions is
        [(solution, _)] -> Ok solution
        _ -> Err "Invalid number of solutions $(Inspect.toStr solutions)"

## Keep track of how many neighboors each boardingId has, or if the seat has been seen
## already
PossibleBoardingIds : Dict U64 [OneNeighboor, TwoNeighboors, Seen]
addNewSeen : PossibleBoardingIds, U64 -> PossibleBoardingIds
addNewSeen = \dict, boardId ->
    neighboors = [boardId + 1, boardId - 1]

    neighboors
    |> List.walk dict \state, neighboor ->
        when Dict.get state neighboor is
            Err KeyNotFound -> state |> Dict.insert neighboor OneNeighboor
            Ok OneNeighboor -> state |> Dict.insert neighboor TwoNeighboors
            Ok TwoNeighboors -> crash "3 neighboors?"
            Ok Seen -> state
    |> Dict.insert boardId Seen

main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2020/day5.txt")

    parsed = parseInput input

    answer1 = Result.try parsed calcAnswer1
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

expect "BFFFBBFRRR" |> parseBoardingPass == Ok { row: 70, col: 7 }
expect "FFFBBBFRRR" |> parseBoardingPass == Ok { row: 14, col: 7 }
expect "BBFFBBFRLL" |> parseBoardingPass == Ok { row: 102, col: 4 }
