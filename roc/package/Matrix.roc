module [
    Matrix,
    nRows,
    nCols,
    get,
    fromListOfList,
    map,
    mapWithIndex,
    walk,
    walkWithIndex,
    walkWithIndexUntil,
    replace,
    findFirstIndex,
]

Matrix a := { rows : U64, cols : U64, data : List a } implements [Eq, Inspect]

nRows : Matrix a -> U64
nRows = \@Matrix m -> m.rows

nCols : Matrix a -> U64
nCols = \@Matrix m -> m.cols

get : Matrix a, U64, U64 -> Result a [OutOfBounds]
get = \@Matrix m, i, j ->
    if i < m.rows && j < m.cols then
        List.get m.data (i * m.cols + j)
    else
        Err OutOfBounds

fromListOfList : List (List a) -> Result (Matrix a) [InconsistentColumns]
fromListOfList = \lst ->
    rows = List.len lst
    colsTest = List.walk lst Empty \state, elem ->
        cols = List.len elem
        when state is
            Empty -> All cols
            All soFar -> if soFar == cols then All soFar else Inconsistent
            Inconsistent -> Inconsistent

    data = List.walk lst [] List.concat
    when colsTest is
        Empty -> Ok (@Matrix { rows, cols: 0, data })
        All cols -> Ok (@Matrix { rows, cols, data })
        Inconsistent -> Err InconsistentColumns

map : Matrix a, (a -> b) -> Matrix b
map = \@Matrix m, func ->
    newData = List.map m.data func
    @Matrix { cols: m.cols, rows: m.rows, data: newData }

mapWithIndex : Matrix a, (a, U64, U64 -> b) -> Matrix b
mapWithIndex = \@Matrix m, func ->
    newData = List.mapWithIndex m.data \elem, i -> func elem (i // m.cols) (i % m.cols)
    @Matrix { cols: m.cols, rows: m.rows, data: newData }

walk : Matrix a, state, (state, a -> state) -> state
walk = \@Matrix m, state, func ->
    List.walk m.data state func

walkWithIndex : Matrix a, state, (state, a, U64, U64 -> state) -> state
walkWithIndex = \@Matrix m, state, func ->
    List.walkWithIndex m.data state \state2, elem, i -> func state2 elem (i // m.cols) (i % m.cols)

walkWithIndexUntil : Matrix a, state, (state, a, U64, U64 -> [Continue state, Break state]) -> state
walkWithIndexUntil = \@Matrix m, state, func ->
    List.walkWithIndexUntil m.data state \state2, elem, i -> func state2 elem (i // m.cols) (i % m.cols)

replace : Matrix a, U64, U64, a -> { matrix : Matrix a, value : a }
replace = \@Matrix m, i, j, toReplace ->
    { list: data, value } = List.replace m.data (i * m.cols + j) toReplace
    { matrix: @Matrix { cols: m.cols, rows: m.rows, data }, value }

findFirstIndex : Matrix a, (a -> Bool) -> Result (U64, U64) [NotFound]
findFirstIndex = \m, isThis ->
    walkWithIndexUntil m (Err NotFound) \_, value, i, j ->
        if isThis value then
            Break (Ok (i, j))
        else
            Continue (Err NotFound)
