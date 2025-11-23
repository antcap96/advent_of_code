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

struct SearchArea {
    min: Point,
    max: Point,
    cubes: HashSet<Cube>,
}

impl SearchArea {
    fn find_outside_faces(&self) -> HashSet<Face> {
        let mut faces = HashSet::new();
        let mut queue = vec![self.max.clone()];
        let mut visited: HashSet<Point> = [self.max.clone()].into_iter().collect();

        while let Some(point) = queue.pop() {
            let cube = Cube { location: point };

            if !self.cubes.contains(&cube) {
                for face in cube.faces() {
                    faces.insert(face);
                }
                for neighbor in cube.neighbors() {
                    if !visited.contains(&neighbor)
                        && neighbor.x <= self.max.x
                        && neighbor.y <= self.max.y
                        && neighbor.z <= self.max.z
                        && neighbor.x >= self.min.x
                        && neighbor.y >= self.min.y
                        && neighbor.z >= self.min.z
                    {
                        visited.insert(neighbor.clone());
                        queue.push(neighbor);
                    }
                }
            }
        }

        faces
    }
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let cubes = parse_data(&input);

    let faces = find_faces_count(&cubes);
    let unpaired_faces = faces.iter().filter(|(_, &count)| count == 1);
    let answer1 = unpaired_faces.clone().count();

    println!("Answer1: {}", answer1);

    let outside_faces = find_outside_faces(cubes);

    let answer2 = unpaired_faces
        .filter(|(face, _)| outside_faces.contains(face))
        .count();

    println!("Answer2: {:?}", answer2);
}

fn find_outside_faces(cubes: HashSet<Cube>) -> HashSet<Face> {
    let min_x = cubes.iter().map(|cube| cube.location.x).min().unwrap();
    let max_x = cubes.iter().map(|cube| cube.location.x).max().unwrap();
    let min_y = cubes.iter().map(|cube| cube.location.y).min().unwrap();
    let max_y = cubes.iter().map(|cube| cube.location.y).max().unwrap();
    let min_z = cubes.iter().map(|cube| cube.location.z).min().unwrap();
    let max_z = cubes.iter().map(|cube| cube.location.z).max().unwrap();

    let search_area = SearchArea {
        min: Point {
            x: min_x - 1,
            y: min_y - 1,
            z: min_z - 1,
        },
        max: Point {
            x: max_x + 1,
            y: max_y + 1,
            z: max_z + 1,
        },
        cubes,
    };

    search_area.find_outside_faces()
}

fn find_faces_count(cubes: &HashSet<Cube>) -> HashMap<Face, i32> {
    let mut faces = HashMap::new();

    for cube in cubes {
        for face in cube.faces() {
            *faces.entry(face).or_insert(0) += 1;
        }
    }

    faces
}

fn parse_data(data: &str) -> HashSet<Cube> {
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
