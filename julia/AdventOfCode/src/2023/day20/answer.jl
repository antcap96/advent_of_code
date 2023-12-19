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

# ╔═╡ 9cf00a49-6003-47b0-a278-a7dd97ceec9b
abstract type AbstractModule end

# ╔═╡ 3d9de54c-6312-4472-8e00-8f01bad5905e
begin
    mutable struct BroadCasterModule <: AbstractModule
        name::String
        to::Vector{String}
    end
    BroadCasterModule(to) = BroadCasterModule("broadcaster", to)
end

# ╔═╡ 66fb338d-7e6d-45f5-9c38-3f4e4151227a
begin
    mutable struct FlipFlopModule <: AbstractModule
        name::String
        to::Vector{String}
        state::Bool
    end
    FlipFlopModule(name, to) = FlipFlopModule(name, to, false)
end

# ╔═╡ 8f059108-0c00-478d-ba0f-7bacde37f75d
begin
    mutable struct ConjunctionModule <: AbstractModule
        name::String
        to::Vector{String}
        state::Dict{String,Bool}
    end
    ConjunctionModule(name, to) = ConjunctionModule(name, to, Dict())
end

# ╔═╡ 1fc6767a-4464-447a-9f0f-c9c1a9d18f47
function update_conjuntion_modules(modules)
    for (name, mod) in modules
        for to in mod.to
            if typeof(modules[to]) == ConjunctionModule
                modules[to].state[name] = false
            end
        end
    end
    modules
end

# ╔═╡ fdf7c0b3-0fc2-47ad-ba5d-bcd1a954388d
function add_terminal_modules(modules)
    for (name, mod) in modules
        for to in mod.to
            if !haskey(modules, to)
                modules[to] = BroadCasterModule(to, [])
            end
        end
    end
    modules
end

# ╔═╡ 83629869-c3af-4d78-97a1-1bcbc6941395
function parse_input(data)
    modules = map(split(data, '\n')) do line
        name, tos = split(line, " -> ")
        to = split(tos, ", ")

        if name == "broadcaster"
            name => BroadCasterModule(to)
        elseif name[1] == '%'
            name[2:end] => FlipFlopModule(name[2:end], to)
        else
            name[2:end] => ConjunctionModule(name[2:end], to)
        end
    end |> Dict
    add_terminal_modules(modules)
    update_conjuntion_modules(modules)
end

# ╔═╡ 67e3b352-0fc4-4ebf-b1c7-eb7bf315fd84
function signal!(modules, observe)
    observed = Set{String}()
    counts = Dict(false => 0, true => 0)
    queue = Deque{Tuple{String,Bool,String}}()

    push!(queue, ("broadcaster", false, ""))

    while !isempty(queue)
        name, signal, from = popfirst!(queue)

        mod = modules[name]
        counts[signal] += 1

        if typeof(mod) == BroadCasterModule
            for to in mod.to
                push!(queue, (to, signal, name))
            end
        elseif typeof(mod) == FlipFlopModule
            if !signal
                mod.state = !mod.state
                for to in mod.to
                    push!(queue, (to, mod.state, name))
                end
            end

        elseif typeof(mod) == ConjunctionModule
            mod.state[from] = signal
            output = !all(values(mod.state))

            if !output && mod.name in observe
                push!(observed, mod.name)
            end
            for to in mod.to
                push!(queue, (to, output, name))
            end
        else
            error("unknown $mod")
        end
    end
    counts, observed
end

# ╔═╡ 6b582f4e-32f6-4510-a23b-2fbe3152ab4d
function answer1(input)
    modules = deepcopy(input)
    counts = Dict(false => 0, true => 0)

    for i in 1:1000
        c, _ = signal!(modules, ())
        for b in [false, true]
            counts[b] += c[b]
        end
    end

    prod(values(counts))
end

# ╔═╡ 2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
function answer2(input)
    modules = deepcopy(input)

    # In my input at least, rx was a ConjunctionModule with 4 ConjunctionModules as input that each had a single ConjuntionModule as input.
    # When all inputs for the 4 ConjunctionModules are high signal, then rx will output the high signal
    to_observe = tuple([
        first(keys(m.state))
        for (_, m) in modules
        if typeof(m) == ConjunctionModule
        &&
        length(m.state) == 1
    ]...)
    repeat_cycle = Dict(zip(to_observe, Iterators.cycle(0)))

    modules = copy(input)
    counts = Dict(false => 0, true => 0)

    for i in 1:10000
        _, observed = signal!(modules, to_observe)
        for o in observed
            if repeat_cycle[o] == 0
                repeat_cycle[o] = i
            end
        end
        if all(values(repeat_cycle) .!= 0)
            break
        end
    end

    lcm(values(repeat_cycle)...)
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
test_input_1 = "broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a"

# ╔═╡ ef30cb55-ade7-4448-a88a-f0ea6fe96794
test_input_2 = "broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output"

# ╔═╡ ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
@test answer1(test_input_1 |> parse_input) == 32000000

# ╔═╡ 4f8e1882-8ddf-495e-9555-c32d287ca6ae
@test answer1(test_input_2 |> parse_input) == 11687500

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
# ╠═9cf00a49-6003-47b0-a278-a7dd97ceec9b
# ╠═3d9de54c-6312-4472-8e00-8f01bad5905e
# ╠═66fb338d-7e6d-45f5-9c38-3f4e4151227a
# ╠═8f059108-0c00-478d-ba0f-7bacde37f75d
# ╠═83629869-c3af-4d78-97a1-1bcbc6941395
# ╠═1fc6767a-4464-447a-9f0f-c9c1a9d18f47
# ╠═fdf7c0b3-0fc2-47ad-ba5d-bcd1a954388d
# ╠═67e3b352-0fc4-4ebf-b1c7-eb7bf315fd84
# ╠═6b582f4e-32f6-4510-a23b-2fbe3152ab4d
# ╠═2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
# ╠═aa10cf48-c754-4037-81f2-4c4220209637
# ╠═182d55e5-f46c-444e-95d9-b898cf48969b
# ╠═68b82337-ea65-4091-872c-7f51dfd826e9
# ╠═312576c0-ff06-41a4-b2d8-891ded62eef7
# ╠═ef30cb55-ade7-4448-a88a-f0ea6fe96794
# ╠═ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
# ╠═4f8e1882-8ddf-495e-9555-c32d287ca6ae
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
