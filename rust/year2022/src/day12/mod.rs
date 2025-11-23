pub mod unnecessarily_complex_version;
use std::vec;

#[derive(Clone)]
struct Map {
    height: ndarray::Array2<u32>,
    start: (usize, usize),
    end: (usize, usize),
}

impl Map {
    fn from_height(
        height: ndarray::Array2<u32>,
        start: (usize, usize),
        end: (usize, usize),
    ) -> Self {
        Self { height, start, end }
    }

    // A struct could be created to avoid allocating memory.
    fn neighbors(&self, point: (usize, usize)) -> impl Iterator<Item = (usize, usize)> {
        let (x, y) = point;
        let mut neighbors = Vec::new();
        if x > 0 && self.height[[x, y]] + 1 >= self.height[[x - 1, y]] {
            neighbors.push((x - 1, y));
        }
        if y > 0 && self.height[[x, y]] + 1 >= self.height[[x, y - 1]] {
            neighbors.push((x, y - 1));
        }
        if x < self.height.dim().0 - 1 && self.height[[x, y]] + 1 >= self.height[[x + 1, y]] {
            neighbors.push((x + 1, y));
        }
        if y < self.height.dim().1 - 1 && self.height[[x, y]] + 1 >= self.height[[x, y + 1]] {
            neighbors.push((x, y + 1));
        }
        neighbors.into_iter()
    }

    fn rev_neighbors(&self, point: (usize, usize)) -> impl Iterator<Item = (usize, usize)> {
        let (x, y) = point;
        let mut neighbors = Vec::new();
        if x > 0 && self.height[[x - 1, y]] + 1 >= self.height[[x, y]] {
            neighbors.push((x - 1, y));
        }
        if y > 0 && self.height[[x, y - 1]] + 1 >= self.height[[x, y]] {
            neighbors.push((x, y - 1));
        }
        if x < self.height.dim().0 - 1 && self.height[[x + 1, y]] + 1 >= self.height[[x, y]] {
            neighbors.push((x + 1, y));
        }
        if y < self.height.dim().1 - 1 && self.height[[x, y + 1]] + 1 >= self.height[[x, y]] {
            neighbors.push((x, y + 1));
        }
        neighbors.into_iter()
    }
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let map = parse_data(&input);

    let distance = distance_start_end(&map);
    println!("Answer 1: {}", distance);

    let distance = distance_end_a(&map);
    println!("Answer 1: {}", distance);
}

fn bfs<TPointIter: Iterator<Item = (usize, usize)>>(
    map: &Map,
    start: (usize, usize),
    get_neighbors: impl Fn(&Map, (usize, usize)) -> TPointIter,
    end_condition: impl Fn(&Map, (usize, usize)) -> bool,
) -> u32 {
    let mut to_visit = vec![start];
    let mut visited = ndarray::Array2::from_elem(map.height.dim(), false);
    visited[start] = true;

    let mut distance = 1;
    loop {
        let mut next_to_visit = Vec::new();
        for point in to_visit {
            for neighbor in get_neighbors(map, point) {
                if end_condition(map, neighbor) {
                    return distance;
                }
                if !visited[neighbor] {
                    next_to_visit.push(neighbor);
                    visited[neighbor] = true;
                }
            }
        }
        to_visit = next_to_visit;
        distance += 1;
    }
}

fn distance_start_end(map: &Map) -> u32 {
    bfs(map, map.start, Map::neighbors, |map, point| {
        point == map.end
    })
}

fn distance_end_a(map: &Map) -> u32 {
    bfs(map, map.end, Map::rev_neighbors, |map, point| {
        map.height[point] == 0
    })
}

fn parse_data(data: &str) -> Map {
    let rows = data.lines().count();
    let cols = data.lines().next().unwrap().chars().count();
    let mut start = (0, 0);
    let mut end = (0, 0);
    let mut height = ndarray::Array2::from_elem((rows, cols), 0);

    for (x, line) in data.lines().enumerate() {
        for (y, c) in line.chars().enumerate() {
            match c {
                'S' => {
                    height[[x, y]] = 0;
                    start = (x, y);
                }
                'E' => {
                    height[[x, y]] = 'z' as u32 - 'a' as u32;
                    end = (x, y);
                }
                c => {
                    height[[x, y]] = c as u32 - 'a' as u32;
                }
            }
        }
    }

    Map::from_height(height, start, end)
}
