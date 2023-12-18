### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ 05c6fb62-9056-445a-b6f8-4e74cfaf13f0
using DataStructures

# ╔═╡ 68b82337-ea65-4091-872c-7f51dfd826e9
using Test

# ╔═╡ 42d0b1b6-981a-11ee-0a01-6f7d5b828f97
function load_data()
    readlines(@__DIR__() * "/input.txt")
end

# ╔═╡ dc5bc992-1f09-4771-a0a3-a81467db4d53
@enum Direction begin
    Right = 1
    Down = 2
    Left = 3
    Up = 4
end

# ╔═╡ a273bc81-b96d-4315-a5dd-094d4ce23a5b
const direction_parser = Dict(
    "R" => Right,
    "L" => Left,
    "D" => Down,
    "U" => Up,
)

# ╔═╡ 4e5a0993-3871-44b3-89ec-d8a04552dbe9
const direction_map = Dict(
    Right => CartesianIndex(0, 1),
    Down => CartesianIndex(1, 0),
    Left => CartesianIndex(0, -1),
    Up => CartesianIndex(-1, 0),
)

# ╔═╡ 8013f1c8-2250-41bc-b78a-6c0f944ce5ec
split_newline = s -> split(s, '\n')

# ╔═╡ 312576c0-ff06-41a4-b2d8-891ded62eef7
test_input_1 = "R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
" |> split_newline

# ╔═╡ 8cba22a8-83e8-4b59-bf56-d945552154dc
function combine_consecutive(arr::Vector{Tuple{Int,UnitRange{Int}}})
    output = Tuple{Int,UnitRange{Int}}[]
    for (i, range) in arr
        if isempty(range)
            continue
        end
        if isempty(output)
            push!(output, (i, range))
        else
            (j, last) = output[end]
            if last.stop + 1 == range.start && i == j
                output[end] = (i, last.start:range.stop)
            else
                push!(output, (i, range))
            end
        end
    end
    output
end

# ╔═╡ 441c3d2d-7c57-4646-80b8-4ce06e3244b2
begin
    struct RangeSet
        ranges::Vector{Tuple{Int,UnitRange{Int}}}
        function RangeSet(ranges::Vector{Tuple{Int,UnitRange{Int}}})
            new(ranges |> sort |> combine_consecutive)
        end
    end
    RangeSet() = RangeSet(Tuple{Int,UnitRange{Int}}[])
    RangeSet(range::Tuple{Int,UnitRange{Int}}) = RangeSet([range])
end

# ╔═╡ 58aee5fd-6d06-4fa4-bd57-3bba1e2557bf
begin
    function Base.intersect(a::RangeSet, b::RangeSet)
        intersections = map(b.ranges) do range
            intersect(a, range)
        end
        RangeSet(filter(!isempty, intersections))
    end

    function Base.intersect(a::RangeSet, b::UnitRange{Int})
        intersections = map(a.ranges) do (i, range)
            (i, intersect(range, b))
        end
        RangeSet(filter(!isempty, intersections))
    end

    function Base.isempty(ranges::RangeSet)
        isempty(ranges.ranges)
    end

    function Base.:(+)(ranges::RangeSet, delta::Int)
        RangeSet(
            map(ranges.ranges) do range
                range .+ delta
            end
        )
    end

    function Base.union(r1::RangeSet, r2::RangeSet)
        r2 = setdiff(r2, r1)
        #println("HERE:  $r1  $r2")
        RangeSet([r1.ranges; r2.ranges])
    end

    function Base.setdiff(r1::RangeSet, r2::RangeSet)
        output = r1
        for (i, r) in r2.ranges
            output = setdiff(output, r)
        end
        output
    end

    function Base.setdiff(ranges::RangeSet, r::UnitRange{Int})
        output = Tuple{Int,UnitRange{Int}}[]
        for (i, range) in ranges.ranges
            intersection = intersect(range, r)
            if isempty(intersection)
                push!(output, (i, range))
            else
                start = range.start:(intersection.start-1)
                if !isempty(start)
                    push!(output, (i, start))
                end
                stop = (intersection.stop+1):range.stop
                if !isempty(stop)
                    push!(output, (i, stop))
                end
            end
        end
        RangeSet(output)
    end

    function Base.minimum(ranges::RangeSet)
        minimum(ranges.ranges) do range
            minimum(range)
        end
    end
    function Base.length(ranges::RangeSet)
        sum(length, ranges.ranges)
    end
    function Base.length(ranges::RangeSet)
        sum(length, ranges.ranges, init=0)
    end
    function Base.intersect(a::RangeSet, b::RangeSet)
        intersections = map(b.ranges) do (i, range)
            intersect(a, range)
        end
        reduce(union, intersections)
    end
