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
    range::CartesianIndices
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

function expand(idxs::CartesianIndices)
    xs = idxs.indices[1]
    ys = idxs.indices[2]
    xstart = xs.start - 1
    xstop = xs.stop + 1
    ystart = ys.start - 1
    ystop = ys.stop + 1

    CartesianIndices((xstart:xstop, ystart:ystop))
end

#= Answer1 =#

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

#= Answer2 =#

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