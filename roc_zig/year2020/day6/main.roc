app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/1.0.0/AnZoxzoGPtSGQ15EQh6pBeeaHJ7aizP9MQhK81dES3Uq.tar.zst",
}

import pf.Stdout
import "../../../inputs/2020/day6.txt" as input : Str

parse_group : Str -> List(Set(U8))
parse_group = |str| {
	str.split_on("\n").map(|row| row.to_utf8() |> Set.from_list)
}

parse_input : Str -> List(List(Set(U8)))
parse_input = |str| {
	str.trim_end().split_on("\n\n").map(parse_group)
}

set_union_cardinality : List(Set(U8)) -> U64
set_union_cardinality = |group| {
	var $set = Set.empty()
	for elem in group {
		$set = $set.union(elem)
	}
	$set.len()
}

calc_answer1 : List(List(Set(U8))) -> U64
calc_answer1 = |groups| {
	groups.map(set_union_cardinality).sum()
}

set_intersection_cardinality : List(Set(U8)) -> U64
set_intersection_cardinality = |group| {
	var $set = match group.first() {
		Ok(first) => first
		Err(ListWasEmpty) => return 0
	}

	for elem in group {
		$set = $set.intersection(elem)
	}
	$set.len()
}

calc_answer2 : List(List(Set(U8))) -> U64
calc_answer2 = |groups| {
	groups.map(set_intersection_cardinality).sum()
}

main! = |_args| {
	parsed = parse_input(input)

	answer1 = calc_answer1(parsed)
	Stdout.line!("Answer1: ${Str.inspect(answer1)}")?

	answer2 = calc_answer2(parsed)
	Stdout.line!("Answer2: ${Str.inspect(answer2)}")
}
