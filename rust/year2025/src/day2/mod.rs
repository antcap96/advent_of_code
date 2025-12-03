use std::ops::RangeInclusive;

#[derive(Debug)]
enum ParseError {
    #[allow(dead_code)]
    MissingDash(String),
    #[allow(dead_code)]
    ParseIntError(String),
}

fn min_with_digits(n: u32) -> usize {
    10usize.pow(n - 1)
}

fn max_with_digits(n: u32) -> usize {
    10usize.pow(n) - 1
}

fn repeat_num(pattern: usize, repeat: usize) -> usize {
    pattern.to_string().repeat(repeat).parse::<usize>().unwrap()
}

fn invalids(range: &RangeInclusive<usize>, two_only: bool) -> Vec<usize> {
    let start_count = range.start().to_string().len();
    let end_count = range.end().to_string().len();

    if end_count > start_count {
        let mut invalid = invalid_ids(
            *range.start(),
            max_with_digits(start_count as u32),
            two_only,
        );
        for count in (start_count + 1)..end_count {
            invalid.extend(invalid_ids(
                min_with_digits(count as u32),
                max_with_digits(count as u32),
                two_only,
            ));
        }
        invalid.extend(invalid_ids(
            min_with_digits(end_count as u32),
            *range.end(),
            two_only,
        ));
        invalid
    } else {
        invalid_ids(*range.start(), *range.end(), two_only)
    }
}

fn invalid_ids(start: usize, end: usize, two_only: bool) -> Vec<usize> {
    let count = start.to_string().len();
    assert!(end.to_string().len() == count);
    let mut result = Vec::<usize>::new();
    for i in 1..=count / 2 {
        if count % i == 0 {
            let repeat = count / i;
            if repeat != 2 && two_only {
                continue;
            }
            let mut prefix_start: usize = start / 10usize.pow((count - i) as u32);
            if repeat_num(prefix_start, repeat) < start {
                prefix_start += 1
            }
            let mut prefix_end: usize = end / 10usize.pow((count - i) as u32);
            if repeat_num(prefix_end, repeat) > end {
                prefix_end -= 1
            }
            result.extend((prefix_start..=prefix_end).map(|num| repeat_num(num, repeat)));
        }
    }
    result.sort();
    result.dedup();
    result
}

fn answer1(instructions: &[RangeInclusive<usize>]) -> usize {
    instructions
        .iter()
        .map(|num| invalids(num, true))
        .flat_map(|vec| vec.into_iter())
        .sum()
}

fn answer2(instructions: &[RangeInclusive<usize>]) -> usize {
    instructions
        .iter()
        .map(|num| invalids(num, false))
        .flat_map(|vec| vec.into_iter())
        .sum()
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let ranges = parse_input(&input).unwrap();

    let ans = answer1(&ranges);
    println!("Answer 1: {:?}", ans);

    let ans = answer2(&ranges);
    println!("Answer 2: {:?}", ans);
}

fn parse_input(data: &str) -> Result<Vec<RangeInclusive<usize>>, ParseError> {
    data.trim()
        .split(',')
        .map(|s| {
            s.split_once('-')
                .map(|(start, end)| {
                    let start = start
                        .parse()
                        .map_err(|_| ParseError::ParseIntError(start.to_owned()))?;
                    let end = end
                        .parse()
                        .map_err(|_| ParseError::ParseIntError(end.to_owned()))?;
                    Ok(start..=end)
                })
                .unwrap_or(Err(ParseError::MissingDash(s.to_owned())))
        })
        .collect::<Result<Vec<_>, ParseError>>()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test1() {
        let input = include_str!("test.txt");

        assert_eq!(answer1(&parse_input(input).unwrap()), 1227775554);
    }

    #[test]
    fn test2() {
        let input = include_str!("test.txt");

        assert_eq!(answer2(&parse_input(input).unwrap()), 4174379265);
    }

    #[test]
    fn test_each_answer2() {
        assert_eq!(invalids(&(11..=22), false), vec![11, 22]);
        assert_eq!(invalids(&(95..=115), false), vec![99, 111]);
        assert_eq!(invalids(&(998..=1012), false), vec![999, 1010]);
        assert_eq!(
            invalids(&(1188511880..=1188511890), false),
            vec![1188511885]
        );
        assert_eq!(invalids(&(222220..=222224), false), vec![222222]);
        assert_eq!(invalids(&(1698522..=1698528), false), vec![]);
        assert_eq!(invalids(&(446443..=446449), false), vec![446446]);
        assert_eq!(invalids(&(38593856..=38593862), false), vec![38593859]);
        assert_eq!(invalids(&(565653..=565659), false), vec![565656]);
        assert_eq!(invalids(&(824824821..=824824827), false), vec![824824824]);
        assert_eq!(
            invalids(&(2121212118..=2121212124), false),
            vec![2121212121]
        );
    }

    #[test]
    fn test_each_answer1() {
        assert_eq!(invalids(&(11..=22), true), vec![11, 22]);
        assert_eq!(invalids(&(95..=115), true), vec![99]);
        assert_eq!(invalids(&(998..=1012), true), vec![1010]);
        assert_eq!(invalids(&(1188511880..=1188511890), true), vec![1188511885]);
        assert_eq!(invalids(&(222220..=222224), true), vec![222222]);
        assert_eq!(invalids(&(1698522..=1698528), true), vec![]);
        assert_eq!(invalids(&(446443..=446449), true), vec![446446]);
        assert_eq!(invalids(&(38593856..=38593862), true), vec![38593859]);
        assert_eq!(invalids(&(565653..=565659), true), vec![]);
        assert_eq!(invalids(&(824824821..=824824827), true), vec![]);
        assert_eq!(invalids(&(2121212118..=2121212124), true), vec![]);
    }
}
