use std::collections::HashSet;

use itertools::Itertools;

const SAND_START: (i32, i32) = (500, 0);

struct Puzzle {
    solid: HashSet<(i32, i32)>,
    active_sand: (i32, i32),
    max_height: i32,
}

pub fn answer() {
    let data = include_str!("input.txt");

    let puzzle = parse_data(data);

    let answers = simulate_sand_falling(puzzle);

    println!("Answer 1: {}", answers.0);
    println!("Answer 2: {}", answers.1);
}

fn simulate_sand_falling(puzzle: Puzzle) -> (u32, u32) {
    let mut active_sand = puzzle.active_sand;
    let mut solid = puzzle.solid;
    let mut total_sand = 0;
    let mut answer1: Option<u32> = None;

    while !solid.contains(&SAND_START) {
        while active_sand.1 < puzzle.max_height {
            let (x, y) = active_sand;
            if !solid.contains(&(x, y + 1)) {
                active_sand = (x, y + 1);
            } else if !solid.contains(&(x - 1, y + 1)) {
                active_sand = (x - 1, y + 1);
            } else if !solid.contains(&(x + 1, y + 1)) {
                active_sand = (x + 1, y + 1);
            } else {
                break;
            }
        }
        if active_sand.1 == puzzle.max_height && answer1.is_none() {
            answer1 = Some(total_sand);
        }

        eprintln!("Solidifying at {:?}", active_sand);
        solid.insert(active_sand);
        active_sand = SAND_START;
        total_sand += 1;
    }

    (answer1.unwrap(), total_sand)
}

fn parse_data(data: &str) -> Puzzle {
    let paths = data.lines().map(|line| {
        line.split("->").map(|part| {
            let Some((x, y)) = part.trim().split(',').collect_tuple() else {
                panic!("Invalid input")
            };
            let x = x.parse::<i32>().unwrap();
            let y = y.parse::<i32>().unwrap();
            (x, y)
        })
    });

    let max_height = paths
        .clone()
        .map(|path| path.map(|(_, y)| y).max().unwrap())
        .max()
        .unwrap()
        + 1;

    let mut solid = HashSet::new();

    for path in paths {
        path.tuple_windows().for_each(|((x1, y1), (x2, y2))| {
            if x1 != x2 {
                for x in std::cmp::min(x1, x2)..=std::cmp::max(x1, x2) {
                    solid.insert((x, y1));
                }
            } else {
                for y in std::cmp::min(y1, y2)..=std::cmp::max(y1, y2) {
                    solid.insert((x1, y));
                }
            }
        });
    }

    Puzzle {
        solid,
        active_sand: SAND_START,
        max_height,
    }
}
