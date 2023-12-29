### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 804dc592-cc75-49ca-91c1-ceb67d765c56
begin
    using Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
end

# ╔═╡ 68b82337-ea65-4091-872c-7f51dfd826e9
using Test

# ╔═╡ 42d0b1b6-981a-11ee-0a01-6f7d5b828f97
function load_data()
    readchomp(@__DIR__() * "/input.txt")
end

# ╔═╡ 37725a67-02b1-45d6-b4b9-3e110aa03f8b
function parse_input(data)
    lines = split(data, '\n')

    matrix = vcat(permutedims.(collect.(lines))...)

    matrix .== '#'
end

# ╔═╡ c8ab9b7c-98d1-4e89-b9da-5ac181c6e5fb
rev_cumsum(arr) = (cumsum(arr |> Iterators.reverse) |> reverse!)

# ╔═╡ e8ebceb9-73bd-43b0-ac6f-3623722f63af
function answer_(input, expansion_factor)
    sum(1:2) do axis
        n_galaxies = dropdims(sum(input; dims=axis); dims=axis)
        times_traveled = (cumsum(n_galaxies) .- n_galaxies) .* rev_cumsum(n_galaxies)
        weights = ((expansion_factor - 1) .* (n_galaxies .== 0) .+ 1)
        weights' * times_traveled
    end
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
#...#....."

# ╔═╡ ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
@test answer1(test_input_1 |> parse_input) == 374

# ╔═╡ 68b7b111-21c6-4960-83a0-47045ebecde8
@test answer_(test_input_1 |> parse_input, 10) == 1030

# ╔═╡ 890ca4e4-e62f-4fc1-93a7-ea4aca2e6b11
@test answer_(test_input_1 |> parse_input, 100) == 8410

# ╔═╡ Cell order:
# ╠═804dc592-cc75-49ca-91c1-ceb67d765c56
# ╠═42d0b1b6-981a-11ee-0a01-6f7d5b828f97
# ╠═37725a67-02b1-45d6-b4b9-3e110aa03f8b
# ╠═c8ab9b7c-98d1-4e89-b9da-5ac181c6e5fb
# ╠═e8ebceb9-73bd-43b0-ac6f-3623722f63af
# ╠═a9d50b91-a713-4619-815f-3196030832f3
# ╠═2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
# ╠═aa10cf48-c754-4037-81f2-4c4220209637
# ╠═182d55e5-f46c-444e-95d9-b898cf48969b
# ╠═68b82337-ea65-4091-872c-7f51dfd826e9
# ╠═312576c0-ff06-41a4-b2d8-891ded62eef7
# ╠═ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
# ╠═68b7b111-21c6-4960-83a0-47045ebecde8
# ╠═890ca4e4-e62f-4fc1-93a7-ea4aca2e6b11
