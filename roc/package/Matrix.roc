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

Matrix a := { rows : U64, cols : U64, data : List (List a) } implements [Eq, Inspect]


nRows : Matrix a -> U64
nRows = \@Matrix m -> m.rows

nCols : Matrix a -> U64
nCols = \@Matrix m -> m.cols

get : Matrix a, U64, U64 -> Result a [OutOfBounds]
get = \@Matrix m, i, j ->
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

map : Matrix a, (a -> b) -> Matrix b
map = \@Matrix m, func ->
    newData = List.map m.data \row ->
        List.map row \elem -> func elem

    @Matrix { cols: m.cols, rows: m.rows, data: newData }

mapWithIndex : Matrix a, (a, U64, U64 -> b) -> Matrix b
mapWithIndex = \@Matrix m, func ->
    newData = List.mapWithIndex m.data \row, i ->
        List.mapWithIndex row \elem, j -> func elem i j

    @Matrix { cols: m.cols, rows: m.rows, data: newData }

walk : Matrix a, state, (state, a -> state) -> state
walk = \@Matrix m, state, func ->
    List.walk m.data state \newState, row ->
        List.walk row newState func
