use std::str::FromStr;

struct Range {
    low: u32,
    high: u32,
}

impl Range {
    fn contains(&self, other: &Range) -> bool {
        self.low <= other.low && self.high >= other.high
    }

    fn overlaps(&self, other: &Range) -> bool {
        self.low <= other.high && self.high >= other.low
    }
}

impl FromStr for Range {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut parts = s.split('-');

        let low = parts
            .next()
            .ok_or("Missing low")?
            .parse()
            .map_err(|e| format!("Invalid low: {}", e))?;
        let high = parts
            .next()
            .ok_or("Missing high")?
            .parse()
            .map_err(|e| format!("Invalid high: {}", e))?;

        if parts.next().is_none() {
            Ok(Range { low, high })
        } else {
            Err("Too many parts".to_string())
        }
    }
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let ranges = parse_data(&input);

    let contained = number_of_contained(&ranges);

    println!("Number of overlaps: {}", contained);

    let overlapped = number_of_overlapped(&ranges);

    println!("Number of overlapped: {}", overlapped);
}

fn number_of_contained(ranges: &[(Range, Range)]) -> i32 {
    ranges
        .iter()
        .map(|(r1, r2)| {
            if r1.contains(r2) || r2.contains(r1) {
                1
            } else {
                0
            }
        })
        .sum()
}

fn number_of_overlapped(ranges: &[(Range, Range)]) -> i32 {
    ranges
        .iter()
        .map(|(r1, r2)| if r1.overlaps(r2) { 1 } else { 0 })
        .sum()
}

fn parse_data(data: &str) -> Vec<(Range, Range)> {
    data.lines()
        .map(|line| {
            let mut parts = line.split(',');
            let first = parts.next().expect("Missing first");
            let second = parts.next().expect("Missing second");

            (
                first.parse().expect("Invalid first"),
                second.parse().expect("Invalid second"),
            )
        })
        .collect()
}
