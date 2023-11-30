use std::collections::HashSet;

#[must_use = "iterator adaptors are lazy and do nothing unless consumed"]
struct CycleEnumerate<I> {
    orig: I,
    iter: I,
    count: usize,
}

impl<I: Iterator + Clone> Iterator for CycleEnumerate<I> {
    type Item = (usize, <I as Iterator>::Item);

    fn next(&mut self) -> Option<Self::Item> {
        match self.iter.next() {
            None => {
                self.iter = self.orig.clone();
                self.count += 1;
                self.iter.next().map(|x| (self.count, x))
            }
            y => y.map(|x| (self.count, x)),
        }
    }
}

trait CycleEnumerateExt: Iterator + Sized {
    fn cycle_enumerate(self) -> CycleEnumerate<Self>;
}

impl<I: Iterator + Clone> CycleEnumerateExt for I {
    fn cycle_enumerate(self) -> CycleEnumerate<I> {
        CycleEnumerate {
            orig: self.clone(),
            iter: self,
            count: 0,
        }
    }
}

#[derive(Debug)]
enum Direction {
    Left,
    Right,
}

impl Direction {
    fn as_offset(&self) -> Offset {
        match self {
            Direction::Left => Offset { x: -1, y: 0 },
            Direction::Right => Offset { x: 1, y: 0 },
        }
    }
}

#[derive(Debug, Eq, Hash, PartialEq)]
struct Point {
    x: i32,
    y: i32,
}

impl Point {
    fn add(&self, offset: &Offset) -> Point {
        Point {
            x: self.x + offset.x,
            y: self.y + offset.y,
        }
    }
}

#[derive(PartialEq, Eq)]
struct Offset {
    x: i32,
    y: i32,
}

struct Piece {
    points: Vec<Offset>,
}

struct FallingPiece<'a> {
    piece: &'a Piece,
    position: Point,
}

impl<'a> FallingPiece<'a> {
    fn iter_points(&'a self) -> impl Iterator<Item = Point> + 'a {
        self.piece
            .points
            .iter()
            .map(|offset| self.position.add(offset))
    }
}

struct Chamber {
    stopped_rocks: HashSet<Point>,
}

impl Chamber {
    fn available(&self, point: &Point) -> bool {
        !self.stopped_rocks.contains(point) && point.y >= 0 && point.x < 7 && point.x >= 0
    }

    fn start_position(&self) -> Point {
        let height = self.height();
        Point {
            x: 2,
            y: height + 3,
        }
    }

    fn height(&self) -> i32 {
        self.stopped_rocks
            .iter()
            .map(|p| p.y)
            .max()
            .map(|y| y + 1)
            .unwrap_or(0)
    }
}

struct Answer {
    init: Vec<i64>,
    cycle: Vec<i64>,
}

impl Answer {
    fn new(mut heights: Vec<Vec<i64>>) -> Answer {
        heights.pop();
        let mut cycle = heights.pop().unwrap();
        let min = *cycle.iter().min().unwrap();
        cycle.iter_mut().for_each(|x| *x -= min);

        let init = heights.into_iter().flatten().collect::<Vec<_>>();

        Answer { init, cycle }
    }

