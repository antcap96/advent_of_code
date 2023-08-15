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

    fn surrounding_points(
        &self,
        point: (usize, usize),
    ) -> impl Iterator<Item = (usize, usize)> + '_ {
        SurroundingPointsIter::new(self, point)
    }

    fn neighbors(&self, point: (usize, usize)) -> impl Iterator<Item = (usize, usize)> + '_ {
        self.surrounding_points(point)
            .filter(move |&other| self.height[point] + 1 >= self.height[other])
    }

    fn reverse_neighbors(
        &self,
        point: (usize, usize),
    ) -> impl Iterator<Item = (usize, usize)> + '_ {
        self.surrounding_points(point)
            .filter(move |&other| self.height[other] + 1 >= self.height[point])
    }
}

struct SurroundingPointsIter<'a> {
    // could just take width and height, this is just to experiment with lifetimes
    map: &'a Map,
    point: (usize, usize),
    step: usize,
}

impl<'a> SurroundingPointsIter<'a> {
    fn new(map: &'a Map, point: (usize, usize)) -> Self {
        Self {
            map,
            point,
            step: 0,
        }
    }
}

impl<'a> Iterator for SurroundingPointsIter<'a> {
    type Item = (usize, usize);

    fn next(&mut self) -> Option<Self::Item> {
        let (x, y) = self.point;
        while self.step < 4 {
            self.step += 1;
            if self.step == 1 && x > 0 {
                return Some((x - 1, y));
            }
            if self.step == 2 && y > 0 {
                return Some((x, y - 1));
            }
            if self.step == 3 && x < self.map.height.dim().0 - 1 {
                return Some((x + 1, y));
            }
            if self.step == 4 && y < self.map.height.dim().1 - 1 {
                return Some((x, y + 1));
            }
        }
        None
    }
}

pub fn answer() {
    let data =
        std::fs::read_to_string("year2022/src/day12/input.txt").expect("Unable to read file");

    let map = parse_data(&data);

    let distance = distance_start_end(&map);
    println!("Answer 1: {}", distance);

    let distance = distance_end_a(&map);
    println!("Answer 1: {}", distance);
}

fn bfs<'a, TPointIter: Iterator<Item = (usize, usize)>>(
    map: &'a Map,
    start: (usize, usize),
    get_neighbors: impl Fn(&'a Map, (usize, usize)) -> TPointIter,
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
    bfs(map, map.end, Map::reverse_neighbors, |map, point| {
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
