struct Ranges
    ranges::Vector{UnitRange{Int}}
end

Ranges(range::UnitRange{Int}) = Ranges([range])

function Base.intersect(a::Ranges, b::UnitRange{Int})
    intersections = map(a.ranges) do range
        intersect(range, b)
    end
    Ranges(
        filter(!isempty, intersections)
    )
end

function Base.isempty(ranges::Ranges)
    isempty(ranges.ranges)
end

function Base.:(+)(ranges::Ranges, delta::Int)
    Ranges(
        map(ranges.ranges) do range
            range .+ delta
        end
    )
end

function Base.union(r1::Ranges, r2::Ranges)
    # TODO: this should remove/merge overlapping ranges
    Ranges([r1.ranges; r2.ranges])
end

function Base.setdiff(r1::Ranges, r2::Ranges)
    output = r1
    for r in r2.ranges
        output = setdiff(output, r)
    end
    output
end

function Base.setdiff(ranges::Ranges, r::UnitRange{Int})
    output = UnitRange[]
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
    Ranges(output)
end

function Base.minimum(ranges::Ranges)
    minimum(ranges.ranges) do range
        minimum(range)
    end
end
