using StatsBase

#= Data parsing =#

function load_data()
    readlines(@__DIR__() * "/input.txt")
end

function parse_input(data)
    map(filter(!isempty, data)) do line
        hand, bid = split(line)
        hand, parse(Int, bid)
    end
end

#= Shared =#

const ORDER1 = collect("AKQJT98765432" |> reverse)
const ORDER2 = collect("AKQT98765432J" |> reverse)

abstract type Card end

struct Card1 <: Card
    ord::Int
end

struct Card2 <: Card
    ord::Int
end

function Card1(s::Char)
    Card1(findfirst(ORDER1 .== s))
end

function Card2(s::Char)
    Card2(findfirst(ORDER2 .== s))
end

function Base.isless(a::Card, b::Card)
    a.ord < b.ord
end

@enum HandType HighCard OnePair TwoPair ThreeOfAKind FullHouse FourOfAKind FiveOfAKind

struct Hand{T<:Card} 
    cards::Vector{T}
    hand_type::HandType
end

function Hand{T}(s::AbstractString) where {T<:Card}
    cards = T.(collect(s))
    Hand(cards, hand_type(cards))
end


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

function hand_type(cards::Vector{Card1})
    counts = countmap(cards)
    counts = counts |> values |> collect |> sort
    hand_type_from_counts(counts)
end

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

function Base.isless(a::Hand, b::Hand)
    if a.hand_type < b.hand_type
        return true
    elseif a.hand_type > b.hand_type
        return false
    else
        return a.cards < b.cards
    end
end

function answer_(::Type{T}, input) where {T<:Card}
    parsed_input = map(input) do (hand, bid)
        Hand{T}.(hand), bid
    end
    sum(sort(parsed_input) |> enumerate) do (rank, (hand, bid))
        rank * bid
    end
end

#= Answer1 =#

function answer1(input)
    answer_(Card1, input)
end

#= Answer2 =#

function answer2(input)
    answer_(Card2, input)
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

test_input_1 = "32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
" |> split_newline

@test answer1(test_input_1 |> parse_input) == 6440

@test answer2(test_input_1 |> parse_input) == 5905
