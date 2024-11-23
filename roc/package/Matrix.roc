module [
    Matrix,
    nRows,
    nCols,
    get,
    fromListOfList,
    map,
    mapWithIndex,
    walk,
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
