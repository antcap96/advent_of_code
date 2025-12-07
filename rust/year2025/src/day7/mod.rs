use std::collections::{HashMap, HashSet};

struct Data {
    start: usize,
    splitters: Vec<HashSet<usize>>,
}

fn answer1(data: &Data) -> usize {
    let mut beams = HashSet::from_iter([data.start]);
    let mut splits = 0;
    for row in data.splitters.iter() {
        let matches = beams.intersection(&row).cloned().collect::<HashSet<_>>();
        splits += matches.len();
        beams.retain(|beam| !matches.contains(beam));
        for split in matches {
            if split > 0 {
                beams.insert(split - 1);
            }
            beams.insert(split + 1);
        }
    }
    splits
}

fn answer2(data: &Data) -> usize {
    let mut beams: HashMap<usize, usize> = HashMap::from_iter([(data.start, 1)]);
    for row in data.splitters.iter() {
        let matches = beams
            .iter()
            .filter(|(at, _)| row.contains(at))
            .map(|(at, timelines)| (*at, *timelines))
            .collect::<Vec<_>>();

        for (split, timelines) in matches {
            beams.remove(&split);
            if split > 0 {
                *beams.entry(split - 1).or_insert(0) += timelines;
            }
            *beams.entry(split + 1).or_insert(0) += timelines;
        }
    }
    beams.values().sum()
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let data = parse_input(&input).unwrap();

    let ans = answer1(&data);
    println!("Answer 1: {:?}", ans);

    let ans = answer2(&data);
    println!("Answer 2: {:?}", ans);
}

fn parse_input(input: &str) -> Result<Data, String> {
    let mut lines = input.lines();
    let start = lines
        .next()
        .and_then(|line| line.find('S'))
        .ok_or("Unable to find start")?;

    let splitters = lines
        .map(|line| {
            line.bytes()
                .enumerate()
                .flat_map(|(idx, b)| (b == b'^').then(|| idx))
                .collect::<HashSet<_>>()
        })
        .filter(|line| !line.is_empty())
        .collect::<Vec<_>>();

    Ok(Data { start, splitters })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test1() {
        let input = include_str!("test.txt");

        assert_eq!(answer1(&parse_input(input).unwrap()), 21);
    }

    #[test]
    fn test2() {
        let input = include_str!("test.txt");

        assert_eq!(answer2(&parse_input(input).unwrap()), 40);
    }
}
