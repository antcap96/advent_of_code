### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ ee97f4ba-f510-4e6d-a656-d85de9157ecf
begin
    using Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
end

# ╔═╡ b1001272-fc89-4d4f-abf0-f24298660c7e
using Memoization

# ╔═╡ bc0fc830-56b1-4a15-9968-9d219b9f2e4f
using Test

# ╔═╡ 7a7ba6ad-d1a8-4e6f-90db-3d2c98d5ae7a
function load_data()
    readchomp(@__DIR__() * "/input.txt")
end

# ╔═╡ 87b9530c-3a36-4432-b484-df24d7bcf773
function parse_input(data)
    lines = split(data, '\n')
    map(split.(lines)) do (pattern, arrangements)
        pattern, parse.(Int, split(arrangements, ','))
    end
end

# ╔═╡ f22bb5cb-93e1-4492-a921-13727967e86f
@memoize Dict{Tuple{Tuple{Char,SubString{String},Vector{Int}},Tuple{}},Int} function possibilities_(at::Char, rest::SubString{String}, arrangements::Vector{Int})
    if at == '.'
        if !isempty(rest)
            return possibilities_(rest[1], rest[2:end], arrangements)
        else
            if isempty(arrangements)
                return 1
            else
                return 0
            end
        end
    elseif at == '#'
        if length(arrangements) == 0
            return 0
        else
            n = arrangements[1]
            if length(rest) < n
                return 0
            else
                if all(x in "#?" for x in rest[1:(n-1)]) && rest[n] in ".?"
                    return possibilities_('.', rest[n+1:end], arrangements[2:end])
                else
                    return 0
                end
            end
        end
    elseif at == '?'
        count1 = possibilities_('#', rest, arrangements)
        count2 = possibilities_('.', rest, arrangements)
        return count1 + count2
    else
        throw("Unknown char '$at'")
    end
end

# ╔═╡ 7dce5ca5-118e-46a5-9c8d-9bd1d83d09e1
function possibilities(str::AbstractString, arrangements::Vector{Int})
    possibilities_(str[1], SubString(str[2:end] * '.', 1), arrangements)
end

# ╔═╡ 614882d0-8f97-4a35-952c-a80ee71a297a
function answer1(input)
    sum(input) do (pattern, arrangements)
        possibilities(pattern, arrangements)
    end
end

# ╔═╡ a57ddb61-c68f-4f69-b772-04c3aed6f44f
function answer2(input)
    sum(input) do (pattern, arrangements)
        pattern = join(repeat([pattern], 5), '?')
        arrangements = repeat(arrangements, 5)
        possibilities(pattern, arrangements)
    end
end

# ╔═╡ d42d50d9-4374-4243-b8f2-41493640a37a
function answer()
    data = load_data()

    input = parse_input(data)

    ans1 = answer1(input)
    ans2 = answer2(input)

    println("Answer 1 is: $ans1")
    println("Answer 2 is: $ans2")
end

# ╔═╡ ce31bdf8-6992-4c3d-ae6e-3393b8cae4e0
answer()

# ╔═╡ 4788c79a-8fe8-4b05-99dc-3fe98032395c
split_newline = s -> split(s, '\n')

# ╔═╡ 8f39980a-ca82-40e7-9224-950f3be74498
test_input_1 = "???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1"

# ╔═╡ e8a071e5-2b5c-4d15-821e-36c7af07c798
@test answer1(test_input_1 |> parse_input) == 21

# ╔═╡ d9d64721-cb03-4aa7-b607-fb933ca04506
@test answer2(test_input_1 |> parse_input) == 525152

# ╔═╡ Cell order:
# ╠═ee97f4ba-f510-4e6d-a656-d85de9157ecf
# ╠═b1001272-fc89-4d4f-abf0-f24298660c7e
# ╠═7a7ba6ad-d1a8-4e6f-90db-3d2c98d5ae7a
# ╠═87b9530c-3a36-4432-b484-df24d7bcf773
# ╠═f22bb5cb-93e1-4492-a921-13727967e86f
# ╠═7dce5ca5-118e-46a5-9c8d-9bd1d83d09e1
# ╠═614882d0-8f97-4a35-952c-a80ee71a297a
# ╠═a57ddb61-c68f-4f69-b772-04c3aed6f44f
# ╠═d42d50d9-4374-4243-b8f2-41493640a37a
# ╠═ce31bdf8-6992-4c3d-ae6e-3393b8cae4e0
# ╠═bc0fc830-56b1-4a15-9968-9d219b9f2e4f
# ╠═4788c79a-8fe8-4b05-99dc-3fe98032395c
# ╠═8f39980a-ca82-40e7-9224-950f3be74498
# ╠═e8a071e5-2b5c-4d15-821e-36c7af07c798
# ╠═d9d64721-cb03-4aa7-b607-fb933ca04506
