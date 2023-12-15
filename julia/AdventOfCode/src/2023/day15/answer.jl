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
    split(data[1], ',')
end

# ╔═╡ edff60c3-66f7-440e-871f-9412eafd338a
hash(s::AbstractString) = hash(0, s)

# ╔═╡ 0a22f589-81db-4bdc-8de0-a8a6effef91a
function hash(state, s::AbstractString)
	for ch in s
		state = hash(state, ch)
	end
	state
end

# ╔═╡ a262b8fe-c6d6-4e17-becd-4641416bd5b5
function hash(state, ch::Char)
	((state + Int(ch)) * 17) % 256
end

# ╔═╡ 6b582f4e-32f6-4510-a23b-2fbe3152ab4d
function answer1(input)
	sum(input) do s
		hash(s)
	end
end

# ╔═╡ a07b93b1-e7e7-40a5-9a79-09568a6ebf03
function step!(boxes, operation)
	op = split(operation, '=')
	if length(op) == 2
		
		label, focal_length_string = op
		focal_length = parse(Int, focal_length_string)
		
		box = boxes[hash(label)+1]
		# Update the existing entry
		for i in eachindex(box)
			if box[i][1] == label
				box[i][2] = focal_length
				return
			end
		end
		# If it doesn't exit, append it to the list
		push!(box, [label, focal_length])
	else
		label = operation[1:end-1]
		# Remove the entry
		filter!(boxes[hash(label)+1]) do (other, _)
			other != label
		end
	end
end

# ╔═╡ 9c913200-50eb-4721-8744-a983d656f010
function focusing_power(boxes)
	sum(enumerate(boxes)) do (i, box)
		i * sum(enumerate(box); init=0) do (j, (_label, focus))
			j * focus
		end
	end
end

# ╔═╡ 2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
function answer2(input)
	boxes = [[] for _ in 1:256]
	for s in input
		step!(boxes, s)
	end
	focusing_power(boxes)
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
test_input_1 = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
" |> split_newline

# ╔═╡ ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
@test answer1(test_input_1 |> parse_input) == 1320

# ╔═╡ 4681250a-cf09-42cc-b5dc-3777accb13c8
@test answer2(test_input_1 |> parse_input) == 145

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
# ╠═edff60c3-66f7-440e-871f-9412eafd338a
# ╠═0a22f589-81db-4bdc-8de0-a8a6effef91a
# ╠═a262b8fe-c6d6-4e17-becd-4641416bd5b5
# ╠═6b582f4e-32f6-4510-a23b-2fbe3152ab4d
# ╠═a07b93b1-e7e7-40a5-9a79-09568a6ebf03
# ╠═9c913200-50eb-4721-8744-a983d656f010
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
