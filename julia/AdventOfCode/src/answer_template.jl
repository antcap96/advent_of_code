#= Data parsing =#

function load_data()
    readlines(@__DIR__() * "/input.txt")
end

function parse_input(data)
end

#= Shared =#

#= Answer1 =#

function answer1(input)
end

#= Answer2 =#

function answer2(input)
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

test_input_1 = "" |> split_newline
test_input_2 = "" |> split_newline

@test answer1(test_input_1 |> parse_input) == ...

@test answer2(test_input_2 |> parse_input) == ...