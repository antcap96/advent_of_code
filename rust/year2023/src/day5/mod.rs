mod range_set;

use std::{num::ParseIntError, str::FromStr};

#[derive(Debug)]
struct RangeMap {
    destination: i64,
    source: i64,
    length: i64,
}

impl FromStr for RangeMap {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut iter = s.split_whitespace();

        let destination = iter.next().ok_or(())?.parse().map_err(|_| ())?;
        let source = iter.next().ok_or(())?.parse().map_err(|_| ())?;
        let length = iter.next().ok_or(())?.parse().map_err(|_| ())?;

        Ok(RangeMap {
            destination,
            source,
            length,
        })
    }
}

impl RangeMap {
    fn source_range(&self) -> std::ops::Range<i64> {
        self.source..(self.source + self.length)
    }

    fn translate(&self, id: i64) -> i64 {
        self.destination + id - self.source
    }
}

#[derive(Debug)]
struct GameData {
    seeds: Vec<i64>,
    maps: Vec<Vec<RangeMap>>,
}

fn parse_data(data: &str) -> GameData {
    let mut iter = data.split("\n\n");

    let seeds_str = iter.next();
    let seeds = seeds_str
        .unwrap()
        .split_whitespace()
        .skip(1)
        .map(|n| n.parse())
        .collect::<Result<Vec<i64>, ParseIntError>>()
        .unwrap();

    let maps = iter
        .map(|chunk| {
            chunk
                .lines()
                .skip(1)
                .map(|line| line.parse())
                .collect::<Result<Vec<RangeMap>, ()>>()
        })
        .collect::<Result<Vec<Vec<RangeMap>>, ()>>()
        .unwrap();

    GameData { seeds, maps }
}

pub fn answer() {
    let data = include_str!("input.txt");

    let input = parse_data(data);

    let ans1 = answer1(&input);
    let ans2 = answer2(&input);

    println!("answer1: {}", ans1);
    println!("answer1: {}", ans2);
}

fn next(id: i64, maps: &[RangeMap]) -> i64 {
    for map in maps {
        if map.source_range().contains(&id) {
            return map.translate(id);
        }
    }
    id
}

fn answer1(input: &GameData) -> i64 {
    input
        .seeds
        .iter()
        .map(|seed| {
            input
                .maps
                .iter()
                .fold(*seed, |id, mapping| next(id, mapping))
        })
        .min()
        .expect("maps isn't empty")
}

fn next_range(origin: range_set::RangeSet, mapping: &[RangeMap]) -> range_set::RangeSet {
    let mapped_to = range_set::RangeSet::default();
    let (unmapped, mapped) =
        mapping
            .iter()
            .fold((origin, mapped_to), |(mut unmapped, mut mapped), range| {
                let intersection = unmapped.intersect(&range.source_range());

                if !intersection.is_empty() {
                    let delta = range.destination - range.source;
                    unmapped = unmapped.diff(&intersection);
                    mapped = mapped.union(&intersection.shift(delta));
                }
                (unmapped, mapped)
            });

    unmapped.union(&mapped)
}

fn answer2(input: &GameData) -> i64 {
    input
        .seeds
        .chunks_exact(2)
        .map(|arr| match arr {
            [a, b] => range_set::RangeSet {
                #[allow(clippy::single_range_in_vec_init)]
                ranges: vec![*a..(a + b)],
            },
            _ => unreachable!(),
        })
        .map(|range| {
            input
                .maps
                .iter()
                .fold(range, |range, mapping| next_range(range, mapping))
        })
        .map(|range| {
            range
                .ranges
                .iter()
                .map(|r| r.start)
                .min()
                .expect("ranges isn't empty")
        })
        .min()
        .expect("seeds contains at least 1 chunk")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test() {
        let data = include_str!("test.txt");

        let input = parse_data(data);

        assert_eq!(answer1(&input), 35);
    }

    #[test]
    fn test2() {
        let data = include_str!("test.txt");

        let input = parse_data(data);

        assert_eq!(answer2(&input), 46);
    }
}