end

# ╔═╡ 37725a67-02b1-45d6-b4b9-3e110aa03f8b
function parse_input(data)
    data = filter(!isempty, data)

    map(split.(data, ' ')) do (direction, amount, color)
        dir = direction_parser[direction]
        amt = parse(Int, amount)
        rbg = color
        (dir, amt, rbg)
    end
end

# ╔═╡ bc746d45-47da-4db3-abd9-73a57483b44d
function turn_left(direction::Direction)
    Direction(
        mod((Int(direction) - 2), 4) + 1
    )
end

# ╔═╡ 953e8081-d532-4a2f-92f1-3fa0a40db63f
function turn_right(direction::Direction)
    Direction(
        mod(Int(direction), 4) + 1
    )
end

# ╔═╡ 7edabf3f-723c-4bd3-a176-f77c760b34db
function explore(input, start)
    visited = Set{CartesianIndex}()
    for (direction, amount, _) in input
        for i in 1:amount
            start += direction_map[direction]
            push!(visited, start)
        end
    end
    visited
end

# ╔═╡ 79ce5b9c-0b31-4716-b500-5f570e6aac19
function exploration_to_matrix(visited)
    visited2 = collect(visited)
    start = minimum(visited2)
    visited3 = [-start + p + CartesianIndex(1, 1) for p in visited2]
    stop = maximum(visited3)
    matrix = zeros(Bool, stop[1], stop[2])
    matrix[visited3] .= true
    matrix
end

# ╔═╡ 1a70911c-5572-402e-9b73-8563f7a81175
function identify_point(matrix)
    for i in axes(matrix, 1)
        for j in axes(matrix, 2)
            if matrix[i, j]
                if matrix[i, j+1]
                    break
                else
                    return CartesianIndex(i, j + 1)
                end
            end
        end
    end
end

# ╔═╡ e917e565-9b4c-4f9b-93ca-3bcc42dda4e9
function flood!(matrix, start)
    to_visit = CartesianIndex[start]
    while !isempty(to_visit)
        point = pop!(to_visit)
        if matrix[point]
            continue
        else
            matrix[point] = true
            for dir in values(direction_map)
                push!(to_visit, point + dir)
            end
        end
    end
end

# ╔═╡ a246bca2-8486-47aa-98d6-2f5ecf24380f
function get_lines(input::Vector{Tuple{Direction,Int}})
    start = CartesianIndex(0, 0)
    vertical_lines = SortedDict{Int,RangeSet}()

    prev_direction = [input[end][1]; map(x -> x[1], input[1:end-1])]
    next_direction = [map(x -> x[1], input[2:end]); input[1][1]]
    for ((direction, distance), pd, nd) in zip(input, prev_direction, next_direction)
        stop = start + direction_map[direction] * distance
        if direction == Up || direction == Down
            if pd == Right && direction == Up
                s = start[1] - 1
            elseif pd == Left && direction == Down
                s = start[1] + 1
            else
                s = start[1]
            end

            if nd == Left && direction == Up
                e = stop[1] + 1
            elseif nd == Right && direction == Down
                e = stop[1] - 1
            else
                e = stop[1]
            end

            range = RangeSet((start[2], min(s, e):max(s, e)))

            if haskey(vertical_lines, start[2])
                vertical_lines[start[2]] = union(vertical_lines[start[2]], range)
            else
                vertical_lines[start[2]] = range
            end
        end
        start = stop
    end
    vertical_lines
end

# ╔═╡ 3fa273be-a308-4c5a-9e8c-81d632d07240
function get_area(vertical_lines)
    total_area = 0
    prev_lines = RangeSet()
    prev_x = 0
    for (x, lines) in vertical_lines
        intersection = intersect(prev_lines, lines)

        for (x_start, range) in intersection.ranges
            total_area += (x - x_start + 1) * length(range)
        end
        prev_lines = setdiff(prev_lines, intersection) ∪ setdiff(lines, intersection)
        prev_x = x
    end
    total_area
end

