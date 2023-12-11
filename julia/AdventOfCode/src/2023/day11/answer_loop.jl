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

	matrix .== '#'
end

# ╔═╡ 094a6a3d-8c4b-4bab-9f3f-21a8208a0195
function distance(g1, g2, empty_rows, empty_cols, expansion_factor)
	cols=min(g1[1],g2[1]):max(g1[1],g2[1])
	rows=min(g1[2],g2[2]):max(g1[2],g2[2])
	total = length(rows) + length(cols) - 2 + (sum(empty_rows[rows]) + sum(empty_cols[cols])) * (expansion_factor-1)
	s1 = sum(empty_rows[rows])
	s2 = sum(empty_cols[cols])
	total
end

# ╔═╡ e8ebceb9-73bd-43b0-ac6f-3623722f63af
function answer_(input, expansion_factor)
	empty_rows = dropdims(sum(input; dims=1); dims=1) .== 0
	empty_cols = dropdims(sum(input; dims=2); dims=2) .== 0
	galaxies = findall(input)

	total = 0
	for i in eachindex(galaxies)
		for j in (i+1):length(galaxies)
			total += distance(galaxies[i], galaxies[j], empty_rows, empty_cols, expansion_factor)
		end
	end
	total
end

# ╔═╡ a9d50b91-a713-4619-815f-3196030832f3
answer1(input) = answer_(input, 2)

# ╔═╡ 2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
answer2(input) = answer_(input, 1000000)

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
test_input_1 = "...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
" |> split_newline

# ╔═╡ ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
@test answer1(test_input_1 |> parse_input) == 374

# ╔═╡ 68b7b111-21c6-4960-83a0-47045ebecde8
@test answer_(test_input_1 |> parse_input, 10) == 1030

# ╔═╡ 890ca4e4-e62f-4fc1-93a7-ea4aca2e6b11
@test answer_(test_input_1 |> parse_input, 100) == 8410

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
# ╠═094a6a3d-8c4b-4bab-9f3f-21a8208a0195
# ╠═e8ebceb9-73bd-43b0-ac6f-3623722f63af
# ╠═a9d50b91-a713-4619-815f-3196030832f3
# ╠═2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
# ╠═aa10cf48-c754-4037-81f2-4c4220209637
# ╠═182d55e5-f46c-444e-95d9-b898cf48969b
# ╠═68b82337-ea65-4091-872c-7f51dfd826e9
# ╠═8013f1c8-2250-41bc-b78a-6c0f944ce5ec
# ╠═312576c0-ff06-41a4-b2d8-891ded62eef7
# ╠═ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
# ╠═68b7b111-21c6-4960-83a0-47045ebecde8
# ╠═890ca4e4-e62f-4fc1-93a7-ea4aca2e6b11
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
