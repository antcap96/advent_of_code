### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 56ed22ce-b9ea-47b4-a51c-bf0729436496
begin
    using Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
end

# ╔═╡ 5d5684bd-3471-4b6a-a77f-bf9698b2215d
using StatsBase

# ╔═╡ f4b6383f-5ef8-405f-b9e5-2d7163c8addb
using Test

# ╔═╡ 11130ca6-c9bc-4a93-9721-cc6da5b3a7a6
function load_data()
    readchomp(@__DIR__() * "/input.txt")
end

# ╔═╡ 0d2e35cd-5509-4694-a969-65a8e1ceb3e7
function parse_input(data)
    map(split(data, '\n')) do line
        hand, bid = split(line)
        hand, parse(Int, bid)
    end
end

# ╔═╡ 568a329c-7048-4610-a7ab-fc28207b2f72
const ORDER1 = collect("AKQJT98765432" |> reverse)

# ╔═╡ c385adc6-b5ca-4f1d-b586-3c52818c0bf3
const ORDER2 = collect("AKQT98765432J" |> reverse)

# ╔═╡ 0a388434-49d3-4ec1-becb-09412be57671
abstract type Card end

# ╔═╡ e4beffb3-e2f8-49f8-9a66-a462489fcc36
begin
    struct Card1 <: Card
        ord::Int
    end
    function Card1(s::Char)
        Card1(findfirst(ORDER1 .== s))
    end
end

# ╔═╡ 326babed-f67c-4bd1-b3ce-de5f3e8cb231
begin
    struct Card2 <: Card
        ord::Int
    end
    function Card2(s::Char)
        Card2(findfirst(ORDER2 .== s))
    end
end

# ╔═╡ c1b6567f-d4ea-44b1-b9ea-e4e269532e6e
function Base.isless(a::Card, b::Card)
    a.ord < b.ord
end

# ╔═╡ abc57308-7a86-40b3-a002-972109fa4345
@enum HandType HighCard OnePair TwoPair ThreeOfAKind FullHouse FourOfAKind FiveOfAKind

# ╔═╡ f1c3a970-387c-402d-83e3-9a01dcf432ff
function hand_type_from_counts(counts)
    if counts == [1, 1, 1, 1, 1]
        return HighCard
    elseif counts == [1, 1, 1, 2]
        return OnePair
    elseif counts == [1, 2, 2]
        return TwoPair
    elseif counts == [1, 1, 3]
        return ThreeOfAKind
    elseif counts == [2, 3]
        return FullHouse
    elseif counts == [1, 4]
        return FourOfAKind
    elseif counts == [5]
        return FiveOfAKind
    else
        error("Invalid hand: $counts")
    end
end

# ╔═╡ c9e87092-54fc-46c8-b11d-a30332e61ea4
function hand_type(cards::Vector{Card1})
    counts = countmap(cards)
    counts = counts |> values |> collect |> sort
    hand_type_from_counts(counts)
end

# ╔═╡ 34062bfb-0e93-49e4-9805-737a136409c1
function hand_type(cards::Vector{Card2})
    counts = countmap(cards)
    joker_count = get(counts, Card2('J'), 0)
    delete!(counts, Card2('J'))
    counts = counts |> values |> collect |> sort

    if joker_count == 5
        return FiveOfAKind
    else
        counts[end] += joker_count
    end

    hand_type_from_counts(counts)
end

# ╔═╡ fce9cfd5-9889-4363-8362-eb40be85d282
begin
    struct Hand{T<:Card}
        cards::Vector{T}
        hand_type::HandType
    end
    function Hand{T}(s::AbstractString) where {T<:Card}
        cards = T.(collect(s))
        Hand(cards, hand_type(cards))
    end
end

# ╔═╡ 219dc975-0918-419d-817b-e0f5f52f38ae
function Base.isless(a::Hand, b::Hand)
    if a.hand_type < b.hand_type
        return true
    elseif a.hand_type > b.hand_type
        return false
    else
        return a.cards < b.cards
    end
end

# ╔═╡ 8965a1e0-6462-4022-8d0d-81a2459965cc
function answer_(::Type{T}, input) where {T<:Card}
    parsed_input = map(input) do (hand, bid)
        Hand{T}.(hand), bid
    end
    sum(sort(parsed_input) |> enumerate) do (rank, (hand, bid))
        rank * bid
    end
end

# ╔═╡ 9d15016c-43d8-488b-82cb-fbf94affc60b
function answer1(input)
    answer_(Card1, input)
end

# ╔═╡ f2e1746e-e806-4a55-95f2-15a2c9f30079
function answer2(input)
    answer_(Card2, input)
end

# ╔═╡ ef0be634-d14f-4216-bc87-16f2981e44ef
function answer()
    data = load_data()

    input = parse_input(data)

    ans1 = answer1(input)
    ans2 = answer2(input)

    println("Answer 1 is: $ans1")
    println("Answer 2 is: $ans2")
end

# ╔═╡ 3a83dc3e-b7e0-4cbe-b864-bbffb3c73828
answer()

# ╔═╡ f86f14f2-224c-4b3d-9ac4-be0c28662958
test_input_1 = "32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483"

# ╔═╡ 8039bd1f-ef1f-421e-8997-ad35e1153253
@test answer1(test_input_1 |> parse_input) == 6440

# ╔═╡ 0efb8365-af52-4992-b1f9-bf4335455f87
@test answer2(test_input_1 |> parse_input) == 5905

# ╔═╡ Cell order:
# ╠═56ed22ce-b9ea-47b4-a51c-bf0729436496
# ╠═5d5684bd-3471-4b6a-a77f-bf9698b2215d
# ╠═11130ca6-c9bc-4a93-9721-cc6da5b3a7a6
# ╠═0d2e35cd-5509-4694-a969-65a8e1ceb3e7
# ╠═568a329c-7048-4610-a7ab-fc28207b2f72
# ╠═c385adc6-b5ca-4f1d-b586-3c52818c0bf3
# ╠═0a388434-49d3-4ec1-becb-09412be57671
# ╠═e4beffb3-e2f8-49f8-9a66-a462489fcc36
# ╠═326babed-f67c-4bd1-b3ce-de5f3e8cb231
# ╠═c1b6567f-d4ea-44b1-b9ea-e4e269532e6e
# ╠═abc57308-7a86-40b3-a002-972109fa4345
# ╠═fce9cfd5-9889-4363-8362-eb40be85d282
# ╠═f1c3a970-387c-402d-83e3-9a01dcf432ff
# ╠═c9e87092-54fc-46c8-b11d-a30332e61ea4
# ╠═34062bfb-0e93-49e4-9805-737a136409c1
# ╠═219dc975-0918-419d-817b-e0f5f52f38ae
# ╠═8965a1e0-6462-4022-8d0d-81a2459965cc
# ╠═9d15016c-43d8-488b-82cb-fbf94affc60b
# ╠═f2e1746e-e806-4a55-95f2-15a2c9f30079
# ╠═ef0be634-d14f-4216-bc87-16f2981e44ef
# ╠═3a83dc3e-b7e0-4cbe-b864-bbffb3c73828
# ╠═f4b6383f-5ef8-405f-b9e5-2d7163c8addb
# ╠═f86f14f2-224c-4b3d-9ac4-be0c28662958
# ╠═8039bd1f-ef1f-421e-8997-ad35e1153253
# ╠═0efb8365-af52-4992-b1f9-bf4335455f87
