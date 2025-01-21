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
unwrap = |res|
    when res is
        Ok(ok) -> ok
        Err(err) -> crash(Inspect.to_str(err))

empty : Ordering a -> HeapQueue a
empty = |ordering| @HeapQueue({ data: [], ordering })

parent = |i| (i - 1) // 2
left_child = |i| 2 * i + 1
right_child = |i| 2 * i + 2

heapify_up : List a, U64, Ordering a -> List a
heapify_up = |lst, idx, ordering|
    if idx == 0 then
        lst
    else
        one = List.get(lst, idx) |> unwrap
        two = List.get(lst, parent(idx)) |> unwrap
        if ordering(one, two) == LT then
            heapify_up(List.swap(lst, idx, parent(idx)), parent(idx), ordering)
        else
            lst

heapify_down : List a, U64, Ordering a -> List a
heapify_down = |lst, idx, ordering|
    left = left_child(idx)
    right = right_child(idx)

    idx_option = List.get(lst, idx)
    left_option = List.get(lst, left)
    right_option = List.get(lst, right)
    smallest =
        if
            (Result.map2(idx_option, left_option, ordering) |> Result.with_default(LT) != GT)
            and (Result.map2(idx_option, right_option, ordering) |> Result.with_default(LT) != GT)
        then
            idx
        else if (Result.map2(left_option, right_option, ordering) |> Result.with_default(LT) != GT) then
            left
        else
            right

    if smallest != idx then
        heapify_down(List.swap(lst, smallest, idx), smallest, ordering)
    else
        lst

insert : HeapQueue a, a -> HeapQueue a where a implements Inspect
insert = |@HeapQueue({ data, ordering }), value|
    tmp_list = List.append(data, value)
    new_data = heapify_up(tmp_list, (List.len(tmp_list) - 1), ordering)
    @HeapQueue({ data: new_data, ordering })

pop : HeapQueue a -> (HeapQueue a, Result a [HeapEmpty])
pop = |@HeapQueue({ data, ordering })|
    first = List.first(data) |> Result.map_err(|_| HeapEmpty)
    replaced_first = List.swap(data, 0, (List.len(data) - 1)) |> List.drop_last(1)
    new_heap = heapify_down(replaced_first, 0, ordering)
    (@HeapQueue({ data: new_heap, ordering }), first)

contents : HeapQueue a -> List a
contents = |@HeapQueue({ data })| data
