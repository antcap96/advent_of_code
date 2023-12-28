### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 751b4653-a9ae-4e0f-82b4-be377d9654c4
begin
    using Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
end

# ╔═╡ 7e56a8a6-6d4a-4dc0-ab84-0f610653c70a
using Test

# ╔═╡ e71eed75-950e-4bb1-abfd-d0486ef5e048
function load_data()
    readchomp(@__DIR__() * "/input.txt")
end

# ╔═╡ eb1d334c-4ef6-41dc-afc5-19a62327a049
function parse_input(data)
    map(split(data, '\n')) do line
        parse.(Int, split(line))
    end
end

# ╔═╡ e05dc316-d64c-4141-9864-6bfe830899d8
function deltas(arr)
    arr[2:end] .- arr[1:end-1]
end

# ╔═╡ a63eb42b-5394-4986-b247-d661511e30bf
function next(arr)
    if all(arr .== 0)
        0
    else
        arr[end] + next(deltas(arr))
    end
end

# ╔═╡ e9542dd6-a2ed-456e-9aa6-e75ca9fb6381
function answer1(input)
    sum(next, input)
end

# ╔═╡ cf9cc488-08d3-449e-953f-b3af1b2291bf
function prev(arr)
    if all(arr .== 0)
        0
    else
        arr[1] - prev(deltas(arr))
    end
end

# ╔═╡ c419093a-461b-4d23-bac9-0764db01be64
function answer2(input)
    sum(prev, input)
end

# ╔═╡ 9a837f71-3348-41ba-904f-81c7043b3091
function answer()
    data = load_data()

    input = parse_input(data)

    ans1 = answer1(input)
    ans2 = answer2(input)

    println("Answer 1 is: $ans1")
    println("Answer 2 is: $ans2")
end

# ╔═╡ e773d647-b89f-4e9e-992e-648d571899c9
answer()

# ╔═╡ 345a8e12-4fba-4a13-89b2-82091b3c6b2a
test_input_1 = "0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45"

# ╔═╡ 376cd75c-8ef1-423f-a9f6-a16ca6343483
@test answer1(test_input_1 |> parse_input) == 114

# ╔═╡ b0df6a80-ddbd-4499-bc1c-03c5e100fa78
@test answer2(test_input_1 |> parse_input) == 2

# ╔═╡ Cell order:
# ╠═751b4653-a9ae-4e0f-82b4-be377d9654c4
# ╠═e71eed75-950e-4bb1-abfd-d0486ef5e048
# ╠═eb1d334c-4ef6-41dc-afc5-19a62327a049
# ╠═e05dc316-d64c-4141-9864-6bfe830899d8
# ╠═a63eb42b-5394-4986-b247-d661511e30bf
# ╠═e9542dd6-a2ed-456e-9aa6-e75ca9fb6381
# ╠═cf9cc488-08d3-449e-953f-b3af1b2291bf
# ╠═c419093a-461b-4d23-bac9-0764db01be64
# ╠═9a837f71-3348-41ba-904f-81c7043b3091
# ╠═e773d647-b89f-4e9e-992e-648d571899c9
# ╠═7e56a8a6-6d4a-4dc0-ab84-0f610653c70a
# ╠═345a8e12-4fba-4a13-89b2-82091b3c6b2a
# ╠═376cd75c-8ef1-423f-a9f6-a16ca6343483
# ╠═b0df6a80-ddbd-4499-bc1c-03c5e100fa78
