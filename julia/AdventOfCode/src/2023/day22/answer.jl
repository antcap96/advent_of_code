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
	map(split(data, '\n')) do line
		start, stop = split(line, '~')
		start_ = parse.(Int, split(start, ','))
		stop_ = parse.(Int, split(stop, ','))
		CartesianIndex(start_...):CartesianIndex(stop_...)
	end
end

# ╔═╡ 1be626f9-74fb-450b-a28b-2c61e522563f
function dropz(idx)
	CartesianIndex(Tuple(idx)[1:2])
end

# ╔═╡ 2bfe630c-6030-4187-90ab-6cde3c7493c3
function drop_if_possible!(cubes, i, floor_)
	cube = cubes[i]
	base = dropz(first(cube)):dropz(last(cube))
	z_start = maximum(floor_[base])
	z_end = first(cube)[3] - 1 

	movement = CartesianIndex(Tuple(first(base))..., z_start):CartesianIndex(Tuple(last(base))..., z_end)

	#println("dropping $i the volume $movement")
	
	intersections = map(cubes[1:end .!= i]) do cube
		isempty(cube∩movement)
	end
	if all(intersections)
		cubes[i] = cube .- CartesianIndex(0,0,size(movement, 3))
		floor_[base] .= z_start + size(cube,3)
		true
	else
		false
	end

end

# ╔═╡ 8b27156d-8d41-4c25-97b8-1d333f76d295
function drop_cubes(cubes)
	start = minimum(first.(cubes))
	
	cubes = map(cubes) do cube
		cube .+ CartesianIndex(1-start[1], 1-start[2], 0)
	end
	floor_ = ones(Int, Tuple(maximum(last.(cubes)))[1:2])

	dropped = zeros(Bool, length(cubes))
	while !all(dropped)
		for i in 1:length(cubes)
			if dropped[i]
				continue
			end
			state = drop_if_possible!(cubes, i, floor_)
			if state
				dropped[i] = true
				break
			end
		end
	end
	cubes
end

# ╔═╡ 6b582f4e-32f6-4510-a23b-2fbe3152ab4d
function answer1(input)
	cubes = sort(copy(input), by=x->first(x)[3])
	cubes = drop_cubes(cubes)
	
	suporting_cubes = map(cubes) do cube
		below = CartesianIndex(first(cube)[1], first(cube)[2], first(cube)[3]-1):		CartesianIndex(last(cube)[1], last(cube)[2], first(cube)[3]-1)
		sum(cubes) do other
			!isempty(other ∩ below)
		end
	end
	sum(cubes) do cube
		above = CartesianIndex(first(cube)[1], first(cube)[2], last(cube)[3]+1):		CartesianIndex(last(cube)[1], last(cube)[2], last(cube)[3]+1)
		sum(cubes[suporting_cubes.<2]) do other
			!isempty(other ∩ above)
		end .== 0
	end
end

# ╔═╡ 2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
function answer2(input)
	cubes = sort(copy(input), by=x->first(x)[3])
	sum(1:length(cubes)) do i
		sum(
			drop_cubes(copy(cubes))[1:end .!= i] .!= drop_cubes(cubes[1:end .!= i])
		)
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

# ╔═╡ 312576c0-ff06-41a4-b2d8-891ded62eef7
test_input_1 = "1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9"

# ╔═╡ ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
@test answer1(test_input_1 |> parse_input) == 5

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
# ╠═1be626f9-74fb-450b-a28b-2c61e522563f
# ╠═2bfe630c-6030-4187-90ab-6cde3c7493c3
# ╠═8b27156d-8d41-4c25-97b8-1d333f76d295
# ╠═6b582f4e-32f6-4510-a23b-2fbe3152ab4d
# ╠═2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
# ╠═aa10cf48-c754-4037-81f2-4c4220209637
# ╠═182d55e5-f46c-444e-95d9-b898cf48969b
# ╠═68b82337-ea65-4091-872c-7f51dfd826e9
# ╠═312576c0-ff06-41a4-b2d8-891ded62eef7
# ╠═ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
