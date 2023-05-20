use std::str::FromStr;

#[derive(Clone)]
enum Direction {
    Up,
    Right,
    Down,
    Left,
}

impl FromStr for Direction {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "U" => Ok(Direction::Up),
            "R" => Ok(Direction::Right),
            "D" => Ok(Direction::Down),
            "L" => Ok(Direction::Left),
            _ => Err(()),
        }
    }
}

#[derive(Debug, Hash, Eq, PartialEq, Clone)]
struct Point {
    x: i32,
    y: i32,
}

impl Point {
    fn distance(&self, other: &Point) -> Point {
        Point {
            x: self.x - other.x,
            y: self.y - other.y,
        }
    }
}

#[derive(Debug)]
struct Rope<const N: usize> {
    knots: [Point; N],
}

impl<const N: usize> Rope<N> {
    fn head_mut(&mut self) -> &mut Point {
        &mut self.knots[0]
    }

    fn tail(&self) -> &Point {
        &self.knots[N - 1]
    }

    fn move_head(&mut self, direction: &Direction) {
        match direction {
            Direction::Up => self.head_mut().y += 1,
            Direction::Right => self.head_mut().x += 1,
            Direction::Down => self.head_mut().y -= 1,
            Direction::Left => self.head_mut().x -= 1,
        }

        for i in 0..(N - 1) {
            let distance = self.knots[i].distance(&self.knots[i + 1]);

            // Needs to move knot
            if distance.x.abs() > 1 || distance.y.abs() > 1 {
                self.knots[i + 1].x += distance.x.signum();
                self.knots[i + 1].y += distance.y.signum();
            }
        }
    }

    fn perform_movements(&mut self, movements: &[Direction]) -> std::collections::HashSet<Point> {
        let mut visited = std::collections::HashSet::new();
        for movement in movements {
            self.move_head(movement);
            // This clones tail even if tail is already in visited. Couldn't
            // figure out how to avoid this clone without hashing tail twice.
            visited.insert(self.tail().clone());
        }
        visited
    }
}

pub fn answer() {
    let data = std::fs::read_to_string("year2022/src/day9/input.txt").expect("Unable to read file");

    let movements = parse_data(&data);

    let mut rope1 = Rope {
        // using map because array constructor requires Copy trait
        knots: [(); 2].map(|_| Point { x: 0, y: 0 }),
    };

    let visited = rope1.perform_movements(&movements);
    println!("Answer 1: {}", visited.len());

    let mut rope2 = Rope {
        // using map because array constructor requires Copy trait
        knots: [(); 10].map(|_| Point { x: 0, y: 0 }),
    };

    let visited = rope2.perform_movements(&movements);
    println!("Answer 2: {}", visited.len());
}

fn parse_data(data: &str) -> Vec<Direction> {
    data.lines()
        .flat_map(|line| {
            let mut iter = line.split_whitespace();
            let dir = iter.next().unwrap().parse::<Direction>().unwrap();
            let amount = iter.next().unwrap().parse::<usize>().unwrap();
            std::iter::repeat(dir).take(amount)
        })
        .collect()
}
