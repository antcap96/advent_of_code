#= Data parsing =#

function load_data()
    readlines(@__DIR__() * "/input.txt")
end

function parse_input(data)
    map(filter(!isempty, data)) do line
        parse.(Int, split(line))
    end
end

#= Shared =#

function deltas(arr)
    arr[2:end] .- arr[1:end-1]
end

#= Answer1 =#

function next(arr)
    if all(arr .== 0)
        0
    else
        arr[end] + next(deltas(arr))
    end
end

function answer1(input)
    sum(next, input)
end

#= Answer2 =#

function prev(arr)
    if all(arr .== 0)
        0
    else
        arr[1] - prev(deltas(arr))
    end
end


function answer2(input)
    sum(prev, input)
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

test_input_1 = "0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
" |> split_newline
test_input_2 = "" |> split_newline

@test answer1(test_input_1 |> parse_input) == 114

@test answer2(test_input_1 |> parse_input) == 2