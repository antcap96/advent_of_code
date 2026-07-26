app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/1.0.0/AnZoxzoGPtSGQ15EQh6pBeeaHJ7aizP9MQhK81dES3Uq.tar.zst",
	parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/1.0.2/FrnJ4RGDKpQyoDyESNoBwFNviY4ZGbMVLnUjW9tvSRjk.tar.zst",
}

import pf.Stdout
import parser.Parser
import parser.String
import "../../../inputs/2020/day3.txt" as input : Str

Row : List([Tree, Open])

Map : List(Row)

parse_row : Str -> Try(Row, _)
parse_row = |row| {
	row.to_utf8().map_try(
		|elem| {
			match elem {
				'.' => Ok(Open)
				'#' => Ok(Tree)
				_ => Err(InvalidChar(Str.from_utf8_lossy([elem])))
			}
		},
	)
}

parse_input : Str -> Try(Map, _)
parse_input = |str| {
	str.trim_end().split_on("\n").map_try(parse_row)
}

row_get : Row, U64 -> [Tree, Open]
row_get = |row, index| {
	match row.get_wrap(index) {
		Ok(result) => result
		Err(ListWasEmpty) => {
			crash "Impossible"
		}
	}
}

count_trees = |map, right, down| {
	map.iter().step_by(down).fold(
		{ index: 0, count: 0 },
		|{ index, count }, row| {
			if row_get(row, index * right) == Tree {
				{ index: index + 1, count: count + 1 }
			} else {
				{ index: index + 1, count: count }
			}
		},
	).count
	# map.fold_with_index(
	# 	{ count: 0 },
	# 	|{ count }, row, index| {
	# 		if index % down == 0
	# 			and row_get(row, index * right // down) == Tree {
	# 			{ count: count + 1 }
	# 		} else {
	# 			{ count }
	# 		}
	# 	},
	# ).count
}

calc_answer1 : Map -> U64
calc_answer1 = |map| count_trees(map, 3, 1)

calc_answer2 : Map -> U64
calc_answer2 = |map| {
	slopes = [
		(1, 1),
		(3, 1),
		(5, 1),
		(7, 1),
		(1, 2),
	]

	slopes
		.map(|(right, down)| count_trees(map, right, down))
		.fold(1, |state, x| state * x)

}

main! = |_args| {
	parsed = parse_input(input)?

	answer1 = calc_answer1(parsed)
	Stdout.line!("Answer1: ${Str.inspect(answer1)}")?

	answer2 = calc_answer2(parsed)
	Stdout.line!("Answer2: ${Str.inspect(answer2)}")?
	Ok({})
}
