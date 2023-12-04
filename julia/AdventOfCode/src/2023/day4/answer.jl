#= Data parsing =#

function load_data()
    readlines(@__DIR__() * "/input.txt")
end

function parse_input(data)
    data = filter(data) do line
        !isempty(line)
    end

    map(data) do line
        card, numbers = split(line, ':')
        id = parse(Int, split(card)[2])
        numbers, winning_numbers = split(numbers, '|')
        numbers = parse.(Int, split(numbers))
        winning_numbers = parse.(Int, split(winning_numbers))
        ScratchCard(id, numbers, winning_numbers)
    end
end

#= Shared =#

struct ScratchCard
    id::Int
    numbers::Vector{Int}
    winning_numbers::Vector{Int}
end

function winning_count_by_card(input)
    map(input) do card
        sum(n in card.winning_numbers for n in card.numbers)
    end
end

#= Answer1 =#

function answer1(input)
    winning_count = winning_count_by_card(input)

    sum(winning_count) do count
        if count > 0
            2^(count - 1)
        else
            0
        end
    end
end

#= Answer2 =#

function answer2(input)
    winning_count = winning_count_by_card(input)

    counts = ones(Int, length(input))
    for (i, winnings) in pairs(winning_count)
        if winnings == 0
            continue
        end
        counts[i+1:i+winnings] .+= counts[i]
    end

    sum(counts)
end

#= Print answer =#

function answer()
    data = load_data()

    input = parse_input(data)

    ans1 = answer1(input)
    ans2 = answer2(input)

    println("Answer 1 is: $ans1")
    println("Answer 2 is: $ans2")
end

answer()

#= Tests =#

using Test

split_newline = s -> split(s, '\n')
\
test_input_1 = "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
" |> split_newline
test_input_2 = "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
" |> split_newline

@test answer1(test_input_1 |> parse_input) == 13

@test answer2(test_input_2 |> parse_input) == 30
