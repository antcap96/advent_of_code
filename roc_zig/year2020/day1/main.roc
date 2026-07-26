app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/1.0.0/AnZoxzoGPtSGQ15EQh6pBeeaHJ7aizP9MQhK81dES3Uq.tar.zst",
}

import pf.Stdout
import "../../../inputs/2020/day1.txt" as input : Str

parse_data : Str -> Try(Set, _)
parse_data = |data| {
	data.trim_end()
		.split_on("\n")
		.map_try(|line| I64.from_str(line).map_err(|_| BadNum("bad num {line}")))?
		->Set.from_list()
		->Ok
}

entries_product : Set(I64), I64, I64 -> [Found(I64), NotFound]
entries_product = |numbers, total, count| {
	if count == 1 {
		if numbers.contains(total) {
			return Found(total)
		} else {
			return NotFound
		}
	}

	for el in numbers.to_list() {
		match entries_product(numbers, total - el, count - 1) {
			Found(num) => return Found(el * num)
			NotFound => {}
		}
	}
	NotFound
}

calc_answer1 : Set(I64) -> Try(I64, [NotFound])
calc_answer1 = |numbers| {
	match entries_product(numbers, 2020, 2) {
		Found(num) => Ok(num)
		NotFound => Err(NotFound)
	}
}

calc_answer2 : Set(I64) -> Try(I64, [NotFound])
calc_answer2 = |numbers| {
	match entries_product(numbers, 2020, 3) {
		Found(num) => Ok(num)
		NotFound => Err(NotFound)
	}
}

main! = |_args| {
	parsed = parse_data(input)?

	answer1 = calc_answer1(parsed)
	Stdout.line!("Answer1: ${Str.inspect(answer1)}")?

	answer2 = calc_answer2(parsed)
	Stdout.line!("Answer2: ${Str.inspect(answer2)}")?
	Ok({})
}
