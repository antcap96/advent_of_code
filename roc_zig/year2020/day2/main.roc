app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/1.0.0/AnZoxzoGPtSGQ15EQh6pBeeaHJ7aizP9MQhK81dES3Uq.tar.zst",
	parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/1.0.2/FrnJ4RGDKpQyoDyESNoBwFNviY4ZGbMVLnUjW9tvSRjk.tar.zst",
}

import pf.Stdout
import parser.Parser
import parser.String
import "../../../inputs/2020/day2.txt" as input : Str

Policy : { key : U8, first : U64, second : U64 }

Entry : { policy : Policy, password : Str }

policy_parser : Parser.Parser(_, Policy)
policy_parser = Parser.const(|first| |second| |key| { key, first, second })
	.keep(String.digits)
	.skip(String.string("-"))
	.keep(String.digits)
	.skip(String.string(" "))
	.keep(String.any_codeunit)

entry_parser : Parser.Parser(_, Entry)
entry_parser =
	Parser.const(|policy| |password| { policy, password })
		.keep(policy_parser)
		.skip(String.string(": "))
		.keep(String.any_string)

parse_entry : Str -> Try(Entry, Str)
parse_entry = |str|
	String.parse_str(entry_parser, str).map_err(Str.inspect)

parse_input : Str -> Try((List(Entry)), [Error(Str), ..])
parse_input = |str| {
	str.trim_end()
		.split_on("\n")
		.map_try(parse_entry)
	# We need the error in a Tag so it can be early returned in main
		.map_err(|err| Error(err))
}

calc_answer1 : List(Entry) -> U64
calc_answer1 = |entries|
	entries.count_if(
		|{ password, policy }| {
			var $count = 0
			for char in password.iter_utf8() {
				if char == policy.key {
					$count = $count + 1
				}
			}
			$count >= policy.first and $count <= policy.second
		},
	)

calc_answer2 : List(Entry) -> Try(U64, Str)
calc_answer2 = |entries| {
	pairs =
		entries.map_try(
			|{ password, policy }| {
				password_bytes = password.to_utf8()

				get_index = |idx|
					password_bytes.get(idx)
						.map_err(|_| "Failed to get index ${idx.to_str()} of '${password}'")

				first = get_index(policy.first - 1)? == policy.key
				second = get_index(policy.second - 1)? == policy.key

				Ok((first, second))
			},
		)?

	Ok(pairs.count_if(|(first, second)| first != second))
}

main! = |_args| {
	parsed = parse_input(input)?

	answer1 = calc_answer1(parsed)
	Stdout.line!("Answer1: ${Str.inspect(answer1)}")?

	answer2 = calc_answer2(parsed)
	Stdout.line!("Answer2: ${Str.inspect(answer2)}")?
	Ok({})
}
