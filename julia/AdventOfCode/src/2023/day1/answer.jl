function load_data()
    readlines(@__DIR__() * "/input.txt")
end

function answer1(lines)
    sum = 0
    for line in lines
        if isempty(line)
            continue
        end
        n = parseline(line)
        sum += n
    end
    sum
end

function parseline(line)
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
    parse(Int,
        first * last)
end

function answer2(lines)
    sum = 0
    for line in lines
        if isempty(line)
            continue
        end
        n = parseline(line |> spelled_out_to_digit)
        sum += n
    end
    sum
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

function answer()
    data = load_data()

    ans1 = answer1(data)
    ans2 = answer2(data)

    println("Answer 1 is: $ans1")
    println("Answer 2 is: $ans2")
end

answer()

using Test

test_input_1 = "1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
" |> split

test_input_2 = "two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
" |> split

@test answer1(test_input_1) == 142

@test answer2(test_input_2) == 281