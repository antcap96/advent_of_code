module [
    Matrix,
    n_rows,
    n_cols,
    get,
    from_list_of_list,
    map,
    map_with_index,
    walk,
    walk_with_index,
    walk_with_index_until,
    replace,
    find_first_index,
    walk_rows,
    walk_cols,
]

Matrix a := { rows : U64, cols : U64, data : List a } implements [Eq, Inspect]

n_rows : Matrix a -> U64
n_rows = |@Matrix(m)| m.rows

n_cols : Matrix a -> U64
n_cols = |@Matrix(m)| m.cols

get : Matrix a, U64, U64 -> Result a [OutOfBounds]
get = |@Matrix(m), i, j|
    if i < m.rows and j < m.cols then
        List.get(m.data, (i * m.cols + j))
    else
        Err(OutOfBounds)

from_list_of_list : List (List a) -> Result (Matrix a) [InconsistentColumns]
from_list_of_list = |lst|
    rows = List.len(lst)
    cols_test = List.walk(
        lst,
        Empty,
        |state, elem|
            cols = List.len(elem)
            when state is
                Empty -> All(cols)
                All(so_far) -> if so_far == cols then All(so_far) else Inconsistent
                Inconsistent -> Inconsistent,
    )

    data = List.walk(lst, [], List.concat)
    when cols_test is
        Empty -> Ok(@Matrix({ rows, cols: 0, data }))
        All(cols) -> Ok(@Matrix({ rows, cols, data }))
        Inconsistent -> Err(InconsistentColumns)

map : Matrix a, (a -> b) -> Matrix b
map = |@Matrix(m), func|
    new_data = List.map(m.data, func)
    @Matrix({ cols: m.cols, rows: m.rows, data: new_data })

map_with_index : Matrix a, (a, U64, U64 -> b) -> Matrix b
map_with_index = |@Matrix(m), func|
    new_data = List.map_with_index(m.data, |elem, i| func(elem, (i // m.cols), (i % m.cols)))
    @Matrix({ cols: m.cols, rows: m.rows, data: new_data })

walk : Matrix a, state, (state, a -> state) -> state
walk = |@Matrix(m), state, func|
    List.walk(m.data, state, func)

walk_with_index : Matrix a, state, (state, a, U64, U64 -> state) -> state
walk_with_index = |@Matrix(m), state, func|
    List.walk_with_index(m.data, state, |state2, elem, i| func(state2, elem, (i // m.cols), (i % m.cols)))

walk_with_index_until : Matrix a, state, (state, a, U64, U64 -> [Continue state, Break state]) -> state
walk_with_index_until = |@Matrix(m), state, func|
    List.walk_with_index_until(m.data, state, |state2, elem, i| func(state2, elem, (i // m.cols), (i % m.cols)))

replace : Matrix a, U64, U64, a -> { matrix : Matrix a, value : a }
replace = |@Matrix(m), i, j, to_replace|
    { list: data, value } = List.replace(m.data, (i * m.cols + j), to_replace)
    { matrix: @Matrix({ cols: m.cols, rows: m.rows, data }), value }

find_first_index : Matrix a, (a -> Bool) -> Result (U64, U64) [NotFound]
find_first_index = |m, is_this|
    walk_with_index_until(
        m,
        Err(NotFound),
        |_, value, i, j|
            if is_this(value) then
                Break(Ok((i, j)))
            else
                Continue(Err(NotFound)),
    )

walk_rows : Matrix a, state, (state, a -> state) -> List state
walk_rows = |m, initial_element, f|
    unsafe_get = |lst, i|
        when List.get(lst, i) is
            Ok ok -> ok
            Err _ -> crash "ups"
    initial = List.repeat(initial_element, n_rows(m))
    walk_with_index(
        m,
        initial,
        |state, elem, i, _|
            next_elem = f(unsafe_get(state, i), elem)
            { list } = List.replace(state, i, next_elem)
            list,
    )

walk_cols : Matrix a, state, (state, a -> state) -> List state
walk_cols = |m, initial_element, f|
    unsafe_get = |lst, i|
        when List.get(lst, i) is
            Ok(ok) -> ok
            Err(_) -> crash "ups"
    initial = List.repeat(initial_element, n_cols(m))
    walk_with_index(
        m,
        initial,
        |state, elem, _, i|
            next_elem = f(unsafe_get(state, i), elem)
            { list } = List.replace(state, i, next_elem)
            list,
    )
