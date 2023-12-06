#= Data parsing =#

function load_data()
    readlines(@__DIR__() * "/input.txt")
end

function parse_input(data)
    map(filter(!isempty, data)) do line
        split(line)[2:end]
    end
end

#= Shared =#

function quadratic_formula(a, b, c)
    Δ = b^2 - 4a * c
    ans1 = (-b + √Δ) / 2a
    ans2 = (-b - √Δ) / 2a
    min(ans1, ans2), max(ans1, ans2)
end

function winning_range(time, distance)
    # held * (time - held) > distance
    # held * time - held^2 - distance > 0
    min, max = quadratic_formula(-1, time, -distance)

    min = floor(Int, min) + 1
    max = ceil(Int, max) - 1
    min:max
end

#= Answer1 =#

function answer1(input)
    a = map(zip(input...)) do pair
        parse.(Int, pair)
    end
    prod(a) do (time, distance)
        winning_range(time, distance) |> length
    end
end

#= Answer2 =#

function answer2(input)
    (time, distance) = parse.(Int, reduce.(*, input))
    winning_range(time, distance) |> length
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

test_input_1 = "Time:      7  15   30
Distance:  9  40  200
" |> split_newline

@test answer1(test_input_1 |> parse_input) == 288

@test answer2(test_input_1 |> parse_input) == 71503
