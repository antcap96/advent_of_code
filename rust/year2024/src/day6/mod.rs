use std::collections::HashSet;

use ndarray;

#[derive(Clone, Copy)]
enum Cell {
    Floor,
    Obstruction,
}

struct Data {
    map: ndarray::Array2<Cell>,
    starting_position: (usize, usize),
}

#[derive(Clone, Copy, Eq, PartialEq, Hash, Debug)]
enum Direction {
    North,
    East,
    South,
    West,
}
impl Direction {
    fn rotate(&self) -> Self {
        match self {
            Direction::North => Direction::East,
            Direction::East => Direction::South,
            Direction::South => Direction::West,
            Direction::West => Direction::North,
        }
    }
}

#[derive(Clone, Eq, Hash, PartialEq, Debug)]
struct State {
    position: (usize, usize),
    direction: Direction,
}

impl State {
    fn rotate(&self) -> Self {
        State {
            position: self.position,
            direction: self.direction.rotate(),
        }
    }

    fn next_position(&self) -> (usize, usize) {
        match self.direction {
            Direction::North => (self.position.0.wrapping_sub(1), self.position.1),
            Direction::East => (self.position.0, self.position.1.wrapping_add(1)),
            Direction::South => (self.position.0.wrapping_add(1), self.position.1),
            Direction::West => (self.position.0, self.position.1.wrapping_sub(1)),
        }
    }
}

fn parse_input(input: &str) -> Data {
    let cols = input.lines().next().unwrap().len();
    let mut starting_position = (0, 0);
    let test = input
        .lines()
        .enumerate()
        .flat_map(|(i, line)| {
            line.chars()
                .enumerate()
                .map(|(j, c)| match c {
                    '#' => Cell::Obstruction,
                    '^' => {
                        starting_position = (i, j);
                        Cell::Floor
                    }
                    '.' => Cell::Floor,
                    _ => panic!("unexpected char {}", c),
                })
                .collect::<Vec<_>>()
        })
        .collect::<Vec<_>>();

    let map = ndarray::Array2::from_shape_vec((test.len() / cols, cols), test).unwrap();

    Data {
        map,
        starting_position,
    }
}

fn step(map: &ndarray::Array2<Cell>, state: &State) -> Option<State> {
    let try_position = state.next_position();

    match map.get(try_position) {
        None => None,
        Some(Cell::Floor) => Some(State {
            position: try_position,
            direction: state.direction,
        }),
        Some(Cell::Obstruction) => Some(state.rotate()),
    }
}

fn answer1(data: &Data) -> usize {
    let mut visited = HashSet::new();

    let mut maybe_state = Some(State {
        position: data.starting_position,
        direction: Direction::North,
    });
    while let Some(state) = maybe_state {
        visited.insert(state.position);
        maybe_state = step(&data.map, &state)
    }

    visited.len()
}

fn is_loop_with_obstacle(
    map: &mut ndarray::Array2<Cell>,
    starting_state: State,
    starting_visited: &HashSet<State>,
) -> bool {
    let next_position = starting_state.next_position();
    let before = *map.get(next_position).unwrap();
    map.get_mut(next_position).map(|x| *x = Cell::Obstruction);

    let mut visited = starting_visited.clone();
    let mut maybe_state = Some(starting_state);
    let mut looped = false;
    while let Some(state) = maybe_state {
        if visited.contains(&state) {
            looped = true;
            break;
        }
        maybe_state = step(map, &state);
        visited.insert(state);
    }

    map.get_mut(next_position).map(|x| *x = before);

    looped
}

fn answer2(data: &mut Data) -> usize {
    let mut visited_positions = HashSet::new();
    let mut visited_states = HashSet::new();
    let mut count = 0;

    let mut maybe_state = Some(State {
        position: data.starting_position,
        direction: Direction::North,
    });

    while let Some(state) = maybe_state {
        visited_positions.insert(state.position);
        let next_position = state.next_position();
        if let Some(Cell::Floor) = data.map.get(next_position) {
            if !visited_positions.contains(&next_position)
                && is_loop_with_obstacle(&mut data.map, state.clone(), &visited_states)
            {
                count += 1
            }
        }

        maybe_state = step(&data.map, &state);
        visited_states.insert(state);
    }

    count
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let mut data = parse_input(&input);

    let ans1 = answer1(&data);
    println!("answer1: {}", ans1);

    let ans2 = answer2(&mut data);
    println!("answer2: {}", ans2);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test1() {
        let input = include_str!("test.txt");

        assert_eq!(answer1(&parse_input(input)), 41);
    }

    #[test]
    fn test2() {
        let input = include_str!("test.txt");

        assert_eq!(answer2(&mut parse_input(input)), 6);
    }
}
