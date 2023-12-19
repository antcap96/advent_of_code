### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

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

# ╔═╡ 4430304a-cd91-4f76-a9d9-24c7ca913481
struct Workflow
    conditions::Vector{Condition}
    default::String
end

# ╔═╡ 8e531427-4b75-4325-81ee-6224d9a2d045
function Base.parse(::Type{Workflow}, s::AbstractString)
    rules = split(s, ',')
    Workflow(
        parse.(Condition, rules[1:end-1]),
        rules[end],
    )
end

# ╔═╡ 1343eb14-6c29-4faf-9ceb-b76e45a7e468
@test parse(Condition, "a>2798:R") == Condition("a", '>', 2798, "R")

# ╔═╡ 83629869-c3af-4d78-97a1-1bcbc6941395
function parse_input(data)
    workflows_, parts_ = split(data, "\n\n")

    workflows = map(split(workflows_, '\n')) do line
        name, rule_ = split(line, '{')

        (
            name,
            parse(Workflow, rstrip(rule_, '}')),
        )
    end |> Dict

    parts = map(split(parts_, '\n')) do line
        ratings = split(strip(line, ['{', '}']), ',')
        map(ratings) do rating
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

    accepted_parts = filter(parts) do part
        isaccepted(workflows, part)
    end
    sum(accepted_parts) do part
        sum(values(part))
    end
end

# ╔═╡ d61303a0-1252-4a49-ab30-6a1ca9834009
function possibilities(ranges::Dict{String,UnitRange{Int}})
    prod(values(ranges)) do range
        length(range)
    end
end

# ╔═╡ 8d2e5eac-a97a-4dcb-810e-b52f8c18c991
function apply_condition(condition::Condition, state::Dict{String,UnitRange{Int}})
    range = state[condition.on]
    range_passing, range_failing = if condition.operation == '>'
        (
            range ∩ ((condition.target+1):4000),
            range ∩ (1:condition.target),
        )
    elseif condition.operation == '<'
        (
            range ∩ (1:(condition.target-1)),
            range ∩ ((condition.target):4000),
        )
    else
        error(condition.operation)
    end

    a = if !isempty(range_passing)
        new_state = copy(state)
        new_state[condition.on] = range_passing
        condition.to => new_state
    end
    b = if !isempty(range_failing)
        new_state = copy(state)
        new_state[condition.on] = range_failing
        new_state
    end
    (a, b)
end

# ╔═╡ 2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
function answer2(input)
    workflows, _ = input
    valid_ranges = Dict(
        "x" => 1:4000,
        "m" => 1:4000,
        "a" => 1:4000,
        "s" => 1:4000,
    )
    state = ["in" => valid_ranges]

    while (!all([id in ["A", "R"] for (id, _) in state]))
        next_state = Pair{String,Dict{String,UnitRange{Int64}}}[]
        for (id, ranges) in state
            if id in ["A", "R"]
                push!(next_state, id => ranges)
                continue
            end
            for condition in workflows[id].conditions
                passing, ranges = apply_condition(condition, ranges)

                if !isnothing(passing)
                    push!(next_state, passing)
                end
                if isnothing(ranges)
                    break
                end
            end
            if !isempty(ranges)
                push!(next_state, workflows[id].default => ranges)
            end
        end
        state = next_state
    end

    sum([
        possibilities(ranges)
        for (id, ranges) in state
        if id == "A"
    ])
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
# ╠═4c711d01-0b88-4101-b7f8-9102a45a6e2e
# ╠═a97b660a-c4c7-43ec-8107-78d4ee084423
# ╠═1343eb14-6c29-4faf-9ceb-b76e45a7e468
# ╠═4430304a-cd91-4f76-a9d9-24c7ca913481
# ╠═8e531427-4b75-4325-81ee-6224d9a2d045
# ╠═83629869-c3af-4d78-97a1-1bcbc6941395
# ╠═89eb8f22-fa07-4283-8010-43e2ae7ebdac
# ╠═44db4db5-be89-42f9-998a-931eb216fd15
# ╠═f1b9daf3-7ddd-48e7-a5d0-e601f09c37af
# ╠═6b582f4e-32f6-4510-a23b-2fbe3152ab4d
# ╠═d61303a0-1252-4a49-ab30-6a1ca9834009
# ╠═8d2e5eac-a97a-4dcb-810e-b52f8c18c991
# ╠═2fafbde3-65ac-48e7-b8ac-ce6ef73bb42a
# ╠═aa10cf48-c754-4037-81f2-4c4220209637
# ╠═182d55e5-f46c-444e-95d9-b898cf48969b
# ╠═68b82337-ea65-4091-872c-7f51dfd826e9
# ╠═312576c0-ff06-41a4-b2d8-891ded62eef7
# ╠═ef19a91f-4eee-4c4e-bc4a-dd8d38f299b1
# ╠═42e107d0-1d63-4b6b-b575-de42c85a23ba
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