# ╔═╡ 6b582f4e-32f6-4510-a23b-2fbe3152ab4d
function answer1(input)
    instructions = map(input) do (direction, distance, _hex)
        (direction, distance)
    end
    instructions |> get_lines |> get_area
end

# ╔═╡ ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
@test answer1(test_input_1 |> parse_input) == 62

# ╔═╡ 2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
function answer2(input)
    instructions = map(input) do (_, _, hex)
        direction = Dict(
            "0" => Right,
            "1" => Down,
            "2" => Left,
            "3" => Up
        )[hex[8:8]]
        distance = parse(Int, hex[3:7], base=16)
        (direction, distance)
    end
    instructions |> get_lines |> get_area
end

# ╔═╡ aa10cf48-c754-4037-81f2-4c4220209637
function answer()
    data = load_data()

    input = parse_input(data)

    ans1 = answer1(input)
    ans2 = answer2(input)

    println("Answer 1 is: $ans1")
    println("Answer 2 is: $ans2")
end

# ╔═╡ 182d55e5-f46c-444e-95d9-b898cf48969b
answer()

# ╔═╡ 42e107d0-1d63-4b6b-b575-de42c85a23ba
@test answer2(test_input_1 |> parse_input) == 952408144115

# ╔═╡ 28030910-8708-4e9e-95c3-b94d4d8fadb2
begin
    aaa = load_data() |> parse_input
    bbb = map(aaa) do (x, y, _)
        (x, y)
    end
    get_lines(bbb) |> get_area
end

# ╔═╡ 02c0880f-2eab-4d0c-8ade-4ad671ba69f6
begin
    aaa2 = test_input_1 |> parse_input
    bbb2 = map(aaa2) do (_, _, hex)
        direction = Dict(
            "0" => Right,
            "1" => Down,
            "2" => Left,
            "3" => Up
        )[hex[8:8]]
        distance = parse(Int, hex[3:7], base=16)
        (direction, distance)
    end
    get_lines(bbb2) |> get_area
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataStructures = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[compat]
DataStructures = "~0.18.15"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "b61a7ee815462e4ac4d40c44f7d9f928384fcca5"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "886826d76ea9e72b35fcd000e535588f7b60f21d"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.1"

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

    [deps.Compat.weakdeps]
    Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
"""

# ╔═╡ Cell order:
# ╠═05c6fb62-9056-445a-b6f8-4e74cfaf13f0
# ╠═42d0b1b6-981a-11ee-0a01-6f7d5b828f97
# ╠═37725a67-02b1-45d6-b4b9-3e110aa03f8b
# ╠═dc5bc992-1f09-4771-a0a3-a81467db4d53
# ╠═bc746d45-47da-4db3-abd9-73a57483b44d
# ╠═953e8081-d532-4a2f-92f1-3fa0a40db63f
# ╠═a273bc81-b96d-4315-a5dd-094d4ce23a5b
# ╠═4e5a0993-3871-44b3-89ec-d8a04552dbe9
# ╠═7edabf3f-723c-4bd3-a176-f77c760b34db
# ╠═79ce5b9c-0b31-4716-b500-5f570e6aac19
# ╠═1a70911c-5572-402e-9b73-8563f7a81175
# ╠═e917e565-9b4c-4f9b-93ca-3bcc42dda4e9
# ╠═6b582f4e-32f6-4510-a23b-2fbe3152ab4d
# ╠═2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
# ╠═aa10cf48-c754-4037-81f2-4c4220209637
# ╠═182d55e5-f46c-444e-95d9-b898cf48969b
# ╠═68b82337-ea65-4091-872c-7f51dfd826e9
# ╠═8013f1c8-2250-41bc-b78a-6c0f944ce5ec
# ╠═312576c0-ff06-41a4-b2d8-891ded62eef7
# ╠═ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
# ╠═42e107d0-1d63-4b6b-b575-de42c85a23ba
# ╠═a246bca2-8486-47aa-98d6-2f5ecf24380f
# ╠═3fa273be-a308-4c5a-9e8c-81d632d07240
# ╠═28030910-8708-4e9e-95c3-b94d4d8fadb2
# ╠═02c0880f-2eab-4d0c-8ade-4ad671ba69f6
# ╠═441c3d2d-7c57-4646-80b8-4ce06e3244b2
# ╠═8cba22a8-83e8-4b59-bf56-d945552154dc
# ╠═58aee5fd-6d06-4fa4-bd57-3bba1e2557bf
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
