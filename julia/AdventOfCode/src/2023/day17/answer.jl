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

# ╔═╡ 37725a67-02b1-45d6-b4b9-3e110aa03f8b
function parse_input(data)
    data = filter(!isempty, data)

    matrix = parse.(Int, vcat(permutedims.(collect.(data))...))

    matrix
end

# ╔═╡ dc5bc992-1f09-4771-a0a3-a81467db4d53
@enum Direction begin
    Right = 1
    Down = 2
    Left = 3
    Up = 4
end

# ╔═╡ fc77ac42-d45a-424d-94fb-f82551b309ff
struct CrucibleState{T}
    move::Int
    direction::Direction
end

# ╔═╡ 1468ef0b-ff3e-4bf9-b57b-1b7dd06da085
max_moves(::Type{CrucibleState{1}}) = 3

# ╔═╡ 5799a8d3-7273-47ab-baa3-a5d861e5a388
max_moves(::Type{CrucibleState{2}}) = 10

# ╔═╡ 0babc792-c48d-4971-bc2b-90ee3d87ab43
function index(state::T) where {T<:CrucibleState}
    state.move + (Int(state.direction) - 1) * max_moves(T)
end

# ╔═╡ ded55e98-0c49-427d-9710-18dd3a096857
function Base.instances(::Type{T}) where {T<:CrucibleState}
    [T(i, d) for i in 1:max_moves(T), d in instances(Direction)]
end

# ╔═╡ 2cb4a7a0-1598-48f9-ad23-5d3b858aeb56
function turn_left(direction::Direction)
    Direction(
        mod((Int(direction) - 2), 4) + 1
    )
end

# ╔═╡ 1c495002-0f0a-4afa-a05f-640827da6237
function turn_right(direction::Direction)
    Direction(
        mod(Int(direction), 4) + 1
    )
end

# ╔═╡ 73f7a1a8-fcac-4bab-8efc-43c80f05f999
function next_moves(state::CrucibleState{1})
    moves = CrucibleState{1}[
        CrucibleState{1}(1, turn_left(state.direction)),
        CrucibleState{1}(1, turn_right(state.direction)),
    ]
    if state.move < 3
        push!(moves,
            CrucibleState{1}(state.move + 1, state.direction)
        )
    end
    moves
end

# ╔═╡ 9ba063b6-2860-462d-a3d3-b1cb69c56701
function next_moves(state::CrucibleState{2})
    moves = if state.move < 10
        CrucibleState{2}[CrucibleState{2}(state.move + 1, state.direction)]
    else
        CrucibleState{2}[]
    end
    if state.move >= 4
        push!(moves, CrucibleState{2}(1, turn_left(state.direction)))
        push!(moves, CrucibleState{2}(1, turn_right(state.direction)))
    end
    moves
end

# ╔═╡ 4e5a0993-3871-44b3-89ec-d8a04552dbe9
const direction_map = Dict(
    Right => CartesianIndex(0, 1),
    Down => CartesianIndex(1, 0),
    Left => CartesianIndex(0, -1),
    Up => CartesianIndex(-1, 0),
)

# ╔═╡ 96ecc081-1a3e-4e4c-879d-68e434e59927
function dijkstra(::Type{T}, matrix) where {T<:CrucibleState}
    distances = fill(typemax(Int), size(matrix)..., length(instances(T)))
    pq = PriorityQueue{Tuple{CartesianIndex,T},Int}()

    for (p, d) in (
        (CartesianIndex(1, 2), T(1, Right)),
        (CartesianIndex(2, 1), T(1, Down)),
    )
        distances[p, index(d)] = matrix[p]
        enqueue!(pq, (p, d) => distances[p, index(d)])
    end

    while !isempty(pq)
        point, state = dequeue!(pq)
        for next_state in next_moves(state)
            next_point = point + direction_map[next_state.direction]
            if !checkbounds(Bool, matrix, next_point)
                continue
            end
            cost = distances[point, index(state)] + matrix[next_point]
            if cost < distances[next_point, index(next_state)]
                distances[next_point, index(next_state)] = cost
                pq[(next_point, next_state)] = cost
            end
        end
    end
    distances
end

# ╔═╡ 6b582f4e-32f6-4510-a23b-2fbe3152ab4d
function answer1(input)
    distances = dijkstra(CrucibleState{1}, input)
    minimum(distances[end, end, :])
end

# ╔═╡ 2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
function answer2(input)
    distances = dijkstra(CrucibleState{2}, input)
    minimum(distances[end, end, [
        index(state) for state in instances(CrucibleState{2}) if state.move >= 4
    ]])
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

# ╔═╡ 8013f1c8-2250-41bc-b78a-6c0f944ce5ec
split_newline = s -> split(s, '\n')

# ╔═╡ 312576c0-ff06-41a4-b2d8-891ded62eef7
test_input_1 = "2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
" |> split_newline

# ╔═╡ 22ecd1d8-c1ff-43bd-9d6f-da20774ee626
test_input_2 = "111111111111
999999999991
999999999991
999999999991
999999999991
" |> split_newline

# ╔═╡ ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
@test answer1(test_input_1 |> parse_input) == 102

# ╔═╡ 4681250a-cf09-42cc-b5dc-3777accb13c8
@test answer2(test_input_1 |> parse_input) == 94

# ╔═╡ da86346b-69cd-4e1a-bdfe-65b276b90150
@test answer2(test_input_2 |> parse_input) == 71

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
# ╠═fc77ac42-d45a-424d-94fb-f82551b309ff
# ╠═73f7a1a8-fcac-4bab-8efc-43c80f05f999
# ╠═9ba063b6-2860-462d-a3d3-b1cb69c56701
# ╠═1468ef0b-ff3e-4bf9-b57b-1b7dd06da085
# ╠═5799a8d3-7273-47ab-baa3-a5d861e5a388
# ╠═0babc792-c48d-4971-bc2b-90ee3d87ab43
# ╠═ded55e98-0c49-427d-9710-18dd3a096857
# ╠═dc5bc992-1f09-4771-a0a3-a81467db4d53
# ╠═2cb4a7a0-1598-48f9-ad23-5d3b858aeb56
# ╠═1c495002-0f0a-4afa-a05f-640827da6237
# ╠═4e5a0993-3871-44b3-89ec-d8a04552dbe9
# ╠═96ecc081-1a3e-4e4c-879d-68e434e59927
# ╠═6b582f4e-32f6-4510-a23b-2fbe3152ab4d
# ╠═2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
# ╠═aa10cf48-c754-4037-81f2-4c4220209637
# ╠═182d55e5-f46c-444e-95d9-b898cf48969b
# ╠═68b82337-ea65-4091-872c-7f51dfd826e9
# ╠═8013f1c8-2250-41bc-b78a-6c0f944ce5ec
# ╠═312576c0-ff06-41a4-b2d8-891ded62eef7
# ╠═22ecd1d8-c1ff-43bd-9d6f-da20774ee626
# ╠═ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
# ╠═4681250a-cf09-42cc-b5dc-3777accb13c8
# ╠═da86346b-69cd-4e1a-bdfe-65b276b90150
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
