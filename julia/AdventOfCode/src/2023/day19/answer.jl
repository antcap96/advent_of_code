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
    readchomp(@__DIR__() * "/input.txt")
end

# ╔═╡ 4c711d01-0b88-4101-b7f8-9102a45a6e2e
struct Condition
	on::String
	operation::Char
	target::Int
	to::String
end

# ╔═╡ a97b660a-c4c7-43ec-8107-78d4ee084423
function Base.parse(::Type{Condition}, s::AbstractString)
	start, to = split(s, ':')
	idx = findfirst((collect(start) .== '<') .|| (collect(start) .== '>'))
	
	Condition(
		start[1:idx-1],
		start[idx],
		parse(Int, start[idx+1:end]),
		to,
	)
end

# ╔═╡ 1343eb14-6c29-4faf-9ceb-b76e45a7e468
@test parse(Condition, "a>2798:R") == Condition("a", '>', 2798, "R")

# ╔═╡ 4430304a-cd91-4f76-a9d9-24c7ca913481
struct Workflow
	conditions::Vector{Condition}
	default::String
end

# ╔═╡ 83629869-c3af-4d78-97a1-1bcbc6941395
function parse_input(data)
	workflows_, parts_ = split(data, "\n\n")

	workflows = map(split(workflows_, '\n')) do line
		name, rule_ = split(line, '{')
		rules = split(rstrip(rule_, ['}']), ',')
		
		(
			name, 
			Workflow(
				parse.(Condition, rules[1:end-1]),
				rules[end],
			),
		)
	end |> Dict
	
	parts = map(split(parts_, '\n')) do line
		map(split(strip(line, ['{','}']), ',')) do rating
			name, value = split(rating, '=')
			(name, parse(Int, value))
		end |> Dict
	end
	(workflows, parts)
end

# ╔═╡ 89eb8f22-fa07-4283-8010-43e2ae7ebdac
function evaluate(condition::Condition, part)
	if condition.operation == '>'
		if part[condition.on] > condition.target
			condition.to
		end
	elseif condition.operation == '<'
		if part[condition.on] < condition.target
			condition.to
		end
	else
		error(condition.operation)
	end
end

# ╔═╡ 44db4db5-be89-42f9-998a-931eb216fd15
function next(workflow, part)
	something(evaluate.(workflow.conditions, Ref(part))..., workflow.default)
end

# ╔═╡ f1b9daf3-7ddd-48e7-a5d0-e601f09c37af
function isaccepted(workflows, part)
	at = "in"
	while at != "A" && at != "R"
		at = next(workflows[at], part)
	end
	at == "A"
end

# ╔═╡ 6b582f4e-32f6-4510-a23b-2fbe3152ab4d
function answer1(input)
	workflows, parts = input

	sum(filter(Base.Fix1(isaccepted, workflows), parts)) do part
		sum(values(part))
	end
end

# ╔═╡ 2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
function answer2(input)
	workflows, _ = input
	valid_ranges = Dict(
		"x"=>1:4000,
		"m"=>1:4000,
		"a"=>1:4000,
		"s"=>1:4000,
	)
	state = ["in" => valid_ranges]

	while (!all([id in ["A", "R"] for (id, _) in state]))
		next_state = []
		for (id, ranges) in state
			if id in ["A", "R"]
				push!(next_state, id => ranges)
				continue
			end
			for condition in workflows[id].conditions
				range = ranges[condition.on]
				if condition.operation == '>'
					range1 = range ∩ ((condition.target+1):4000)
					ranges[condition.on] = range ∩ (1:condition.target)
				elseif condition.operation == '<'
					range1 = range ∩ (1:(condition.target-1))
					ranges[condition.on] = range ∩ ((condition.target):4000)
				end
				if !isempty(range1)
					new_ranges = copy(ranges)
					new_ranges[condition.on] = range1
					push!(next_state, condition.to => new_ranges)
				end
				if isempty(ranges[condition.on])
					break
				end
			end
			if all(.! isempty.(values(ranges)))
				push!(next_state, workflows[id].default => ranges)
			end
		end
		state = next_state
	end
	sum(
		filter(state) do s
			first(s) == "A"
		end
	) do (_,ranges)
		prod(values(ranges)) do range
			length(range)
		end
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
test_input_1 = "px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}"

# ╔═╡ ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
@test answer1(test_input_1 |> parse_input) == 19114

# ╔═╡ 42e107d0-1d63-4b6b-b575-de42c85a23ba
@test answer2(test_input_1 |> parse_input) == 167409079868000

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
# ╠═4c711d01-0b88-4101-b7f8-9102a45a6e2e
# ╠═a97b660a-c4c7-43ec-8107-78d4ee084423
# ╠═1343eb14-6c29-4faf-9ceb-b76e45a7e468
# ╠═4430304a-cd91-4f76-a9d9-24c7ca913481
# ╠═83629869-c3af-4d78-97a1-1bcbc6941395
# ╠═89eb8f22-fa07-4283-8010-43e2ae7ebdac
# ╠═44db4db5-be89-42f9-998a-931eb216fd15
# ╠═f1b9daf3-7ddd-48e7-a5d0-e601f09c37af
# ╠═6b582f4e-32f6-4510-a23b-2fbe3152ab4d
# ╠═2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
# ╠═aa10cf48-c754-4037-81f2-4c4220209637
# ╠═182d55e5-f46c-444e-95d9-b898cf48969b
# ╠═68b82337-ea65-4091-872c-7f51dfd826e9
# ╠═312576c0-ff06-41a4-b2d8-891ded62eef7
# ╠═ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
# ╠═42e107d0-1d63-4b6b-b575-de42c85a23ba
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
