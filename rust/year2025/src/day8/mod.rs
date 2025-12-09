use std::collections::{HashMap, HashSet};

use itertools::Itertools;

struct Point {
    x: usize,
    y: usize,
    z: usize,
}

impl Point {
    fn distance_squared(&self, other: &Point) -> usize {
        (self.x.abs_diff(other.x)).pow(2)
            + (self.y.abs_diff(other.y)).pow(2)
            + (self.z.abs_diff(other.z)).pow(2)
    }
}

struct Data {
    points: Box<[Point]>,
}

struct SetMap {
    set_map: Vec<usize>,
    sets: HashMap<usize, HashSet<usize>>,
}

impl SetMap {
    fn new(elements: usize) -> Self {
        let set_map = (0..elements).collect::<Vec<_>>();
        let sets =
            HashMap::from_iter((0..elements).map(|x| (x, HashSet::from_iter(std::iter::once(x)))));
        Self { set_map, sets }
    }

    fn pair_points(&mut self, point1: usize, point2: usize) {
        if self.set_map[point1] == self.set_map[point2] {
            return;
        }
        let set1 = self.set_map[point1];
        let set2 = self.set_map[point2];
        let min = set1.min(set2);
        let max = set1.max(set2);
        for i in self.sets[&max].iter() {
            self.set_map[*i] = min;
        }

        let dropped_set = self.sets.remove(&max).unwrap();
        self.sets.entry(min).and_modify(|f| f.extend(&dropped_set));
    }

    fn set(&self, point: usize) -> &HashSet<usize> {
        &self.sets[&self.set_map[point]]
    }
}

fn sorted_pairs(data: &Data) -> Vec<(usize, usize, usize)> {
    let indexes = 0..data.points.len();
    let mut pairs = indexes
        .clone()
        .cartesian_product(indexes)
        .filter(|(idx1, idx2)| idx1 < idx2)
        .map(|(idx1, idx2)| {
            (
                idx1,
                idx2,
                data.points[idx1].distance_squared(&data.points[idx2]),
            )
        })
        .collect::<Vec<_>>();
    pairs.sort_unstable_by_key(|(_, _, d)| *d);
    pairs
}

fn answer1_aux(data: &Data, n_pairs: usize) -> usize {
    let mut sets = SetMap::new(data.points.len());
    let pairs = sorted_pairs(data);

    for (point1, point2, _) in pairs.into_iter().take(n_pairs) {
        sets.pair_points(point1, point2);
    }

    sets.sets
        .values()
        .map(|set| set.len())
        .sorted_unstable_by(|x, y| y.cmp(x))
        .take(3)
        .product()
}

fn answer1(data: &Data) -> usize {
    answer1_aux(data, 1000)
}

fn answer2(data: &Data) -> usize {
    let mut sets = SetMap::new(data.points.len());
    let pairs = sorted_pairs(data);

    for (point1, point2, _) in pairs {
        sets.pair_points(point1, point2);
        if sets.set(point1).len() == data.points.len() {
            return data.points[point1].x * data.points[point2].x;
        }
    }
    panic!("By checking all pairs, a set with all elements must exist")
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let data = parse_input(&input).unwrap();

    let ans = answer1(&data);
    println!("Answer 1: {:?}", ans);

    let ans = answer2(&data);
    println!("Answer 2: {:?}", ans);
}

fn parse_point(line: &str) -> Result<Point, String> {
    let err = || format!("Failled to parse '{line}' as num");
    let mut iter = line
        .split(',')
        .map(|num| num.parse::<usize>().map_err(|_| err()));

    Ok(Point {
        x: iter.next().ok_or_else(err)??,
        y: iter.next().ok_or_else(err)??,
        z: iter.next().ok_or_else(err)??,
    })
}

fn parse_input(input: &str) -> Result<Data, String> {
    let points = input
        .trim()
        .lines()
        .map(parse_point)
        .collect::<Result<Box<_>, _>>()?;

    Ok(Data { points })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test1() {
        let input = include_str!("test.txt");

        assert_eq!(answer1_aux(&parse_input(input).unwrap(), 10), 40);
    }

    #[test]
    fn test2() {
        let input = include_str!("test.txt");

        assert_eq!(answer2(&parse_input(input).unwrap()), 25272);
    }
}
