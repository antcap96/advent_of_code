#= Data parsing =#

function load_data()
    readlines(@__DIR__() * "/input.txt")
end

function parse_input(data)
    data = filter(!isempty, data)
    map(split.(data)) do (pattern, arrangements)
        pattern, parse.(Int, split(arrangements, ','))
    end
end

#= Shared =#

const possibilities_memorization::Dict{Tuple{SubString{String},Array{Int}},Int} = Dict()
function possibilities(str, arrangements, min_length)
    if haskey(possibilities_memorization, (str, arrangements))
        return possibilities_memorization[(str, arrangements)]
    end

    if length(str) == 0
        if length(arrangements) != 0
            return 0
        else
            return 1
        end
    end
    if length(str) < min_length
        return 0
    end
    if str[1] == '.'
        return possibilities(str[2:end], arrangements, min_length)
    elseif str[1] == '#'
        if length(arrangements) == 0
            return 0
        else
            n = arrangements[1]
            if length(str) < n + 1
                return 0
            else
                if all(x in "#?" for x in str[1:n]) && str[n+1] in ".?"
                    return possibilities(str[n+2:end], arrangements[2:end], min_length - n - 1)
                else
                    return 0
                end
            end
        end
    else #str[1] == '?'
        count1 = possibilities('#' * str[2:end], arrangements, min_length)
        count2 = possibilities(str[2:end], arrangements, min_length)
        possibilities_memorization[(str, arrangements)] = count1 + count2
        return count1 + count2
    end
end

#= Answer1 =#

function answer1(input)
    sum(input) do (pattern, arrangements)
        min_length = sum(arrangements) + length(arrangements)
        possibilities(pattern * '.', arrangements, min_length)
    end
end

#= Answer2 =#

function answer2(input)
    sum(input) do (pattern, arrangements)
        pattern = join(repeat([pattern], 5), '?') * '.'
        arrangements = repeat(arrangements, 5)
        min_length = (sum(arrangements) + length(arrangements))
        possibilities(pattern, arrangements, min_length)
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

test_input_1 = "???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
" |> split_newline

@test answer1(test_input_1 |> parse_input) == 21

@test answer2(test_input_1 |> parse_input) == 525152
