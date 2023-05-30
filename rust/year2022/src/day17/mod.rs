use std::collections::HashSet;

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

    fn show(&self) {
        for i in 0..self.height() {
            for j in 0..7 {
                let point = Point { x: j, y: i };
                if self.stopped_rocks.contains(&point) {
                    print!("#");
                } else {
                    print!(".");
                }
            }
            println!();
        }
        println!();
    }
}

fn fall_piece<'a>(
    chamber: &mut Chamber,
    piece: &Piece,
    jet_stream: &mut impl Iterator<Item = &'a Direction>,
) {
    let position = chamber.start_position();
    let start_y = position.y;

    let mut falling_piece = FallingPiece { piece, position };

    for direction in jet_stream {
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
            break;
        }
    }
    for point in falling_piece.iter_points() {
        chamber.stopped_rocks.insert(point);
    }

    if falling_piece.piece.points.contains(&Offset { x: 3, y: 0 }) {
        dbg!(start_y - falling_piece.iter_points().map(|x| x.y).min().unwrap_or(0));
    }
}

pub fn answer() {
    let data =
        std::fs::read_to_string("year2022/src/day17/input.txt").expect("Failed to read file");

    let jet_stream = parse_data(&data);
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

    let pieces_iter = pieces.iter().cycle().take(2022);
    let mut jet_stream_iter = jet_stream.iter().cycle();

    let mut chamber = Chamber {
        stopped_rocks: HashSet::new(),
    };

    for piece in pieces_iter {
        fall_piece(&mut chamber, piece, &mut jet_stream_iter)
    }
    println!("The height of the chamber is {}", chamber.height());
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
