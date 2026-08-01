app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/1.0.0/AnZoxzoGPtSGQ15EQh6pBeeaHJ7aizP9MQhK81dES3Uq.tar.zst",
}

import pf.Stdout
import "../../../inputs/2020/day4.txt" as input : Str

MaybeField : [With(Str), Missing]

maybe_field_from_result = |res| {
	match res {
		Ok(ok) => With(ok)
		Err(_) => Missing
	}
}

Passport := {
	byr : MaybeField,
	iyr : MaybeField,
	eyr : MaybeField,
	hgt : MaybeField,
	hcl : MaybeField,
	ecl : MaybeField,
	pid : MaybeField,
	cid : MaybeField,
}.{
	from_dict : Dict(Str, Str) -> Passport
	from_dict = |dict| {
		{
			byr: dict.get("byr") |> maybe_field_from_result,
			iyr: dict.get("iyr") |> maybe_field_from_result,
			eyr: dict.get("eyr") |> maybe_field_from_result,
			hgt: dict.get("hgt") |> maybe_field_from_result,
			hcl: dict.get("hcl") |> maybe_field_from_result,
			ecl: dict.get("ecl") |> maybe_field_from_result,
			pid: dict.get("pid") |> maybe_field_from_result,
			cid: dict.get("cid") |> maybe_field_from_result,
		}
	}
	parse : Str -> Try(Passport, _)
	parse = |str| {
		str.replace_each("\n", " ")
			.split_on(" ")
			.map_try(
				|field| match field.split_first(":") {
					Ok({ before, after }) => Ok((before, after))
					Err(NotFound) => Err(MissingColonIn(field))
				},
			)?
			|> Dict.from_list
			|> Passport.from_dict
			|> Ok
	}

}

parse_input : Str -> Try(List(Passport), _)
parse_input = |str| {
	str.trim_end().split_on("\n\n").map_try(Passport.parse)
}

calc_answer1 : List(Passport) -> U64
calc_answer1 = |list| {
	list.count_if(
		|passport|
			match passport {
				{
					byr: With(_),
					iyr: With(_),
					eyr: With(_),
					hgt: With(_),
					hcl: With(_),
					ecl: With(_),
					pid: With(_),
					cid: _,
				} => True
				_ => False
			},
	)
}

num_between = |str, low, high| {
	match U16.from_str(str) {
		Ok(num) => num >= low and num <= high
		_ => False
	}
}

height_check = |str| {
	if str.ends_with("cm") {
		num_between(str.drop_suffix("cm"), 150, 193)
	} else if str.ends_with("in") {
		num_between(str.drop_suffix("in"), 59, 76)
	} else {
		False
	}
}

hex_color_check = |str| {
	str.starts_with("#") and
		(str.to_utf8().len() == 7) and
			str.drop_prefix("#").to_utf8().all(|elem| (elem >= '0' and elem <= '9') or (elem >= 'a' and elem <= 'f'))
}

eye_color_check = |str|
	match str {
		"amb" | "blu" | "brn" | "gry" | "grn" | "hzl" | "oth" => True
		_ => False
	}

id_check = |str| {
	str.to_utf8().len() == 9 and
		str.to_utf8().all(|elem| (elem >= '0' and elem <= '9'))
}

is_valid2_elements : Passport -> List(Bool)
is_valid2_elements = |passport|
	match passport {
		{
			byr: With(byr),
			iyr: With(iyr),
			eyr: With(eyr),
			hgt: With(hgt),
			hcl: With(hcl),
			ecl: With(ecl),
			pid: With(pid),
			cid: _,
		} =>
			[
				num_between(byr, 1920, 2002),
				num_between(iyr, 2010, 2020),
				num_between(eyr, 2020, 2030),
				height_check(hgt),
				hex_color_check(hcl),
				eye_color_check(ecl),
				id_check(pid),
			]
		_ => [False]
	}

is_valid2 : Passport -> Bool
is_valid2 = |passport|
	is_valid2_elements(passport).all(|x| x)

calc_answer2 : List(Passport) -> U64
calc_answer2 = |list|
	list.count_if(is_valid2)

main! = |_args| {
	parsed = parse_input(input)?

	answer1 = calc_answer1(parsed)
	Stdout.line!("Answer1: ${Str.inspect(answer1)}")?

	answer2 = calc_answer2(parsed)
	Stdout.line!("Answer2: ${Str.inspect(answer2)}")?
	Ok({})
}
