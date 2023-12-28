### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 16547ccc-6c03-4e8a-bbe6-39badf853595
begin
    using Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
end

# ╔═╡ c89e746c-d1e8-4f93-9e87-3ec9e2301230
using Test

# ╔═╡ 0dbb4ae7-a134-4c27-9ade-ba56485e9924
function load_data()
    readchomp(@__DIR__() * "/input.txt")
end

# ╔═╡ 9f7c9bb4-6f95-4fd8-a831-b52e1e067d0c
function parse_input(data)
    map(split(data, '\n')) do line
        split(line)[2:end]
    end
end

# ╔═╡ 82b683ba-4dd8-425e-9467-75e9f481d823
function quadratic_formula(a, b, c)
    Δ = b^2 - 4a * c
    ans1 = (-b + √Δ) / 2a
    ans2 = (-b - √Δ) / 2a
    min(ans1, ans2), max(ans1, ans2)
end

# ╔═╡ ee3b17fa-41c5-4933-863f-0253a0ee4001
function winning_range(time, distance)
    # held * (time - held) > distance
    # held * time - held^2 - distance > 0
    min, max = quadratic_formula(-1, time, -distance)

    min = floor(Int, min) + 1
    max = ceil(Int, max) - 1
    min:max
end

# ╔═╡ f4c448c0-470d-4fe6-bebb-5d651613fd46
function answer1(input)
    a = map(zip(input...)) do pair
        parse.(Int, pair)
    end
    prod(a) do (time, distance)
        winning_range(time, distance) |> length
    end
end

# ╔═╡ 6a3730f6-a9cd-44f5-8a76-0d2d9f853020
function answer2(input)
    (time, distance) = parse.(Int, reduce.(*, input))
    winning_range(time, distance) |> length
end

# ╔═╡ a4388c9c-e043-4701-98e2-395b6f8ed61e
function answer()
    data = load_data()

    input = parse_input(data)

    ans1 = answer1(input)
    ans2 = answer2(input)

    println("Answer 1 is: $ans1")
    println("Answer 2 is: $ans2")
end

# ╔═╡ 06c7a4cd-ca1a-4c65-86d6-44b9cc337982
answer()

# ╔═╡ 0b46975d-1b81-4814-adde-005f51092958
test_input_1 = "Time:      7  15   30
Distance:  9  40  200"

# ╔═╡ 8142fd18-b8d0-4143-93e8-46542bb34342
@test answer1(test_input_1 |> parse_input) == 288

# ╔═╡ 0d753fb9-c208-4a3e-8e72-16f2d6c8ca5f
@test answer2(test_input_1 |> parse_input) == 71503

# ╔═╡ Cell order:
# ╠═16547ccc-6c03-4e8a-bbe6-39badf853595
# ╠═0dbb4ae7-a134-4c27-9ade-ba56485e9924
# ╠═9f7c9bb4-6f95-4fd8-a831-b52e1e067d0c
# ╠═82b683ba-4dd8-425e-9467-75e9f481d823
# ╠═ee3b17fa-41c5-4933-863f-0253a0ee4001
# ╠═f4c448c0-470d-4fe6-bebb-5d651613fd46
# ╠═6a3730f6-a9cd-44f5-8a76-0d2d9f853020
# ╠═a4388c9c-e043-4701-98e2-395b6f8ed61e
# ╠═06c7a4cd-ca1a-4c65-86d6-44b9cc337982
# ╠═c89e746c-d1e8-4f93-9e87-3ec9e2301230
# ╠═0b46975d-1b81-4814-adde-005f51092958
# ╠═8142fd18-b8d0-4143-93e8-46542bb34342
# ╠═0d753fb9-c208-4a3e-8e72-16f2d6c8ca5f