    fn of(&self, n_rocks: i64) -> i64 {
        if n_rocks < self.init.len() as i64 {
            self.init[n_rocks as usize]
        } else {
            let cycle_len = self.cycle.len() as i64 - 1;
            let init_len = self.init.len() - 1;
            let cycle_idx = (n_rocks - init_len as i64) % cycle_len;
            let cycle_n = (n_rocks - init_len as i64) / cycle_len;
            self.init.last().unwrap()
                + self.cycle[cycle_idx as usize]
                + cycle_n * self.cycle.last().unwrap()
        }
    }
}

fn find_pattern(mut chamber: Chamber, pieces: &[Piece], jet_stream: &[Direction]) -> Answer {
    // [cycle][index]
    let mut heights: Vec<Vec<i64>> = vec![vec![0]];

    let mut jet_stream_iter = jet_stream.iter().cycle_enumerate();
    let piece_iter = pieces.iter().cycle();

    for piece in piece_iter {
        let position = chamber.start_position();

        let mut falling_piece = FallingPiece { piece, position };

        let mut end_idx = 0;
        for (i, direction) in &mut jet_stream_iter {
            // go left or right
            let next_position = falling_piece.position.add(&direction.as_offset());

            let next_falling_piece = FallingPiece {
                piece: falling_piece.piece,
                position: next_position,
            };

            if next_falling_piece
                .iter_points()
                .all(|p| chamber.available(&p))
            {
                falling_piece = next_falling_piece;
            }

            // go down
            let next_position = falling_piece.position.add(&Offset { x: 0, y: -1 });

            let next_falling_piece = FallingPiece {
                piece: falling_piece.piece,
                position: next_position,
            };

            if next_falling_piece
                .iter_points()
                .all(|p| chamber.available(&p))
            {
                falling_piece = next_falling_piece;
            } else {
                end_idx = i;
                break;
            }
        }

        for point in falling_piece.iter_points() {
            chamber.stopped_rocks.insert(point);
        }

        if end_idx >= heights.len() {
            if heights.len() >= 2 {
                let last = &heights[end_idx - 1];
                let last_min = *last.iter().min().unwrap();
                let last = last.iter().map(|x| x - last_min).collect::<Vec<_>>();
                let prev_last = &heights[end_idx - 2];
                let prev_last_min = *prev_last.iter().min().unwrap();
                let prev_last = prev_last
                    .iter()
                    .map(|x| x - prev_last_min)
                    .collect::<Vec<_>>();

                dbg!(last.last());
                dbg!(prev_last.last());
                if last == prev_last {
                    break;
                }
            }
            heights.push(vec![
                *heights[end_idx - 1].last().unwrap(),
                chamber.height() as i64,
            ]);
        } else {
            heights[end_idx].push(chamber.height() as i64);
        }
    }
    Answer::new(heights)
}

pub fn answer() {
    let data = include_str!("input.txt");

    let jet_stream = parse_data(data);
    let pieces = build_pieces();
    let chamber = Chamber {
        stopped_rocks: HashSet::new(),
    };

    let answer = find_pattern(chamber, &pieces, &jet_stream);

    println!("Answer1: {}", answer.of(2022));
    println!("Answer1: {}", answer.of(1000000000000));
}

fn build_pieces() -> Vec<Piece> {
    let pieces = vec![
        Piece {
            points: vec![
                Offset { x: 0, y: 0 },
                Offset { x: 1, y: 0 },
                Offset { x: 2, y: 0 },
                Offset { x: 3, y: 0 },
            ],
        },
        Piece {
            points: vec![
                Offset { x: 1, y: 0 },
                Offset { x: 0, y: 1 },
                Offset { x: 1, y: 1 },
                Offset { x: 2, y: 1 },
                Offset { x: 1, y: 2 },
            ],
        },
        Piece {
            points: vec![
                Offset { x: 0, y: 0 },
                Offset { x: 1, y: 0 },
                Offset { x: 2, y: 0 },
                Offset { x: 2, y: 1 },
                Offset { x: 2, y: 2 },
            ],
        },
        Piece {
            points: vec![
                Offset { x: 0, y: 0 },
                Offset { x: 0, y: 1 },
                Offset { x: 0, y: 2 },
                Offset { x: 0, y: 3 },
            ],
        },
        Piece {
            points: vec![
                Offset { x: 0, y: 0 },
                Offset { x: 0, y: 1 },
                Offset { x: 1, y: 0 },
                Offset { x: 1, y: 1 },
            ],
        },
    ];
    pieces
}

fn parse_data(data: &str) -> Vec<Direction> {
    data.trim()
        .chars()
        .map(|c| match c {
            '<' => Direction::Left,
            '>' => Direction::Right,
            _ => panic!("Unexpected character"),
        })
        .collect()
}

// Failing
#[test]
fn test1() {
    let jet_stream = parse_data(">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>");
    let pieces = build_pieces();
    let chamber = Chamber {
        stopped_rocks: HashSet::new(),
    };

    let answer = find_pattern(chamber, &pieces, &jet_stream);

    assert!(answer.of(2022) == 3068);
    assert!(answer.of(1000000000000) == 1514285714288);
}
