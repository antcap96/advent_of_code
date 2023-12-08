#= Data parsing =#

function load_data()
    readlines(@__DIR__() * "/input.txt")
end

function parse_input(data)
    moves = data[1]
    edges = map(filter(!isempty, data[2:end])) do line
        start, pairs = split(line, " = ")
        left, right = split(pairs, ", ")
        start => (left[2:end], right[1:end-1])
    end |> Dict

    moves, edges
end

#= Shared =#

function index_of_move(move)
    if move == 'L'
        1
    elseif move == 'R'
        2
    else
        error("invalid move $move")
    end
end

#= Answer1 =#

function answer1(input)
    moves, edges = input
    infinite_moves = Iterators.enumerate(Iterators.cycle(moves))

    at = "AAA"[:]
    for (i, move) in infinite_moves
        at = edges[at][index_of_move(move)]
        if at == "ZZZ"
            return i
        end
    end
end

#= Answer2 =#

function answer2(input)
    moves, edges = input

    jump_map = create_map(moves, edges)

    ends = [k for k in keys(jump_map) if endswith(k , 'Z')]

    rl = [repeat_length(stop, jump_map) for stop in ends]

    lcm(rl...) * length(moves)
end

function create_map(moves, edges)
    start = keys(edges)
    at = collect(start)

    for move in moves
        at = map(at) do pos
            edges[pos][index_of_move(move)]
        end
    end

    map(zip(start, at)) do (a,b)
        a => b
    end |> Dict
end

function repeat_length(stop, jump_map)
    at = stop
    i = 0
    while true
        i += 1
        at = jump_map[at]
        if at == stop
            break
        end
    end
    i
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

test_input_1 = "LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
" |> split_newline
test_input_2 = "LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
" |> split_newline

@test answer1(test_input_1 |> parse_input) == 6

@test answer2(test_input_2 |> parse_input) == 6
