#= Data parsing =#

function load_data()
    readlines(@__DIR__() * "/input.txt")
end

function parse_input(data)
    mirrors = filter.(!isempty, split.(split(join(data, '\n'), "\n\n"), '\n'))

    map(mirrors) do mirror
        reduce(vcat, permutedims.(collect.(mirror)))
    end
end

#= Shared =#

function reflection(mirror, axis)
    len = size(mirror, axis)
    for i in 1:(size(mirror, axis)-1)
        r1 = max(1, 2i - len + 1):i
        r2 = min(2i, len):-1:i+1
        if axis == 1
            if mirror[r1, :] == mirror[r2, :]
                return i
            end
        else
            if mirror[:, r1] == mirror[:, r2]
                return i
            end
        end
    end
    0
end

function reflection2(mirror, axis)
    len = size(mirror, axis)
    for i in 1:(size(mirror, axis)-1)
        r1 = max(1, 2i - len + 1):i
        r2 = min(2i, len):-1:i+1
        if axis == 1
            if sum(mirror[r1, :] .!= mirror[r2, :]) == 1
                return i
            end
        else
            if sum(mirror[:, r1] .!= mirror[:, r2]) == 1
                return i
            end
        end
    end
    0
end

#= Answer1 =#

function answer1(input)
    sum(input) do mirror
        100 * reflection(mirror, 1) + reflection(mirror, 2)
    end
end

#= Answer2 =#

function answer2(input)
    sum(input) do mirror
        100 * reflection2(mirror, 1) + reflection2(mirror, 2)
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

test_input_1 = "#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
" |> split_newline
test_input_2 = "" |> split_newline

@test answer1(test_input_1 |> parse_input) == 405

@test answer2(test_input_1 |> parse_input) == 400
