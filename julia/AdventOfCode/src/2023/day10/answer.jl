#= Data parsing =#

function load_data()
    readlines(@__DIR__() * "/input.txt")
end

function parse_input(data)
    data = filter(!isempty, data)

    matrix = vcat(permutedims.(collect.(data))...)

    start = findfirst(matrix .== 'S')

    s = identify_start(matrix, start)

    matrix[start] = s

    start, Pipe.(Int.(matrix))
end

function get_or_nothing(matrix, idx)
    if idx in eachindex(IndexCartesian(), matrix)
        matrix[idx]
    end
end


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

#= Shared =#

@enum Pipes begin
    NS = Int('|')
    EW = Int('-')
    NE = Int('L')
    NW = Int('J')
    SW = Int('7')
    SE = Int('F')
    Ground = Int('.')
end

const N_PIPES = [NS, NE, NW]
const S_PIPES = [NS, SE, SW]
const E_PIPES = [EW, NE, SE]
const W_PIPES = [EW, NW, SW]


const NEIGHBORS = Dict(
    NS => [CartesianIndex(-1, 0), CartesianIndex(1, 0)],
    NE => [CartesianIndex(-1, 0), CartesianIndex(0, 1)],
    NW => [CartesianIndex(-1, 0), CartesianIndex(0, -1)],
    SE => [CartesianIndex(1, 0), CartesianIndex(0, 1)],
    SW => [CartesianIndex(1, 0), CartesianIndex(0, -1)],
    EW => [CartesianIndex(0, 1), CartesianIndex(0, -1)],
)

function neighbors(point, matrix, distances)
    neighbors_ = Ref(point) .+ NEIGHBORS[matrix[point]]
    filter(neighbors_) do neighbor
        neighbor in eachindex(IndexCartesian(), matrix) &&
            distances[neighbor] == -1
    end
end

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

function Base.show(io::IO, matrix::Matrix{Pipes})
    text = join(join.(eachrow(Char.(Int.(matrix)))), "\n")
    print(io, text)
end

#= Answer1 =#

function answer1(input)
    start, matrix = input
    maximum(bfs(start, matrix))
end

#= Answer2 =#

function double_resolution(matrix::AbstractMatrix{Pipes})
    new_size = size(matrix) .* 2 .+ 1
    doubled = fill(Ground, new_size)
    doubled[2:2:end, 2:2:end] = matrix

    new_EW = in.(doubled, Ref(E_PIPES))[:, 1:end-2] .&& in.(doubled, Ref(W_PIPES))[:, 3:end]
    new_NS = in.(doubled, Ref(S_PIPES))[1:end-2, :] .&& in.(doubled, Ref(N_PIPES))[3:end, :]

    @view(doubled[:, 2:end-1])[new_EW] .= EW
    @view(doubled[2:end-1, :])[new_NS] .= NS

    doubled
end

function start_flood(matrix::AbstractMatrix{Pipes}, start)
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
    flood(marks, start + start_delta[matrix[start]][1], 1)
    flood(marks, start + start_delta[matrix[start]][2], 2)

    marks
end

function flood(matrix, point, value)
    deltas = [
        CartesianIndex(0, 1),
        CartesianIndex(0, -1),
        CartesianIndex(1, 0),
        CartesianIndex(-1, 0),
    ]
    matrix[point] = value
    to_visit = [point]
    while true
        next_to_visit = []
        for p in to_visit
            next = [p + d for d in deltas if get_or_nothing(matrix, p + d) == 0]
            for n in next
                matrix[n] = value
            end
            next_to_visit = [next_to_visit; next]
        end
        to_visit = next_to_visit
        if isempty(to_visit)
            break
        end
    end
    matrix
end

function get_mark_of_interest(marks)
    if marks[1, 1] != 0
        3 - marks[1, 1]
    else
        @warn "humm"
        1
    end
end

function half_resolution(matrix)
    matrix[2:2:end-1, 2:2:end-1]
end

function answer2(input)
    start, matrix = input
    matrix2 = double_resolution(matrix)
    @show size(matrix2)
    marks = start_flood(matrix2, start * 2)
    mark_of_interest = get_mark_of_interest(marks)
    display(marks)
    display(half_resolution(marks))
    sum(half_resolution(marks) .== mark_of_interest)
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

test_input_1 = ".....
.S-7.
.|.|.
.L-J.
.....
" |> split_newline
test_input_2 = "..F7.
.FJ|.
SJ.L7
|F--J
LJ...
" |> split_newline

test_input_3 = "...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........
" |> split_newline

test_input_4 = "..........
.S------7.
.|F----7|.
.||....||.
.||....||.
.|L-7F-J|.
.|..||..|.
.L--JL--J.
.........." |> split_newline

test_input_5 = ".F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
" |> split_newline

test_input_6 = "FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
" |> split_newline

@test answer1(test_input_1 |> parse_input) == 4
@test answer1(test_input_2 |> parse_input) == 8

@test answer2(test_input_3 |> parse_input) == 4
@test answer2(test_input_4 |> parse_input) == 4
@test answer2(test_input_5 |> parse_input) == 8
@test answer2(test_input_6 |> parse_input) == 10