#= Data parsing =#

function load_data()
    readlines(@__DIR__() * "/input.txt")
end

function parse_input(data)
    lines = filter(data) do line
        !isempty(line)
    end
    vcat(permutedims.(collect.(lines))...)
end

#= Shared =#

struct FoundNumber
    start::CartesianIndex
    end_::CartesianIndex
    value::Int
end

function FoundNumber(pos, str)
    FoundNumber(
        CartesianIndex(pos[1], pos[2] - length(str)),
        CartesianIndex(pos[1], pos[2] - 1),
        parse(Int, str),
    )
end

function get_numbers(input)
    numbers = []

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
                    number = ch
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

#= Answer1 =#

function answer1(input)
    symbols = .!(isdigit.(input) .|| input .== '.')
    neighbors = circshift(symbols, (-1, -1)) .||
                circshift(symbols, (-1, 0)) .||
                circshift(symbols, (-1, 1)) .||
                circshift(symbols, (0, -1)) .||
                circshift(symbols, (0, 1)) .||
                circshift(symbols, (1, -1)) .||
                circshift(symbols, (1, 0)) .||
                circshift(symbols, (1, 1))
    numbers = get_numbers(input)

    valid_numbers = filter(numbers) do number
        any(neighbors[number.start:number.end_])
    end

    sum(valid_numbers) do number
        number.value
    end
end

#= Answer2 =#

function neighbor(idx::CartesianIndex, idxs::CartesianIndices)
    any([idx + CartesianIndex(x, y) in idxs for x in -1:1 for y in -1:1])
end

function answer2(input)
    gears = findall(input .== '*')

    numbers = get_numbers(input)

    sum(gears) do gear
        neighbors = filter(numbers) do number
            neighbor(gear, number.start:number.end_)
        end
        if length(neighbors) != 2
            return 0
        end
        neighbors[1].value * neighbors[2].value
    end
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

test_input_1 = raw"467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
" |> split_newline

@test answer1(test_input_1 |> parse_input) == 4361

@test answer2(test_input_1 |> parse_input) == 467835