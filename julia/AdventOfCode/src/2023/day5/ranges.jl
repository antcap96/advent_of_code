struct RangeSet
    ranges::Vector{UnitRange{Int}}
    function RangeSet(ranges::Vector{UnitRange{Int}})
        new(ranges |> sort |> combine_consecutive)
    end
end

RangeSet() = RangeSet(UnitRange{Int}[])

RangeSet(range::UnitRange{Int}) = RangeSet([range])

function combine_consecutive(arr::Vector{UnitRange{Int}})
    output = UnitRange{Int}[]
    for range in arr
        if isempty(range)
            continue
        end
        if isempty(output)
            push!(output, range)
        else
            last = output[end]
            if last.stop + 1 == range.start
                output[end] = last.start:range.stop
            else
                push!(output, range)
            end
        end
    end
    output
end

function Base.intersect(a::RangeSet, b::UnitRange{Int})
    intersections = map(a.ranges) do range
        intersect(range, b)
    end
    RangeSet(filter(!isempty, intersections))
end

function Base.isempty(ranges::RangeSet)
    isempty(ranges.ranges)
end

function Base.:(+)(ranges::RangeSet, delta::Int)
    RangeSet(
        map(ranges.ranges) do range
            range .+ delta
        end
    )
end

function Base.union(r1::RangeSet, r2::RangeSet)
    r2 = setdiff(r2, r1)
    RangeSet([r1.ranges; r2.ranges])
end

function Base.setdiff(r1::RangeSet, r2::RangeSet)
    output = r1
    for r in r2.ranges
        output = setdiff(output, r)
    end
    output
end

function Base.setdiff(ranges::RangeSet, r::UnitRange{Int})
    output = UnitRange{Int}[]
    for range in ranges.ranges
        intersection = intersect(range, r)
        if isempty(intersection)
            push!(output, range)
        else
            start = range.start:(intersection.start-1)
            if !isempty(start)
                push!(output, start)
            end
            stop = (intersection.stop+1):range.stop
            if !isempty(stop)
                push!(output, stop)
            end
        end
    end
    RangeSet(output)
end

function Base.minimum(ranges::RangeSet)
    minimum(ranges.ranges) do range
        minimum(range)
    end
end
