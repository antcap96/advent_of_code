### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ 20e4b8d2-7a85-4816-8830-e53a12a809e4
begin
    using Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
end

# ╔═╡ e2703aa6-cf42-486a-8720-659a86b3988d
using Test

# ╔═╡ e2dc3f77-514c-470d-bb18-b1f098419a79
function load_data()
    readchomp(@__DIR__() * "/input.txt")
end

# ╔═╡ f51c8758-0a8f-46bf-8e37-cabae33d6fe9
function parse_input(data)
    filter(split(data, '\n')) do line
        !isempty(line)
    end
end

# ╔═╡ 9e77fc2c-0c5d-493b-972d-704fe2583bd2
function calibration_value(line)
    first = nothing
    last = nothing
    for c in line
        if isdigit(c)
            if isnothing(first)
                first = c
            end
            last = c
        end
    end
    parse(Int, first * last)
end

# ╔═╡ 11a6392a-0901-4cf4-bf1a-1a26976eb271
function answer1(input)
    sum(calibration_value, input)
end

# ╔═╡ 10215b48-251d-411e-90b3-606a654ed99a
function spelled_out_to_digit(line)
    _replace(pair) = line -> replace(line, pair)
    (
        line
        # Keep the surrounding characters in case they are shared (eg. twone -> 21)
        |> _replace("one" => "one1one")
        |> _replace("two" => "two2two")
        |> _replace("three" => "three3three")
        |> _replace("four" => "four4four")
        |> _replace("five" => "five5five")
        |> _replace("six" => "six6six")
        |> _replace("seven" => "seven7seven")
        |> _replace("eight" => "eight8eight")
        |> _replace("nine" => "nine9nine")
    )
end

# ╔═╡ 07d43daf-bb4a-4b56-85fa-42d4b926d8d1
function answer2(input)
    sum(input) do line
        calibration_value(line |> spelled_out_to_digit)
    end
end

# ╔═╡ b34f8283-b04a-48ca-99fb-206e518f3636
function answer()
    data = load_data()

    input = parse_input(data)

    ans1 = answer1(input)
    ans2 = answer2(input)

    println("Answer 1 is: $ans1")
    println("Answer 2 is: $ans2")
end

# ╔═╡ c0e30895-221c-4394-8f9d-8f94f3bc1fad
answer()

# ╔═╡ 692bcfa9-9d92-480b-b2db-6954ad83128e
split_newline = s -> split(s, '\n')

# ╔═╡ e6a96264-4e03-4317-bcdc-0500423ee24e
test_input_1 = "1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet"

# ╔═╡ d575703f-f1fc-4e79-91c7-a8207da2e06e
test_input_2 = "two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen"

# ╔═╡ f45a77e6-8ca3-4b28-8980-1a5e1085c56c
@test answer1(test_input_1 |> parse_input) == 142

# ╔═╡ 7bd46daf-d767-420e-9530-cb69e1a61e3b
@test answer2(test_input_2 |> parse_input) == 281

# ╔═╡ Cell order:
# ╠═20e4b8d2-7a85-4816-8830-e53a12a809e4
# ╠═e2dc3f77-514c-470d-bb18-b1f098419a79
# ╠═f51c8758-0a8f-46bf-8e37-cabae33d6fe9
# ╠═9e77fc2c-0c5d-493b-972d-704fe2583bd2
# ╠═11a6392a-0901-4cf4-bf1a-1a26976eb271
# ╠═07d43daf-bb4a-4b56-85fa-42d4b926d8d1
# ╠═10215b48-251d-411e-90b3-606a654ed99a
# ╠═b34f8283-b04a-48ca-99fb-206e518f3636
# ╠═c0e30895-221c-4394-8f9d-8f94f3bc1fad
# ╠═e2703aa6-cf42-486a-8720-659a86b3988d
# ╠═692bcfa9-9d92-480b-b2db-6954ad83128e
# ╠═e6a96264-4e03-4317-bcdc-0500423ee24e
# ╠═d575703f-f1fc-4e79-91c7-a8207da2e06e
# ╠═f45a77e6-8ca3-4b28-8980-1a5e1085c56c
# ╠═7bd46daf-d767-420e-9530-cb69e1a61e3b
