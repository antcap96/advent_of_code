### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 4b5a565e-a8ba-4bb2-a6cb-55b471872d8a
begin
    using Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
end

# ╔═╡ 4f9fd04f-89b0-4295-b215-5a0aff154f52
using Test

# ╔═╡ 055929b3-2d93-4e83-96cc-453c9e7a385d
function load_data()
    readchomp(@__DIR__() * "/input.txt")
end

# ╔═╡ 7ab86b44-1563-41a3-8c2d-7bef341b54a9
function get_or_nothing(matrix, idx)
    if checkbounds(Bool, matrix, idx)
        matrix[idx]
    end
end

# ╔═╡ 145352ed-6c49-4bc5-8b19-e1c537080086
@enum Pipe begin
    NS = Int('|')
    EW = Int('-')
    NE = Int('L')
    NW = Int('J')
    SW = Int('7')
    SE = Int('F')
    Ground = Int('.')
end

# ╔═╡ ba58b804-b288-442a-bad2-e31cc757d984
const N_PIPES = [NS, NE, NW]

# ╔═╡ c23be852-1d00-415a-a44f-746069423bd3
const S_PIPES = [NS, SE, SW]

# ╔═╡ 6318b3fe-ce39-4ff0-91ca-c077575b6988
const E_PIPES = [EW, NE, SE]

# ╔═╡ c9185ba7-38c0-4994-a908-0ec1d6ba2564
const W_PIPES = [EW, NW, SW]

