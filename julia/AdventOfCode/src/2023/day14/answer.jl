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

# ╔═╡ 66052ae3-0ddf-4c3c-9a0d-2d9d3fe8682f
@enum Direction North West South East

# ╔═╡ f0f25670-5572-4e98-aa2a-fd387e2c9d89
function slide(matrix, direction::Direction)
	output = fill('.', size(matrix))
	if direction == North
		for x in axes(matrix, 2)
			y_to = 1
			for y in axes(matrix, 1)
				if matrix[y, x] == 'O'
					output[y_to, x] = 'O'
					y_to += 1
				end
				if matrix[y, x] == '#'
					output[y, x] = '#'
					y_to = y+1
				end
			end
		end
	elseif direction == East
		for y in axes(matrix, 1)
			x_to = 1
			for x in axes(matrix, 2)
				if matrix[y, x] == 'O'
					output[y, x_to] = 'O'
					x_to += 1
				end
				if matrix[y, x] == '#'
					output[y, x] = '#'
					x_to = x+1
				end
			end
		end
	elseif direction == South
		output = slide((@view matrix[end:-1:1, :]), North)[end:-1:1, :]
	elseif direction == West
		output = slide((@view matrix[:, end:-1:1]), East)[:, end:-1:1]
	end
	output
end

# ╔═╡ 0291ad51-c31b-457e-8a27-6f1056693e2c
function total_load(matrix)
	(matrix .== 'O')' * (size(matrix, 1):-1:1) |> sum
end

# ╔═╡ a9d50b91-a713-4619-815f-3196030832f3
answer1(input) = total_load(slide(input, North))

# ╔═╡ f3566289-9f6f-4de7-aa67-b4a94e78180b
cycle(matrix) = slide(slide(slide(slide(matrix, North), East), South), West)

# ╔═╡ 2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
function answer2(input)
	# Warmup to reach a loop
	warmup_cycles = 500
	for i in 1:warmup_cycles
		input = cycle(input)
	end
	loop_size = 1
	_start = input
	while true
		input = cycle(input)
		if input == _start
			break
		end
		loop_size += 1
	end
	loop_start = 1_000_000_000 % loop_size
	# loop_start + n * loop_size >= warmup_cycles
	# n >= (warmup_cycles - loop_start) // n
	n = ceil((warmup_cycles - loop_start) / loop_size)
	_end = loop_start + n * loop_size
	for i in (warmup_cycles+1):_end
		input = cycle(input)
	end
	total_load(input)
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
test_input_1 = "O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
" |> split_newline

# ╔═╡ 73b4b255-42a3-44fe-820b-768e4feec605
test_output_1 = ".....#....
....#...O#
...OO##...
.OO#......
.....OOO#.
.O#...O#.#
....O#....
......OOOO
#...O###..
#..OO#....
" |> split_newline

# ╔═╡ 6bce133b-07af-48cf-a465-9f546c0bc839
test_output_2 = ".....#....
....#...O#
.....##...
..O#......
.....OOO#.
.O#...O#.#
....O#...O
.......OOO
#..OO###..
#.OOO#...O
" |> split_newline

# ╔═╡ 0cb17879-626c-4a1b-ad34-912c41862ba1
test_output_3 = ".....#....
....#...O#
.....##...
..O#......
.....OOO#.
.O#...O#.#
....O#...O
.......OOO
#...O###.O
#.OOO#...O
" |> split_newline

# ╔═╡ ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
@test answer1(test_input_1 |> parse_input) == 136

# ╔═╡ 60c65c46-3d47-4eba-aee6-66eb9268b08f
@test test_input_1 |> parse_input |> cycle == test_output_1 |> parse_input

# ╔═╡ e0421caa-e416-414e-a662-49b856529e61
@test test_input_1 |> parse_input |> cycle |> cycle == test_output_2 |> parse_input

# ╔═╡ 0610017c-5571-420d-8605-568c34e2e972
@test test_input_1 |> parse_input |> cycle |> cycle |> cycle == test_output_3 |> parse_input

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
# ╠═66052ae3-0ddf-4c3c-9a0d-2d9d3fe8682f
# ╠═f0f25670-5572-4e98-aa2a-fd387e2c9d89
# ╠═0291ad51-c31b-457e-8a27-6f1056693e2c
# ╠═a9d50b91-a713-4619-815f-3196030832f3
# ╠═f3566289-9f6f-4de7-aa67-b4a94e78180b
# ╠═2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
# ╠═aa10cf48-c754-4037-81f2-4c4220209637
# ╠═182d55e5-f46c-444e-95d9-b898cf48969b
# ╠═68b82337-ea65-4091-872c-7f51dfd826e9
# ╠═8013f1c8-2250-41bc-b78a-6c0f944ce5ec
# ╠═312576c0-ff06-41a4-b2d8-891ded62eef7
# ╠═73b4b255-42a3-44fe-820b-768e4feec605
# ╠═6bce133b-07af-48cf-a465-9f546c0bc839
# ╠═0cb17879-626c-4a1b-ad34-912c41862ba1
# ╠═ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
# ╠═60c65c46-3d47-4eba-aee6-66eb9268b08f
# ╠═e0421caa-e416-414e-a662-49b856529e61
# ╠═0610017c-5571-420d-8605-568c34e2e972
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
