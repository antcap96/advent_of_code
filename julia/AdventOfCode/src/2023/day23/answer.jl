### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ cf2572b2-a72b-43ba-b85c-ba78f349fe29
using DataStructures

# ╔═╡ 68b82337-ea65-4091-872c-7f51dfd826e9
using Test

# ╔═╡ 42d0b1b6-981a-11ee-0a01-6f7d5b828f97
function load_data()
    readchomp(@__DIR__() * "/input.txt")
end

# ╔═╡ 83629869-c3af-4d78-97a1-1bcbc6941395
function parse_input(data)
	vcat(permutedims.(collect.(split(data, '\n')))...)
end

# ╔═╡ 1be950b4-3b80-4528-baa4-36bf812ae3be
function bfs(matrix, start, stop)
	visited = zeros(Bool, size(matrix))
	bfs(matrix, start, stop, visited, 0)
end

# ╔═╡ 785e20b7-4a53-488c-9d39-815e5ddc8149
function next_moves(matrix, start, visited)
	next = CartesianIndex{2}[]
	for delta in [
		CartesianIndex(-1,0),
		CartesianIndex(0,-1),
		CartesianIndex(1,0),
		CartesianIndex(0,1),
	]
		to = start+delta
		if (checkbounds(Bool, visited, to)
			&& !visited[to]
			&& (
				matrix[to] == '.'
				|| (matrix[to] == '>' && delta == CartesianIndex(0,1))
				|| (matrix[to] == 'v' && delta == CartesianIndex(1,0))
			))
			push!(next, to)
		end
	end
	next
end

# ╔═╡ d8fbc433-95e5-4c00-8329-458acba3b762
function bfs(matrix, at, stop, visited, distance)
	visited = copy(visited)
	visited[at] = true
	while at != stop
		moves = next_moves(matrix, at, visited)
		if length(moves) == 1
			at = moves[1]
			distance += 1
			visited[at] = true
		else
			return maximum(moves, init=-1) do at
				bfs(matrix, at, stop, visited, distance+1)
			end
				
		end
	end
	distance
end

# ╔═╡ 6b582f4e-32f6-4510-a23b-2fbe3152ab4d
function answer1(input)
	bottom = size(input, 1)
	start = CartesianIndex(1, findfirst(input[1,:] .== '.'))
	stop = CartesianIndex(bottom, findfirst(input[bottom,:] .== '.'))
	bfs(input, start, stop)
end

# ╔═╡ 592be7e1-234e-42fe-ae78-b94c60c19eab
function next_moves2(matrix, start, visited)
	next = CartesianIndex{2}[]
	for delta in [
		CartesianIndex(-1,0),
		CartesianIndex(0,-1),
		CartesianIndex(1,0),
		CartesianIndex(0,1),
	]
		to = start+delta
		if (checkbounds(Bool, visited, to)
			&& !visited[to]
			&& matrix[to] != '#'
			)
			push!(next, to)
		end
	end
	next
end

# ╔═╡ e0f45708-82ae-41e5-b425-050450cbb52c
function bfs2(matrix, at, visited)
	visited = copy(visited)
	visited[at] = true
	map(next_moves2(matrix, at, visited)) do start
		distance = 0
		at = start
		visited[at] = true
		while true
			moves = next_moves2(matrix, at, visited)
			if length(moves) == 1
				at = moves[1]
				distance += 1
				visited[at] = true
			else
				return (at, distance+1)
			end
		end
	end
end

# ╔═╡ 69182e67-6b09-4752-b673-08b242d0c2f6
function bfs3(edges, start, stop)
	visited = Set{CartesianIndex{2}}()
	bfs3(edges, start, stop, visited, 0)
end

# ╔═╡ 59dcfd79-b0d7-460a-9a5a-43d5e64de7ff
function bfs3(edges, at, stop, visited, distance)
	if at == stop
		return distance
	end
	visited = copy(visited)
	push!(visited, at)
	moves = filter(edges[at]) do (pos, d)
		!(pos in visited)
	end
	maximum(moves, init=-1) do (at, d)
		bfs3(edges, at, stop, visited, distance+d)
	end
end

# ╔═╡ 2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
function answer2(input)
	visited = zeros(Bool, size(input))

	bottom = size(input, 1)
	start = CartesianIndex(1, findfirst(input[1,:] .== '.'))
	stop = CartesianIndex(bottom, findfirst(input[bottom,:] .== '.'))
	
	edges = filter(CartesianIndices(input)) do index
		if input[index] != '#'
			neighboors = length(next_moves2(input, index, visited)) 
			neighboors > 2 || neighboors == 1
		else
			false
		end
	end 
	edges_ = map(edges) do edge
		edge => bfs2(input, edge, visited)
	end |> Dict{CartesianIndex{2}, Vector{Tuple{CartesianIndex{2}, Int}}}
	bfs3(edges_, start, stop)
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

# ╔═╡ 312576c0-ff06-41a4-b2d8-891ded62eef7
test_input_1 = "#.#####################
#.......#########...###
#######.#########.#.###
###.....#.>.>.###.#.###
###v#####.#v#.###.#.###
###.>...#.#.#.....#...#
###v###.#.#.#########.#
###...#.#.#.......#...#
#####.#.#.#######.#.###
#.....#.#.#.......#...#
#.#####.#.#.#########v#
#.#...#...#...###...>.#
#.#.#v#######v###.###v#
#...#.>.#...>.>.#.###.#
#####v#.#.###v#.#.###.#
#.....#...#...#.#.#...#
#.#########.###.#.#.###
#...###...#...#...#.###
###.###.#.###v#####v###
#...#...#.#.>.>.#.>.###
#.###.###.#.###.#.#v###
#.....###...###...#...#
#####################.#"

# ╔═╡ ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
@test answer1(test_input_1 |> parse_input) == 94

# ╔═╡ 708d9710-1d29-4aac-a35f-c28cfee0b45e
@test answer2(test_input_1 |> parse_input) == 154

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
# ╠═cf2572b2-a72b-43ba-b85c-ba78f349fe29
# ╠═42d0b1b6-981a-11ee-0a01-6f7d5b828f97
# ╠═83629869-c3af-4d78-97a1-1bcbc6941395
# ╠═1be950b4-3b80-4528-baa4-36bf812ae3be
# ╠═785e20b7-4a53-488c-9d39-815e5ddc8149
# ╠═d8fbc433-95e5-4c00-8329-458acba3b762
# ╠═6b582f4e-32f6-4510-a23b-2fbe3152ab4d
# ╠═592be7e1-234e-42fe-ae78-b94c60c19eab
# ╠═e0f45708-82ae-41e5-b425-050450cbb52c
# ╠═69182e67-6b09-4752-b673-08b242d0c2f6
# ╠═59dcfd79-b0d7-460a-9a5a-43d5e64de7ff
# ╠═2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
# ╠═aa10cf48-c754-4037-81f2-4c4220209637
# ╠═182d55e5-f46c-444e-95d9-b898cf48969b
# ╠═68b82337-ea65-4091-872c-7f51dfd826e9
# ╠═312576c0-ff06-41a4-b2d8-891ded62eef7
# ╠═ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
# ╠═708d9710-1d29-4aac-a35f-c28cfee0b45e
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
