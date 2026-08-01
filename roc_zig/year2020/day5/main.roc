app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/1.0.0/AnZoxzoGPtSGQ15EQh6pBeeaHJ7aizP9MQhK81dES3Uq.tar.zst",
}

import pf.Stdout
import "../../../inputs/2020/day5.txt" as input : Str

BoardingPass : { row : U64, col : U64 }

parse_row : List(U8) -> Try(U64, _)
parse_row = |lst| {
	var $state = 0
	for (elem, index) in lst.rev().map_with_index(|elem, index| (elem, index)) {
		match elem {
			'B' => {
				$state = $state + U64.pow(2, index)
			}
			'F' => {}
			_ => return Err(InvalidRowChar(Str.from_utf8_lossy([elem])))
		}
	}
	Ok($state)
}

parse_col : List(U8) -> Try(U64, _)
parse_col = |lst| {
	var $state = 0
	for (elem, index) in lst.rev().map_with_index(|elem, index| (elem, index)) {
		match elem {
			'R' => {
				$state = $state + U64.pow(2, index)
			}
			'L' => {}
			_ => return Err(InvalidColChar(Str.from_utf8_lossy([elem])))
		}
	}
	Ok($state)
}

parse_boarding_pass : Str -> Try(BoardingPass, _)
parse_boarding_pass = |str| {
	{ before, others } = str.to_utf8().split_at(7)
	row = parse_row(before)?
	col = parse_col(others)?
	Ok({ row, col })

}

parse_input : Str -> Try(List(BoardingPass), _)
parse_input = |str| {
	str.trim_end()
		.split_on("\n")
		.map_try(parse_boarding_pass)
}

boarding_pass_id : BoardingPass -> U64
boarding_pass_id = |pass| pass.row * 8 + pass.col

calc_answer1 : List(BoardingPass) -> Try(U64, _)
calc_answer1 = |lst| {
	lst.map(boarding_pass_id).max()
}

calc_answer2 : List(BoardingPass) -> Try(U64, _)
calc_answer2 = |lst| {
	solutions =
		neighboor_count(lst.map(boarding_pass_id))
			.keep_if(|(_, state)| state == TwoNeighboors)
			.keys()

	match solutions {
		[solution] => Ok(solution)
		_ => Err(InvalidNumberOfSolutions(solutions))
	}
}

## Keep track of how many neighboors each boardingId has, or if the seat has been seen
## already
PossibleBoardingIds : Dict(U64, [OneNeighboor, TwoNeighboors, Seen])

neighboor_count : List(U64) -> PossibleBoardingIds
neighboor_count = |boarding_passes| {
	var $candidates = Dict.empty()

	for board_id in boarding_passes {
		for neighboor in [board_id + 1, board_id - 1] {
			match $candidates.get(neighboor) {
				Err(KeyNotFound) => {
					$candidates = $candidates.insert(neighboor, OneNeighboor)
				}
				Ok(OneNeighboor) => {
					$candidates = $candidates.insert(neighboor, TwoNeighboors)
				}
				Ok(TwoNeighboors) => {
					crash "Impossible to get 3 neighboors"
				}
				Ok(Seen) => {}
			}
		}
		$candidates = $candidates.insert(board_id, Seen)
	}
	$candidates
}

main! = |_args| {
	parsed = parse_input(input)?

	answer1 = calc_answer1(parsed)
	Stdout.line!("Answer1: ${Str.inspect(answer1)}")?

	answer2 = calc_answer2(parsed)
	Stdout.line!("Answer2: ${Str.inspect(answer2)}")?
	Ok({})
}
