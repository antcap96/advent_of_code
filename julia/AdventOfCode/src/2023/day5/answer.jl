### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ fc492531-5f5f-4c3f-8acf-eb5733e67029
begin
    using Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
end

# ╔═╡ afd02ace-a9f7-4b04-b0d8-dd69f342d381
using Intervals

# ╔═╡ 033d0af9-6edf-4d2e-83e1-cb13e0fd0628
using Test

# ╔═╡ 6dc20dae-d634-4a57-bcc4-244f75c7299e
function Base.:+(a::IntervalSet, b)
    IntervalSet(map(x -> x + b, convert(Array, a)))
end

# ╔═╡ 8b2294ae-89ce-4b18-b968-30167a503845
Base.:+(b, a::IntervalSet) = a + b

# ╔═╡ 1fc48119-12fe-4e97-8f01-4db83e6fdbb6
function Base.minimum(s::IntervalSet)
    minimum(map(minimum, convert(Array, s)))
end

# ╔═╡ 019eb054-1a68-4b5e-a3b7-541c34d946d1
function load_data()
    readchomp(@__DIR__() * "/input.txt")
end

# ╔═╡ 03376d68-b4a8-4619-b7b5-4dc716647499
struct MappingRange
    destination::Int
    origin::Int
    length::Int
end

# ╔═╡ d6462b57-141b-4abf-b85d-6254a1d19afa
function parse_input(data)
    chunks = split.(split(data, "\n\n"), '\n')

    seed_str = split(chunks[1][1], ':')[2]
    seeds = parse.(Int, split(seed_str))

    mappings = map(chunks[2:end]) do chunk
        map(chunk[2:end]) do line
            MappingRange(parse.(Int, split(line))...)
        end
    end
    seeds, mappings
end

# ╔═╡ e68d6a7e-bcc6-4840-b660-ff13730d2eae
function origin_interval(mapping::MappingRange)
    Interval{Closed,Open}(mapping.origin, mapping.origin + mapping.length)
end

# ╔═╡ 440d607d-a299-4c52-b9a0-853fcde17559
function next(origin, mapping::Vector{MappingRange})
    for range in mapping
        if origin in origin_interval(range)
            return origin + (range.destination - range.origin)
        end
    end
    origin
end

# ╔═╡ 426bbfe3-e94f-4686-a3fc-11bb4148c750
function next(origin, mappings::Vector{Vector{MappingRange}})
    for mapping in mappings
        origin = next(origin, mapping)
    end
    origin
end

# ╔═╡ fe602630-462e-4f37-b00d-133ef3e522df
function next(origin::IntervalSet, mappings::Vector{Vector{MappingRange}})
    for mapping in mappings
        origin = next(origin, mapping)
    end
    origin
end

# ╔═╡ fd62574c-2b07-46d6-a9ef-3da7f883dc77
function next(origin::IntervalSet, mapping::Vector{MappingRange})
    unmapped = origin
    mapped_to = IntervalSet(Interval{Int,Closed,Open}[])
    for range in mapping
        intersection = origin ∩ origin_interval(range)
        if !isempty(intersection)
            delta = range.destination - range.origin
            unmapped = setdiff(unmapped, intersection)
            mapped_to = (mapped_to ∪ (intersection + delta))
        end
    end
    # Any source numbers that aren't mapped correspond to the same destination number.
    mapped_to ∪ unmapped
end

# ╔═╡ 9b40b9c0-d55d-4908-88f2-595c1ef2c47f
function answer1(input)
    seeds, mappings = input
    minimum(seeds) do seed
        next(seed, mappings)
    end
end

# ╔═╡ e5c84b64-2695-4a6f-8272-264cf170b19e
function answer2(input)
    seeds, mappings = input
    ranges = map(zip(seeds[1:2:end], seeds[2:2:end])) do (start, len)
        next(IntervalSet(Interval{Closed,Open}(start, start + len)), mappings)
    end
    minimum(ranges) do range
        minimum(range)
    end
end

# ╔═╡ 3b65d3b0-1f31-4d31-b3cd-e3194caad819
function answer()
    data = load_data()

    input = parse_input(data)

    ans1 = answer1(input)
    ans2 = answer2(input)

    println("Answer 1 is: $ans1")
    println("Answer 2 is: $ans2")
end

# ╔═╡ b6e36731-dde8-4d8a-8987-58a7fbd52824
answer()

# ╔═╡ ee5c316f-113a-4b91-881e-0d837818b4c9
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
56 93 4"

# ╔═╡ ff84a7fa-d219-4173-97fb-a9bb1d2db96e
@test answer1(test_input_1 |> parse_input) == 35

# ╔═╡ 195e0502-db89-45d1-ad28-43a13b86386d
@test answer2(test_input_1 |> parse_input) == 46

# ╔═╡ Cell order:
# ╠═fc492531-5f5f-4c3f-8acf-eb5733e67029
# ╠═afd02ace-a9f7-4b04-b0d8-dd69f342d381
# ╠═6dc20dae-d634-4a57-bcc4-244f75c7299e
# ╠═8b2294ae-89ce-4b18-b968-30167a503845
# ╠═1fc48119-12fe-4e97-8f01-4db83e6fdbb6
# ╠═019eb054-1a68-4b5e-a3b7-541c34d946d1
# ╠═d6462b57-141b-4abf-b85d-6254a1d19afa
# ╠═03376d68-b4a8-4619-b7b5-4dc716647499
# ╠═e68d6a7e-bcc6-4840-b660-ff13730d2eae
# ╠═440d607d-a299-4c52-b9a0-853fcde17559
# ╠═426bbfe3-e94f-4686-a3fc-11bb4148c750
# ╠═9b40b9c0-d55d-4908-88f2-595c1ef2c47f
# ╠═fe602630-462e-4f37-b00d-133ef3e522df
# ╠═fd62574c-2b07-46d6-a9ef-3da7f883dc77
# ╠═e5c84b64-2695-4a6f-8272-264cf170b19e
# ╠═3b65d3b0-1f31-4d31-b3cd-e3194caad819
# ╠═b6e36731-dde8-4d8a-8987-58a7fbd52824
# ╠═033d0af9-6edf-4d2e-83e1-cb13e0fd0628
# ╠═ee5c316f-113a-4b91-881e-0d837818b4c9
# ╠═ff84a7fa-d219-4173-97fb-a9bb1d2db96e
# ╠═195e0502-db89-45d1-ad28-43a13b86386d