# ╔═╡ 0575bd55-03a9-446a-8f0d-95e67073c202
function identify_start(matrix, start)
    north = get_or_nothing(matrix, start + CartesianIndex(-1, 0))
    south = get_or_nothing(matrix, start + CartesianIndex(1, 0))
    east = get_or_nothing(matrix, start + CartesianIndex(0, 1))
    west = get_or_nothing(matrix, start + CartesianIndex(0, -1))

    n_pipes = Char.(Int.(N_PIPES))
    s_pipes = Char.(Int.(S_PIPES))
    e_pipes = Char.(Int.(E_PIPES))
    w_pipes = Char.(Int.(W_PIPES))

    if north in s_pipes && west in e_pipes
        Char(Int(NW))
    elseif north in s_pipes && east in w_pipes
        Char(Int(NE))
    elseif south in n_pipes && west in e_pipes
        Char(Int(SW))
    elseif south in n_pipes && east in w_pipes
        Char(Int(SE))
    elseif north in s_pipes && south in n_pipes
        Char(Int(NS))
    elseif east in w_pipes && west in e_pipes
        Char(Int(EW))
    else
        error("Cannot identify start pipe:
        $south $N_PIPES
        $north $S_PIPES
        $west $E_PIPES
        $east $W_PIPES
        ")
    end
end

# ╔═╡ 925a8995-9423-4291-86b3-083a80923624
function parse_input(data)
    lines = split(data, '\n')

    matrix = vcat(permutedims.(collect.(lines))...)

    start = findfirst(matrix .== 'S')

    s = identify_start(matrix, start)

    matrix[start] = s

    start, Pipe.(Int.(matrix))
end

# ╔═╡ 818c0525-2185-4221-8d51-d5bc7b7778ec
const NEIGHBORS = Dict(
    NS => [CartesianIndex(-1, 0), CartesianIndex(1, 0)],
    NE => [CartesianIndex(-1, 0), CartesianIndex(0, 1)],
    NW => [CartesianIndex(-1, 0), CartesianIndex(0, -1)],
    SE => [CartesianIndex(1, 0), CartesianIndex(0, 1)],
    SW => [CartesianIndex(1, 0), CartesianIndex(0, -1)],
    EW => [CartesianIndex(0, 1), CartesianIndex(0, -1)],
)

# ╔═╡ 662cb508-1b53-4dfb-8e7d-1c000e5bcaa8
function neighbors(point, matrix, distances)
    neighbors_ = Ref(point) .+ NEIGHBORS[matrix[point]]
    filter(neighbors_) do neighbor
        get_or_nothing(distances, neighbor) == -1
    end
end

# ╔═╡ f2611883-acc1-437e-8674-f409e5a9090c
function bfs(start, matrix)
    distances = fill(-1, size(matrix))
    distances[start] = 0

    to_visit = [start]
    depth = 1
    while true
        next_to_visit = []
        for p in to_visit
            next = neighbors(p, matrix, distances)
            distances[next] .= depth
            next_to_visit = [next_to_visit; next]
        end
        to_visit = next_to_visit
        if isempty(to_visit)
            break
        end
        depth += 1
    end
    distances
end

# ╔═╡ e56ebc50-0532-4b3b-9748-237ef23ded8b
function Base.show(io::IO, matrix::Matrix{Pipe})
    text = join(join.(eachrow(Char.(Int.(matrix)))), "\n")
    print(io, text)
end

# ╔═╡ 689f202d-482f-4e5d-8109-dd16b66b0d0d
function answer1(input)
    start, matrix = input
    maximum(bfs(start, matrix))
end

# ╔═╡ 59adc8ce-844c-40b5-a9af-68f8b556126b
function double_resolution(matrix::AbstractMatrix{Pipe})
    new_size = size(matrix) .* 2 .+ 1
    doubled = fill(Ground, new_size)
    # Fill every other point
    doubled[2:2:end, 2:2:end] = matrix

    # Fill gaps between where necessary	
    new_EW = (
        in.(doubled[:, 1:end-2], Ref(E_PIPES)) .&&
        in.(doubled[:, 3:end], Ref(W_PIPES))
    )
    new_NS = (
        in.(doubled[1:end-2, :], Ref(S_PIPES)) .&&
        in.(doubled[3:end, :], Ref(N_PIPES))
    )

    @view(doubled[:, 2:end-1])[new_EW] .= EW
    @view(doubled[2:end-1, :])[new_NS] .= NS

    doubled
end

# ╔═╡ 4d0751bc-cdfd-4cc5-a59b-c19fc85c0b12
function flood!(matrix, point, value)
    deltas = [
        CartesianIndex(0, 1),
        CartesianIndex(0, -1),
        CartesianIndex(1, 0),
        CartesianIndex(-1, 0),
    ]
    matrix[point] = value
    to_visit = [point]
    while !isempty(to_visit)
        next_to_visit = []
        for p in to_visit
            next = [p + d for d in deltas if get_or_nothing(matrix, p + d) == 0]
            for n in next
                matrix[n] = value
            end
            next_to_visit = [next_to_visit; next]
        end
        to_visit = next_to_visit
    end
    matrix
end

# ╔═╡ b1b92394-c82d-41af-b799-5d62f519df6a
function start_flood(matrix::AbstractMatrix{Pipe}, start)
    start_delta = Dict(
        NS => [CartesianIndex(0, -1), CartesianIndex(0, 1)],
        NE => [CartesianIndex(-1, 1), CartesianIndex(1, -1)],
        NW => [CartesianIndex(-1, -1), CartesianIndex(1, 1)],
        SE => [CartesianIndex(1, 1), CartesianIndex(-1, -1)],
        SW => [CartesianIndex(1, -1), CartesianIndex(-1, 1)],
        EW => [CartesianIndex(-1, 0), CartesianIndex(1, 0)],
    )
    marks = zeros(Int, size(matrix))
    marks[bfs(start, matrix).!=-1] .= -1
    flood!(marks, start + start_delta[matrix[start]][1], 1)
    flood!(marks, start + start_delta[matrix[start]][2], 2)

    marks
end

# ╔═╡ 201b7fc7-0a8b-42ff-adb5-0da8e424e29e
function get_mark_of_interest(marks)
    3 - marks[1, 1]
end

# ╔═╡ 7ff0426f-9a90-459d-861c-58c899855bea
function half_resolution(matrix)
    matrix[2:2:end-1, 2:2:end-1]
end

# ╔═╡ 5283318e-9de7-406c-9c1d-95f7357e96d7
function answer2(input)
    start, matrix = input
    matrix2 = double_resolution(matrix)
    marks = start_flood(matrix2, start * 2)
    mark_of_interest = get_mark_of_interest(marks)
    sum(half_resolution(marks) .== mark_of_interest)
end

# ╔═╡ b2a53c7e-4c10-4d91-9b75-bbb36a5f2f09
function answer()
    data = load_data()

    input = parse_input(data)

    ans1 = answer1(input)
    ans2 = answer2(input)

    println("Answer 1 is: $ans1")
    println("Answer 2 is: $ans2")
end

# ╔═╡ a3b2c4fc-e9da-4374-b0a0-124facb10d54
answer()

# ╔═╡ f1be99a4-d40c-4dcd-b393-24a9484eb43f
test_input_1 = ".....
.S-7.
.|.|.
.L-J.
....."

# ╔═╡ e0211dd9-fb59-4aff-88c0-b48af098c23b
test_input_2 = "..F7.
.FJ|.
SJ.L7
|F--J
LJ..."

# ╔═╡ db05fefb-af5a-4262-9587-f50fd7afc0f4
test_input_3 = "...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
..........."

# ╔═╡ d20466b6-4e31-424c-9fa4-a7f0724f5fe1
test_input_4 = "..........
.S------7.
.|F----7|.
.||....||.
.||....||.
.|L-7F-J|.
.|..||..|.
.L--JL--J.
.........."

# ╔═╡ 2d2f2ef4-d7f2-4df4-9f2a-0cc290f03eac
test_input_5 = ".F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ..."

# ╔═╡ c4e8147d-e73e-4e36-87e4-665cc51ea54d
test_input_6 = "FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L"

# ╔═╡ d3df6483-4334-40d2-ab59-3d1c8199ab9d
@test answer1(test_input_1 |> parse_input) == 4

# ╔═╡ 663f609b-b5e7-40da-8857-dfae967b8403
@test answer1(test_input_2 |> parse_input) == 8

# ╔═╡ d1b02178-77d1-4739-ba5a-997f54425b39
@test answer2(test_input_3 |> parse_input) == 4

# ╔═╡ 6b32df9f-9011-47ec-a0ab-4b5a08599be9
@test answer2(test_input_4 |> parse_input) == 4

# ╔═╡ 092ffd5c-2393-45db-ac8e-5a8698cc8ae3
@test answer2(test_input_5 |> parse_input) == 8

# ╔═╡ ee0a8314-2d45-47a6-b081-14e1e956e052
@test answer2(test_input_6 |> parse_input) == 10

# ╔═╡ Cell order:
# ╠═4b5a565e-a8ba-4bb2-a6cb-55b471872d8a
# ╠═055929b3-2d93-4e83-96cc-453c9e7a385d
# ╠═925a8995-9423-4291-86b3-083a80923624
# ╠═7ab86b44-1563-41a3-8c2d-7bef341b54a9
# ╠═0575bd55-03a9-446a-8f0d-95e67073c202
# ╠═145352ed-6c49-4bc5-8b19-e1c537080086
# ╠═ba58b804-b288-442a-bad2-e31cc757d984
# ╠═c23be852-1d00-415a-a44f-746069423bd3
# ╠═6318b3fe-ce39-4ff0-91ca-c077575b6988
# ╠═c9185ba7-38c0-4994-a908-0ec1d6ba2564
# ╠═818c0525-2185-4221-8d51-d5bc7b7778ec
# ╠═662cb508-1b53-4dfb-8e7d-1c000e5bcaa8
# ╠═f2611883-acc1-437e-8674-f409e5a9090c
# ╠═e56ebc50-0532-4b3b-9748-237ef23ded8b
# ╠═689f202d-482f-4e5d-8109-dd16b66b0d0d
# ╠═59adc8ce-844c-40b5-a9af-68f8b556126b
# ╠═b1b92394-c82d-41af-b799-5d62f519df6a
# ╠═4d0751bc-cdfd-4cc5-a59b-c19fc85c0b12
# ╠═201b7fc7-0a8b-42ff-adb5-0da8e424e29e
# ╠═7ff0426f-9a90-459d-861c-58c899855bea
# ╠═5283318e-9de7-406c-9c1d-95f7357e96d7
# ╠═b2a53c7e-4c10-4d91-9b75-bbb36a5f2f09
# ╠═a3b2c4fc-e9da-4374-b0a0-124facb10d54
# ╠═4f9fd04f-89b0-4295-b215-5a0aff154f52
# ╠═f1be99a4-d40c-4dcd-b393-24a9484eb43f
# ╠═e0211dd9-fb59-4aff-88c0-b48af098c23b
# ╠═db05fefb-af5a-4262-9587-f50fd7afc0f4
# ╠═d20466b6-4e31-424c-9fa4-a7f0724f5fe1
# ╠═2d2f2ef4-d7f2-4df4-9f2a-0cc290f03eac
# ╠═c4e8147d-e73e-4e36-87e4-665cc51ea54d
# ╠═d3df6483-4334-40d2-ab59-3d1c8199ab9d
# ╠═663f609b-b5e7-40da-8857-dfae967b8403
# ╠═d1b02178-77d1-4739-ba5a-997f54425b39
# ╠═6b32df9f-9011-47ec-a0ab-4b5a08599be9
# ╠═092ffd5c-2393-45db-ac8e-5a8698cc8ae3
# ╠═ee0a8314-2d45-47a6-b081-14e1e956e052
