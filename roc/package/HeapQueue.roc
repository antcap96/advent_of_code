module [
    HeapQueue,
    empty,
    insert,
    pop,
    contents,
]

Ordering a : a, a -> [LT, GT, EQ]
HeapQueue a := { data : List a, ordering : Ordering a }

unwrap : Result ok err -> ok where err implements Inspect
unwrap = \res ->
    when res is
        Ok ok -> ok
        Err err -> crash (Inspect.toStr err)

empty : Ordering a -> HeapQueue a
empty = \ordering -> @HeapQueue { data: [], ordering }

parent = \i -> (i - 1) // 2
leftChild = \i -> 2 * i + 1
rightChild = \i -> 2 * i + 2

heapifyUp : List a, U64, Ordering a -> List a
heapifyUp = \lst, idx, ordering ->
    if idx == 0 then
        lst
    else
        one = List.get lst idx |> unwrap
        two = List.get lst (parent idx) |> unwrap
        if ordering one two == LT then
            heapifyUp (List.swap lst idx (parent idx)) (parent idx) ordering
        else
            lst

heapifyDown : List a, U64, Ordering a -> List a
heapifyDown = \lst, idx, ordering ->
    left = leftChild idx
    right = rightChild idx

    idxOption = List.get lst idx
    leftOption = List.get lst left
    rightOption = List.get lst right
    smallest =
        if
            (Result.map2 idxOption leftOption ordering |> Result.withDefault LT != GT)
            && (Result.map2 idxOption rightOption ordering |> Result.withDefault LT != GT)
        then
            idx
        else if (Result.map2 leftOption rightOption ordering |> Result.withDefault LT != GT) then
            left
        else
            right
    
    if smallest != idx then
        heapifyDown (List.swap lst smallest idx) smallest ordering
    else
        lst


insert : HeapQueue a, a -> HeapQueue a where a implements Inspect
insert = \@HeapQueue { data, ordering }, value ->
    tmpList = List.append data value
    newData = heapifyUp tmpList (List.len tmpList - 1) ordering
    @HeapQueue { data: newData, ordering }

pop : HeapQueue a -> (HeapQueue a, Result a [HeapEmpty])
pop = \@HeapQueue { data, ordering } ->
    first = List.first data |> Result.mapErr \_ -> HeapEmpty
    replacedFirst = List.swap data 0 (List.len data - 1) |> List.dropLast 1
    newHeap = heapifyDown replacedFirst 0 ordering
    (@HeapQueue { data: newHeap, ordering }, first)

contents : HeapQueue a -> List a
contents = \@HeapQueue { data } -> data
