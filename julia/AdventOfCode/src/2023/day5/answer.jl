#= Data parsing =#

function load_data()
    readlines(@__DIR__() * "/input.txt")
end

function parse_input(data)
    empty_lines = [findall(isempty.(data)); length(data) + 1]
    ranges = range.([1; empty_lines[1:end-1] .+ 1], empty_lines .- 1)
    chunks = [data[idx] for idx in ranges]
    seed_str = split(chunks[1][1], ':')[2]
    seeds = parse.(Int, split(seed_str))

    mappings = map(chunks[2:end]) do chunk
        map(chunk[2:end]) do line
            MappingRange(parse.(Int, split(line))...)
        end
    end
    seeds, mappings
end

#= Shared =#

struct MappingRange
    destination::Int
    origin::Int
    length::Int
end

function origin_range(mapping::MappingRange)
    (mapping.origin):(mapping.origin+mapping.length-1)
end

#= Answer1 =#

function next(origin, mapping::Vector{MappingRange})
    for range in mapping
        if origin in origin_range(range)
            return origin + (range.destination - range.origin)
        end
    end
    origin
end

function next(origin, mappings::Vector{Vector{MappingRange}})
    for mapping in mappings
        origin = next(origin, mapping)
    end
    origin
end

function answer1(input)
    seeds, mappings = input
    minimum([next(seed, mappings) for seed in seeds])
end

#= Answer2 =#

include("ranges.jl")

function next(origin::Ranges, mappings::Vector{Vector{MappingRange}})
    for mapping in mappings
        origin = next(origin, mapping)
    end
    origin
end

function next(origin::Ranges, mapping::Vector{MappingRange})
    unmapped = origin
    mapped_to = Ranges([])
    for range in mapping
        intersection = intersect(origin, origin_range(range))
        if !isempty(intersection)
            delta = range.destination - range.origin
            unmapped = setdiff(unmapped, intersection)
            mapped_to = union(mapped_to, intersection + delta)
        end
    end
    # Any source numbers that aren't mapped correspond to the same destination number.
    union(mapped_to, unmapped)
end


function answer2(input)
    seeds, mappings = input
    ranges = map(zip(seeds[1:2:end], seeds[2:2:end])) do (start, len)
        next(Ranges(start:start+len), mappings)
    end
    minimum(ranges) do range
        minimum(range)
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

test_input_1 = "seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
" |> split_newline
test_input_2 = "" |> split_newline

@test answer1(test_input_1 |> parse_input) == 35

@test answer2(test_input_1 |> parse_input) == 46
