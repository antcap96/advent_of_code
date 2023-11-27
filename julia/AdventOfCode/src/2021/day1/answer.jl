function answer()
    string = readlines(@__DIR__() * "/input.txt")
    state = load_state(string)
    a1 = answer1(state)
    println("Answer 1: $a1")
end

function load_state(string)
    lines = filter(l -> l != "", string)
    input = vcat(permutedims.(collect.(lines))...)
    return input
end

function answer1(state)
    for i ∈ 1:5000
        state, movement = step_(state)
        if !movement
            return i
        end
    end
end

function step_(input::AbstractArray{Char,2})
    movement = false

    east_facing = input .== '>'
    can_move = circshift(input .== '.', (0, -1))
    move_from = east_facing .& can_move
    if count(move_from) > 0
        movement = true

        move_to = circshift(move_from, (0, 1))
        input[move_from] .= '.'
        input[move_to] .= '>'
    end

    south_facing = input .== 'v'
    can_move = circshift(input .== '.', (-1, 0))
    move_from = south_facing .& can_move
    if count(move_from) > 0
        movement = true

        move_to = circshift(move_from, (1, 0))
        input[move_from] .= '.'
        input[move_to] .= 'v'
    end

    return (input, movement)
end

using Test

@test split("""v...>>.vv>
.vv>>.vv..
>>.>v>...v
>>v>>.>.v.
v>v.vv.v..
>.>>..v...
.vv..>.>v.
v.v..>>v.v
....v..v.>
""", "\n") |> load_state |> answer1 == 58
