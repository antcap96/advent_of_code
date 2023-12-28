### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 20e4b8d2-7a85-4816-8830-e53a12a809e4
begin
    using Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
end

# ╔═╡ 89d92432-ba50-4570-84fa-919b48fbca97
using Test

# ╔═╡ 2ed3be38-a948-4035-9649-35962cdbd4b7
function load_data()
    readchomp(@__DIR__() * "/input.txt")
end

# ╔═╡ 4c57622e-bfef-4be5-b645-044f609c7e5e
function parse_input(data)
    lines = split(data, '\n')
    vcat(permutedims.(collect.(lines))...)
end

# ╔═╡ 625946cf-1e8b-41d7-b12d-f9fe1e763221
begin
    struct FoundNumber
        range::CartesianIndices{2,Tuple{UnitRange{Int},UnitRange{Int}}}
        value::Int
    end

    function FoundNumber(pos::Tuple{Int,Int}, str::Union{AbstractString,Char})
        start = CartesianIndex(pos[1], pos[2] - length(str))
        stop = CartesianIndex(pos[1], pos[2] - 1)
        FoundNumber(
            start:stop,
            parse(Int, str),
        )
    end
end

# ╔═╡ 19bc8b40-0957-4864-aa49-b2d1c998c9b5
function get_numbers(input::AbstractMatrix{Char})
    numbers = FoundNumber[]

    for y in axes(input, 1)
        in_number = false
        number = ""
        for x in axes(input, 2)
            ch = input[y, x]
            if isdigit(ch)
                if in_number
                    number *= ch
                else
                    in_number = true
                    number = string(ch)
                end
            else
                if in_number
                    in_number = false
                    push!(numbers, FoundNumber((y, x), number))
                end
            end
        end
        if in_number
            in_number = false
            push!(numbers, FoundNumber((y, size(input, 2) + 1), number))
        end
    end

    numbers
end

# ╔═╡ 5100938b-1f59-40c6-8179-efc5354ea160
function expand(idxs::CartesianIndices)
    start = first(idxs) - CartesianIndex(1, 1)
    stop = last(idxs) + CartesianIndex(1, 1)

    start:stop
end

# ╔═╡ b5ad02c3-8c1b-4a8e-8826-82a5ce837136
function answer1(input)
    symbols = @. !(isdigit(input) || input == '.')
    numbers = get_numbers(input)

    valid_indices = eachindex(IndexCartesian(), input)
    valid_numbers = filter(numbers) do number
        neighbors = intersect(expand(number.range), valid_indices)
        any(symbols[neighbors])
    end

    sum(valid_numbers) do number
        number.value
    end
end

# ╔═╡ d7e23637-2fa1-480d-b426-eebb9a25c1f7
function answer2(input)
    gears = findall(input .== '*')

    numbers = get_numbers(input)

    sum(gears) do gear
        neighbors = filter(numbers) do number
            gear in expand(number.range)
        end
        if length(neighbors) != 2
            return 0
        end
        neighbors[1].value * neighbors[2].value
    end
end

# ╔═╡ 7e2b6139-3cfa-4b1b-ab33-039e79271396
function answer()
    data = load_data()

    input = parse_input(data)

    ans1 = answer1(input)
    ans2 = answer2(input)

    println("Answer 1 is: $ans1")
    println("Answer 2 is: $ans2")
end

# ╔═╡ 4e11e8ff-384f-41d3-97da-6ec7e7b78152
answer()

# ╔═╡ b76bc938-0ba7-4bf2-a56f-2d786a930934
test_input_1 = raw"467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."

# ╔═╡ 5a7511f4-ccc0-4b4d-9bc6-49318b008d57
@test answer1(test_input_1 |> parse_input) == 4361

# ╔═╡ e83cb1ad-3834-4e8f-936f-ffbf92dcbb2f
@test answer2(test_input_1 |> parse_input) == 467835

# ╔═╡ Cell order:
# ╠═20e4b8d2-7a85-4816-8830-e53a12a809e4
# ╠═2ed3be38-a948-4035-9649-35962cdbd4b7
# ╠═4c57622e-bfef-4be5-b645-044f609c7e5e
# ╠═625946cf-1e8b-41d7-b12d-f9fe1e763221
# ╠═19bc8b40-0957-4864-aa49-b2d1c998c9b5
# ╠═5100938b-1f59-40c6-8179-efc5354ea160
# ╠═b5ad02c3-8c1b-4a8e-8826-82a5ce837136
# ╠═d7e23637-2fa1-480d-b426-eebb9a25c1f7
# ╠═7e2b6139-3cfa-4b1b-ab33-039e79271396
# ╠═4e11e8ff-384f-41d3-97da-6ec7e7b78152
# ╠═89d92432-ba50-4570-84fa-919b48fbca97
# ╠═b76bc938-0ba7-4bf2-a56f-2d786a930934
# ╠═5a7511f4-ccc0-4b4d-9bc6-49318b008d57
# ╠═e83cb1ad-3834-4e8f-936f-ffbf92dcbb2f
