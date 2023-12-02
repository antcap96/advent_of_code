using DataStructures

#= Data parsing =#

function load_data()
    readlines(@__DIR__() * "/input.txt")
end

function parse_input(data)
    data = filter(data) do line
        !isempty(line)
    end
    map(parse_line, data)
end

function parse_line(line)
    game, results = split(line, ':')
    game_id = parse(Int, split(game)[2])

    results = split(results, ';')
    revealed = map(results) do revealed
        each = split(revealed, ',')
        DefaultDict(0,
            map(each) do group
                count, color = split(group)
                color => parse(Int, count)
            end...
        )
    end

    (game_id, revealed)
end

#= Answer1 =#

function answer1(input)
    maxes = ["red" => 12, "green" => 13, "blue" => 14]

    possible_games = filter(input) do (_, revealed)
        is_possible(revealed, maxes)
    end
    sum([game_id for (game_id, _) in possible_games])
end

function is_possible(revealed, maxes::AbstractVector{Pair{S,I}}) where {
    S<:AbstractString,
    I<:Integer
}
    for reveal in revealed
        for pair in maxes
            if reveal[pair.first] > pair.second
                return false
            end
        end
    end
    true
end

#= Answer2 =#

function answer2(input)
    sum(input) do (_, revealed)
        prod(["red", "green", "blue"]) do color
            maximum(revealed) do reveal
                reveal[color]
            end
        end
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

test_input_1 = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
" |> split_newline

@test answer1(test_input_1 |> parse_input) == ...

@test answer2(test_input_1 |> parse_input) == ...