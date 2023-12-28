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

# ╔═╡ d020b9b0-c456-49ba-b2ba-27e877e2513a
using Test

# ╔═╡ 8653086b-1ef1-4b41-970c-b1e3e00c1d22
function load_data()
    readchomp(@__DIR__() * "/input.txt")
end

# ╔═╡ f6099dd5-49bf-4cd2-9e29-58c90d9a9e48
struct ScratchCard
    id::Int
    numbers::Vector{Int}
    winning_numbers::Vector{Int}
end

# ╔═╡ 55eb8d67-a81c-4799-9f11-9e9730941bd1
function parse_input(data)
    lines = split(data, '\n')
    map(lines) do line
        card, numbers = split(line, ':')
        id = parse(Int, split(card)[2])
        numbers, winning_numbers = split(numbers, '|')
        numbers = parse.(Int, split(numbers))
        winning_numbers = parse.(Int, split(winning_numbers))
        ScratchCard(id, numbers, winning_numbers)
    end
end

# ╔═╡ 9b64f300-9899-4294-b6b1-047ee7731510
function winning_count(card)
    sum(n in card.winning_numbers for n in card.numbers)
end

# ╔═╡ 1e1456fe-618c-4e60-838d-744d11c9d2b9
function answer1(input)
    winning_counts = winning_count.(input)

    sum(winning_counts) do count
        if count > 0
            2^(count - 1)
        else
            0
        end
    end
end

# ╔═╡ 3243f208-c43e-4f31-b369-659ee23a82d4
function answer2(input)
    winning_counts = winning_count.(input)

    counts = ones(Int, length(input))
    for (i, winnings) in enumerate(winning_counts)
        if winnings == 0
            continue
        end
        counts[i+1:i+winnings] .+= counts[i]
    end

    sum(counts)
end

# ╔═╡ 8a2f22b8-e5ab-4164-b22b-9d3c72fffbbf
function answer()
    data = load_data()

    input = parse_input(data)

    ans1 = answer1(input)
    ans2 = answer2(input)

    println("Answer 1 is: $ans1")
    println("Answer 2 is: $ans2")
end

# ╔═╡ df56e7f8-a180-4ab2-bf2c-b8a4bf3402c7
answer()

# ╔═╡ 4e1e9a28-d81a-40d0-bc08-ea558758f596
test_input_1 = "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"

# ╔═╡ f75a6d4c-f0a9-46e4-b902-7368579414c8
test_input_2 = "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"

# ╔═╡ 6c930d70-024e-4b33-bd11-523ea7aa386a
@test answer1(test_input_1 |> parse_input) == 13

# ╔═╡ 989926ce-c763-4d26-b7ad-ba0b21931c81
@test answer2(test_input_2 |> parse_input) == 30

# ╔═╡ Cell order:
# ╠═20e4b8d2-7a85-4816-8830-e53a12a809e4
# ╠═8653086b-1ef1-4b41-970c-b1e3e00c1d22
# ╠═55eb8d67-a81c-4799-9f11-9e9730941bd1
# ╠═f6099dd5-49bf-4cd2-9e29-58c90d9a9e48
# ╠═9b64f300-9899-4294-b6b1-047ee7731510
# ╠═1e1456fe-618c-4e60-838d-744d11c9d2b9
# ╠═3243f208-c43e-4f31-b369-659ee23a82d4
# ╠═8a2f22b8-e5ab-4164-b22b-9d3c72fffbbf
# ╠═df56e7f8-a180-4ab2-bf2c-b8a4bf3402c7
# ╠═d020b9b0-c456-49ba-b2ba-27e877e2513a
# ╠═4e1e9a28-d81a-40d0-bc08-ea558758f596
# ╠═f75a6d4c-f0a9-46e4-b902-7368579414c8
# ╠═6c930d70-024e-4b33-bd11-523ea7aa386a
# ╠═989926ce-c763-4d26-b7ad-ba0b21931c81
