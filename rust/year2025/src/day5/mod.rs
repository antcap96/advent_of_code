use std::ops::RangeInclusive;

struct Data {
    fresh: Box<[RangeInclusive<usize>]>,
    available: Box<[usize]>,
}

fn answer1(data: &Data) -> usize {
    data.available
        .iter()
        .filter(|id| data.fresh.iter().any(|range| range.contains(&id)))
        .count()
}

fn count_valid_ids(mut ranges: Vec<RangeInclusive<usize>>) -> usize {
    if ranges.len() == 0 {
        return 0;
    }

    ranges.sort_by(|a, b| a.start().cmp(b.start()));
    let mut start = *ranges[0].start();
    let mut end = *ranges[0].end();
    
    let mut count = 0;
    for range in ranges.into_iter() {
        if (start..=end).contains(range.start()) {
            end = end.max(*range.end());
        } else {
            count += (start..=end).count();
            start = *range.start();
            end = *range.end();
        }
    }
    count += (start..=end).count();

    count
}

fn answer2(data: &Data) -> usize {
    count_valid_ids(data.fresh.clone().into())
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
    let (ranges, ids) = input
        .split_once("\n\n")
        .ok_or("Failled to find the double line break".to_owned())?;

    let fresh = ranges
        .lines()
        .map(|line| {
            line.split_once('-')
                .ok_or(format!("missing dash in range {}", line))
                .and_then(|(first, second)| {
                    let first: usize = first
                        .parse()
                        .map_err(|_| format!("invalid first {}", first))?;
                    let second: usize = second
                        .parse()
                        .map_err(|_| format!("invalid second {}", second))?;
                    Ok(first..=second)
                })
        })
        .collect::<Result<Box<_>, _>>()?;

    let available = ids
        .lines()
        .map(|line| line.parse().map_err(|_| format!("invalid id {}", line)))
        .collect::<Result<Box<_>, _>>()?;

    Ok(Data { fresh, available })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test1() {
        let input = include_str!("test.txt");

        assert_eq!(answer1(&parse_input(input).unwrap()), 3);
    }

    #[test]
    fn test2() {
        let input = include_str!("test.txt");

        assert_eq!(answer2(&parse_input(input).unwrap()), 14);
    }
}
