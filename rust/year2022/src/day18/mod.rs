use std::collections::{HashMap, HashSet};

#[derive(Clone, Hash, Eq, PartialEq, Debug)]
struct Point {
    x: i32,
    y: i32,
    z: i32,
}

#[derive(Clone, Hash, Eq, PartialEq)]
struct Cube {
    location: Point,
}

impl Cube {
    fn faces(&self) -> impl Iterator<Item = Face> + '_ {
        (0..6).map(|idx| match idx {
            0 => Face {
                location: Point {
                    x: self.location.x,
                    y: self.location.y,
                    z: self.location.z,
                },
                direction: Direction::X,
            },
            1 => Face {
                location: Point {
                    x: self.location.x,
                    y: self.location.y,
                    z: self.location.z,
                },
                direction: Direction::Y,
            },
            2 => Face {
                location: Point {
                    x: self.location.x,
                    y: self.location.y,
                    z: self.location.z,
                },
                direction: Direction::Z,
            },
            3 => Face {
                location: Point {
                    x: self.location.x + 1,
                    y: self.location.y,
                    z: self.location.z,
                },
                direction: Direction::X,
            },
            4 => Face {
                location: Point {
                    x: self.location.x,
                    y: self.location.y + 1,
                    z: self.location.z,
                },
                direction: Direction::Y,
            },
            5 => Face {
                location: Point {
                    x: self.location.x,
                    y: self.location.y,
                    z: self.location.z + 1,
                },
                direction: Direction::Z,
            },
            _ => unreachable!(),
        })
    }

    fn neighbors(&self) -> impl Iterator<Item = Point> + '_ {
        (0..6).map(move |idx| match idx {
            0 => Point {
                x: self.location.x - 1,
                y: self.location.y,
                z: self.location.z,
            },

            1 => Point {
                x: self.location.x + 1,
                y: self.location.y,
                z: self.location.z,
            },

            2 => Point {
                x: self.location.x,
                y: self.location.y - 1,
                z: self.location.z,
            },

            3 => Point {
                x: self.location.x,
                y: self.location.y + 1,
                z: self.location.z,
            },

            4 => Point {
                x: self.location.x,
                y: self.location.y,
                z: self.location.z - 1,
            },

            5 => Point {
                x: self.location.x,
                y: self.location.y,
                z: self.location.z + 1,
            },
            _ => unreachable!(),
        })
    }
}

#[derive(Hash, Eq, PartialEq, Debug)]
enum Direction {
    X,
    Y,
    Z,
}

#[derive(Hash, Eq, PartialEq, Debug)]
struct Face {
    location: Point,
    direction: Direction,
}

fn flood(cubes: HashSet<Cube>, max: Point) -> HashSet<Face> {
    let start = max.clone();
    let mut faces = HashSet::new();
    let mut queue = vec![start.clone()];
    let mut visited: HashSet<Point> = [start].into_iter().collect();

    while let Some(point) = queue.pop() {
        let cube = Cube { location: point };

        if !cubes.contains(&cube) {
            for face in cube.faces() {
                faces.insert(face);
            }
            for neighbor in cube.neighbors() {
                if !visited.contains(&neighbor)
                    && neighbor.x <= max.x
                    && neighbor.y <= max.y
                    && neighbor.z <= max.z
                    && neighbor.x >= -1
                    && neighbor.y >= -1
                    && neighbor.z >= -1
                {
                    visited.insert(neighbor.clone());
                    queue.push(neighbor);
                }
            }
        }
    }

    faces
}

pub fn answer() {
    let data =
        std::fs::read_to_string("year2022/src/day18/input.txt").expect("Failed to read file");

    let cubes = parse_data(&data);
    let min_x = cubes.iter().map(|cube| cube.location.x).min().unwrap();
    let max_x = cubes.iter().map(|cube| cube.location.x).max().unwrap();
    let min_y = cubes.iter().map(|cube| cube.location.y).min().unwrap();
    let max_y = cubes.iter().map(|cube| cube.location.y).max().unwrap();
    let min_z = cubes.iter().map(|cube| cube.location.z).min().unwrap();
    let max_z = cubes.iter().map(|cube| cube.location.z).max().unwrap();

    let mut faces = HashMap::new();

    for cube in &cubes {
        for face in cube.faces() {
            *faces.entry(face).or_insert(0) += 1;
        }
    }

    let unpaired_faces = faces.iter().filter(|(_, &count)| count == 1);
    let answer1 = unpaired_faces.clone().count();

    println!("Answer1: {}", answer1);

    let outside_faces = flood(
        cubes.into_iter().collect(),
        Point {
            x: max_x + 1,
            y: max_y + 1,
            z: max_z + 1,
        },
    );

    let answer2 = unpaired_faces.filter(|(face, _)| outside_faces.contains(face)).count();

    println!("Answer2: {:?}", answer2);
}

fn parse_data(data: &str) -> Vec<Cube> {
    data.lines()
        .map(|line| {
            let mut numbers = line.split(',');
            let x = numbers.next().unwrap().parse().unwrap();
            let y = numbers.next().unwrap().parse().unwrap();
            let z = numbers.next().unwrap().parse().unwrap();
            Cube {
                location: Point { x, y, z },
            }
        })
        .collect()
}
