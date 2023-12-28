### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 7dcae31f-52fc-43b3-af6d-d21464f78889
begin
    using Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
end

# ╔═╡ 7dc40436-16b5-402d-9647-7c0f26962f8b
using Test

# ╔═╡ 4f2a3602-7632-4571-be39-54df631e0210
function load_data()
    readchomp(@__DIR__() * "/input.txt")
end

# ╔═╡ 9df1c661-635f-4502-8b4f-8c6f8f4f2b57
function parse_input(data)
    lines = split(data, '\n')
    moves = lines[1]
    edges = map(lines[3:end]) do line
        start, pairs = split(line, " = ")
        left, right = split(pairs, ", ")
        start => (left[2:end], right[1:end-1])
    end |> Dict

    moves, edges
end

# ╔═╡ f8c71a8d-d8fa-4b61-a8b8-5f36f7038b31
function index_of_move(move)
    if move == 'L'
        1
    elseif move == 'R'
        2
    else
        error("invalid move $move")
    end
end

# ╔═╡ ada08c42-5ba2-4687-9cf6-956df5fdc50f
function answer1(input)
    moves, edges = input
    infinite_moves = Iterators.enumerate(Iterators.cycle(moves))

    at = SubString("AAA", 1) # type stability
    for (i, move) in infinite_moves
        at = edges[at][index_of_move(move)]
        if at == "ZZZ"
            return i
        end
    end
end

# ╔═╡ 1a15ff76-c42c-4d9a-8722-9df577ec8242
function create_map(moves, edges)
    start = keys(edges)
    at = collect(start)

    for move in moves
        at = map(at) do pos
            edges[pos][index_of_move(move)]
        end
    end

    map(zip(start, at)) do (a, b)
        a => b
    end |> Dict
end

# ╔═╡ 96b3df9f-bc96-457d-9f5c-b816eb4ad4f2
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

# ╔═╡ 0ff2dbdf-55e8-48ba-8bdc-f1f17431bdb3
function answer2(input)
    moves, edges = input

    jump_map = create_map(moves, edges)

    ends = [k for k in keys(jump_map) if endswith(k, 'Z')]

    rl = [repeat_length(stop, jump_map) for stop in ends]

    lcm(rl...) * length(moves)
end

# ╔═╡ 870b9b55-2f47-413b-ab11-8df30d23d61c
function answer()
    data = load_data()

    input = parse_input(data)

    ans1 = answer1(input)
    ans2 = answer2(input)

    println("Answer 1 is: $ans1")
    println("Answer 2 is: $ans2")
end

# ╔═╡ e8db7659-06a8-42c5-a708-12dc32fb02f7
answer()

# ╔═╡ 99bdb233-a4d8-4dbc-a822-fbfa2f5f75e0
test_input_1 = "LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)"

# ╔═╡ e339b3b5-a3eb-4746-9b5a-bc8235b6afe2
test_input_2 = "LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)"

# ╔═╡ 5927f237-bf95-4548-9d41-5cc69669f8f2
@test answer1(test_input_1 |> parse_input) == 6

# ╔═╡ c94d61dc-a8ad-473a-8d85-019b3c57ff90
@test answer2(test_input_2 |> parse_input) == 6

# ╔═╡ Cell order:
# ╠═7dcae31f-52fc-43b3-af6d-d21464f78889
# ╠═4f2a3602-7632-4571-be39-54df631e0210
# ╠═9df1c661-635f-4502-8b4f-8c6f8f4f2b57
# ╠═f8c71a8d-d8fa-4b61-a8b8-5f36f7038b31
# ╠═ada08c42-5ba2-4687-9cf6-956df5fdc50f
# ╠═0ff2dbdf-55e8-48ba-8bdc-f1f17431bdb3
# ╠═1a15ff76-c42c-4d9a-8722-9df577ec8242
# ╠═96b3df9f-bc96-457d-9f5c-b816eb4ad4f2
# ╠═870b9b55-2f47-413b-ab11-8df30d23d61c
# ╠═e8db7659-06a8-42c5-a708-12dc32fb02f7
# ╠═7dc40436-16b5-402d-9647-7c0f26962f8b
# ╠═99bdb233-a4d8-4dbc-a822-fbfa2f5f75e0
# ╠═e339b3b5-a3eb-4746-9b5a-bc8235b6afe2
# ╠═5927f237-bf95-4548-9d41-5cc69669f8f2
# ╠═c94d61dc-a8ad-473a-8d85-019b3c57ff90
