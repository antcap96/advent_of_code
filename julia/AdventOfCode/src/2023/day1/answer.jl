#= Data parsing =#

function load_data()
    readlines(@__DIR__() * "/input.txt")
end

function parse_input(data)
    filter(data) do line
        !isempty(line)
    end
end

#= Shared =#

function calibration_value(line)
    first = nothing
    last = nothing
    for c in line
        if isdigit(c)
            if isnothing(first)
                first = c
            end
            last = c
        end
    end
    parse(Int, first * last)
end

#= Answer1 =#

function answer1(input)
    sum(input) do line
        calibration_value(line)
    end
end

#= Answer2 =#

function answer2(input)
    sum(input) do line
        calibration_value(line |> spelled_out_to_digit)
    end
end

function spelled_out_to_digit(line)
    _replace(pair) = line -> replace(line, pair)

    (
        line
        # Keep the surrounding characters in case they are shared (eg. twone -> 21)
        |> _replace("one" => "one1one")
        |> _replace("two" => "two2two")
        |> _replace("three" => "three3three")
        |> _replace("four" => "four4four")
        |> _replace("five" => "five5five")
        |> _replace("six" => "six6six")
        |> _replace("seven" => "seven7seven")
        |> _replace("eight" => "eight8eight")
        |> _replace("nine" => "nine9nine")
    )
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

test_input_1 = "1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
" |> split_newline

test_input_2 = "two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
" |> split_newline

@test answer1(test_input_1 |> parse_input) == 142

@test answer2(test_input_2 |> parse_input) == 281