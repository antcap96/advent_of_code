### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ 68b82337-ea65-4091-872c-7f51dfd826e9
using Test

# ╔═╡ 42d0b1b6-981a-11ee-0a01-6f7d5b828f97
function load_data()
    readlines(@__DIR__() * "/input.txt")
end

# ╔═╡ 37725a67-02b1-45d6-b4b9-3e110aa03f8b
function parse_input(data)
	data = filter(!isempty, data)

    matrix = vcat(permutedims.(collect.(data))...)

	matrix
end

# ╔═╡ dc5bc992-1f09-4771-a0a3-a81467db4d53
@enum Direction begin
	Right=1
	Down=2
	Left=3
	Up=4
end

# ╔═╡ 4e5a0993-3871-44b3-89ec-d8a04552dbe9
const direction_map = Dict(
	Right => CartesianIndex(0,1),
	Down => CartesianIndex(1,0),
	Left => CartesianIndex(0,-1),
	Up => CartesianIndex(-1,0),
)

# ╔═╡ 96ecc081-1a3e-4e4c-879d-68e434e59927
function visit!(visited, matrix, point, direction::Direction)
	if !checkbounds(Bool, matrix, point)
		return
	end
	if visited[point, Int(direction)]
		return
	end
	visited[point, Int(direction)] = true
	if matrix[point] == '.'
		visit!(visited, matrix, point + direction_map[direction], direction)
	elseif matrix[point] == '|'
		if direction == Up || direction == Down
			visit!(visited, matrix, point + direction_map[direction], direction)
		elseif direction == Left || direction == Right
			visit!(visited, matrix, point + direction_map[Up], Up)
			visit!(visited, matrix, point + direction_map[Down], Down)
		end
	elseif matrix[point] == '-'
		if direction == Left || direction == Right
			visit!(visited, matrix, point + direction_map[direction], direction)
		elseif direction == Up || direction == Down
			visit!(visited, matrix, point + direction_map[Left], Left)
			visit!(visited, matrix, point + direction_map[Right], Right)
		end
	elseif matrix[point] == '/'
		if direction == Up
			visit!(visited, matrix, point + direction_map[Right], Right)
		elseif direction == Right
			visit!(visited, matrix, point + direction_map[Up], Up)
		elseif direction == Down
			visit!(visited, matrix, point + direction_map[Left], Left)
		elseif direction == Left
			visit!(visited, matrix, point + direction_map[Down], Down)
		end
	elseif matrix[point] == '\\'
		if direction == Up
			visit!(visited, matrix, point + direction_map[Left], Left)
		elseif direction == Left
			visit!(visited, matrix, point + direction_map[Up], Up)
		elseif direction == Down
			visit!(visited, matrix, point + direction_map[Right], Right)
		elseif direction == Right
			visit!(visited, matrix, point + direction_map[Down], Down)
		end
	else
		error(matrix[point])
	end
end

# ╔═╡ dbdba72b-a1c0-4ac9-89bc-079e833c7282
function energized(visited)
	sum(sum(visited, dims=3) .> 0)
end

# ╔═╡ 6b582f4e-32f6-4510-a23b-2fbe3152ab4d
function answer1(input)
	visited = zeros(Bool, size(input)..., length(instances(Direction)))
	visit!(visited, input, CartesianIndex(1,1), Right)

	energized(visited)
end

# ╔═╡ 2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
function answer2(input)
	maximum(
		Iterators.flatten(
			(
				Iterators.product([1], axes(input, 1), [Right]),
				Iterators.product([size(input, 2)], axes(input, 1), [Left]),
				Iterators.product([size(input, 1)], axes(input, 2), [Up]),
				Iterators.product([1], axes(input, 2), [Down]),
			)
		)
	) do (i, j, d)
		visited = zeros(Bool, size(input)..., length(instances(Direction)))
		visit!(visited, input, CartesianIndex(i,j), d)
	
		energized(visited)
	end
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
test_input_1 = raw".|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|....
" |> split_newline

# ╔═╡ ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
@test answer1(test_input_1 |> parse_input) == 46

# ╔═╡ 4681250a-cf09-42cc-b5dc-3777accb13c8
@test answer2(test_input_1 |> parse_input) == 51

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "71d91126b5a1fb1020e1098d9d492de2a4438fd2"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

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
"""

# ╔═╡ Cell order:
# ╠═42d0b1b6-981a-11ee-0a01-6f7d5b828f97
# ╠═37725a67-02b1-45d6-b4b9-3e110aa03f8b
# ╠═dc5bc992-1f09-4771-a0a3-a81467db4d53
# ╠═4e5a0993-3871-44b3-89ec-d8a04552dbe9
# ╠═96ecc081-1a3e-4e4c-879d-68e434e59927
# ╠═dbdba72b-a1c0-4ac9-89bc-079e833c7282
# ╠═6b582f4e-32f6-4510-a23b-2fbe3152ab4d
# ╠═2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
# ╠═aa10cf48-c754-4037-81f2-4c4220209637
# ╠═182d55e5-f46c-444e-95d9-b898cf48969b
# ╠═68b82337-ea65-4091-872c-7f51dfd826e9
# ╠═8013f1c8-2250-41bc-b78a-6c0f944ce5ec
# ╠═312576c0-ff06-41a4-b2d8-891ded62eef7
# ╠═ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
# ╠═4681250a-cf09-42cc-b5dc-3777accb13c8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
