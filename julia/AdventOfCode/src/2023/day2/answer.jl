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

# ╔═╡ 45d3c580-6a1c-4a78-ac08-eda564b12e6c
using DataStructures

# ╔═╡ 1dbfcec9-4a5e-4216-bc98-a31d2ea934d6
using Test

# ╔═╡ 8b3a76b0-68b8-46aa-ae1f-6025c5c49976
function load_data()
    readchomp(@__DIR__() * "/input.txt")
end

# ╔═╡ d4679951-240a-4a7e-b471-01b3268c4fe2
function parse_line(line)
    game, results = split(line, ':')
    game_id = parse(Int, split(game)[2])

    results = split(results, ';')
    revealed = map(results) do revealed
        each = split(revealed, ',')
        DefaultDict(0,
            map(each) do group
                count, color = split(group)
                (color, parse(Int, count))
            end
        )
    end

    (game_id, revealed)
end

# ╔═╡ ab3c3b6b-facb-4c96-98ca-343abd903d95
function parse_input(data)
    map(parse_line, split(data, '\n'))
end

# ╔═╡ 3b5034b9-6c9a-4061-8a25-d4b169da9ce0
function is_possible(revealed, maxes::AbstractVector{Pair{S,I}}) where {
    S<:AbstractString,
    I<:Integer
}
    for reveal in revealed
        for (color, max) in maxes
            if reveal[color] > max
                return false
            end
        end
    end
    true
end

# ╔═╡ 8ca9cf20-96da-4733-9cc9-0b4413d3bd09
function answer1(input)
    maxes = ["red" => 12, "green" => 13, "blue" => 14]

    possible_games = filter(input) do (_, revealed)
        is_possible(revealed, maxes)
    end
    sum([game_id for (game_id, _) in possible_games])
end

# ╔═╡ a38ce1b6-c321-4bb9-9218-e30a00c47dae
function answer2(input)
    sum(input) do (_, revealed)
        prod(["red", "green", "blue"]) do color
            maximum(revealed) do reveal
                reveal[color]
            end
        end
    end
end

# ╔═╡ 4ee076f1-cba9-4e9f-b008-decc92da0d9f
function answer()
    data = load_data()

    input = parse_input(data)

    ans1 = answer1(input)
    ans2 = answer2(input)

    println("Answer 1 is: $ans1")
    println("Answer 2 is: $ans2")
end

# ╔═╡ c7282c86-3507-4277-816e-87836f1999d5
answer()

# ╔═╡ 1f06d884-f975-409a-8c01-d21e908f2cf3
test_input_1 = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"

# ╔═╡ 82581b8e-db94-4876-8f39-6e84e024ddca
@test answer1(test_input_1 |> parse_input) == 8

# ╔═╡ e93cca71-62bf-48d2-9881-67fcecd3c042
test_input_1 |> parse_input

# ╔═╡ 96d75676-d636-4542-a975-9e3fe737e510
@test answer2(test_input_1 |> parse_input) == 2286

# ╔═╡ Cell order:
# ╠═20e4b8d2-7a85-4816-8830-e53a12a809e4
# ╠═45d3c580-6a1c-4a78-ac08-eda564b12e6c
# ╠═8b3a76b0-68b8-46aa-ae1f-6025c5c49976
# ╠═ab3c3b6b-facb-4c96-98ca-343abd903d95
# ╠═d4679951-240a-4a7e-b471-01b3268c4fe2
# ╠═8ca9cf20-96da-4733-9cc9-0b4413d3bd09
# ╠═3b5034b9-6c9a-4061-8a25-d4b169da9ce0
# ╠═a38ce1b6-c321-4bb9-9218-e30a00c47dae
# ╠═4ee076f1-cba9-4e9f-b008-decc92da0d9f
# ╠═c7282c86-3507-4277-816e-87836f1999d5
# ╠═1dbfcec9-4a5e-4216-bc98-a31d2ea934d6
# ╠═1f06d884-f975-409a-8c01-d21e908f2cf3
# ╠═82581b8e-db94-4876-8f39-6e84e024ddca
# ╠═e93cca71-62bf-48d2-9881-67fcecd3c042
# ╠═96d75676-d636-4542-a975-9e3fe737e510
