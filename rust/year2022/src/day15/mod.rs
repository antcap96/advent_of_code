use std::{collections::HashSet, str::FromStr};

#[derive(Debug)]
struct Point {
    x: i32,
    y: i32,
}

impl Point {
    fn manhattan_distance(&self, other: &Self) -> i32 {
        (self.x - other.x).abs() + (self.y - other.y).abs()
    }
}

#[derive(Debug)]
struct Sensor {
    position: Point,
    closest_beacon: Point,
}

impl FromStr for Sensor {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut chars = s.chars();

        let beacon_x = parse_i32_from_iter(&mut chars);
        let beacon_y = parse_i32_from_iter(&mut chars);
        let sensor_x = parse_i32_from_iter(&mut chars);
        let sensor_y = parse_i32_from_iter(&mut chars);

        Ok(Self {
            position: Point {
                x: beacon_x,
                y: beacon_y,
            },
            closest_beacon: Point {
                x: sensor_x,
                y: sensor_y,
            },
        })
    }
}

fn parse_i32_from_iter(chars: &mut impl Iterator<Item = char>) -> i32 {
    let mut buffer = String::new();
    for c in chars {
        if c.is_ascii_digit() || c == '-' {
            buffer.push(c)
        } else if !buffer.is_empty() {
            break;
        }
    }
    buffer.parse::<i32>().unwrap()
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let sensors = parse_data(&input);

    let answer1 = count_impossible(&sensors, 2000000);

    println!("Answer 1: {}", answer1.0);

    for y in 0..4000000 {
        let (_, answer2) = count_impossible(&sensors, y);
        if let Some(answer2) = answer2 {
            println!("Answer 2: {}", answer2);
            break;
        }
    }
}

fn count_impossible(sensors: &[Sensor], row: i32) -> (usize, Option<i64>) {
    let mut impossible_ranges = Vec::new();

    for sensor in sensors {
        let distance = sensor.position.manhattan_distance(&sensor.closest_beacon);

        if let Some(range) = impossible_range(distance, &sensor.position, row) {
            impossible_ranges.push(range)
        }
    }

    impossible_ranges.sort_by(|a, b| a.start.cmp(&b.start).then(a.end.cmp(&b.end)));

    let merged_ranges = merge_ranges(impossible_ranges);

    let impossible_count: usize = merged_ranges.iter().map(|range| range.len()).sum();

    let beacons_in_row = count_beacons_in_row(sensors, row);
    let impossible_excluding_beacons = impossible_count - beacons_in_row;

    let tunning_frequency = if merged_ranges.len() > 1 {
        merged_ranges.first()
            .map(|x| x.end as i64 * 4000000 + row as i64)
    } else {
        None
    };

    (impossible_excluding_beacons, tunning_frequency)
}

fn count_beacons_in_row(sensors: &[Sensor], row: i32) -> usize {
    let beacons_in_row = sensors
        .iter()
        .filter(|sensor| sensor.closest_beacon.y == row)
        .map(|sensor| sensor.closest_beacon.x)
        .collect::<HashSet<_>>()
        .len();
    beacons_in_row
}

fn impossible_range(
    distance: i32,
    sensor_position: &Point,
    row: i32,
) -> Option<std::ops::Range<i32>> {
    let impossible_width = (distance - (sensor_position.y - row).abs()) * 2 + 1;
    if impossible_width <= 0 {
        return None;
    }
    let impossible_start = sensor_position.x - impossible_width / 2;
    let impossible_end = impossible_start + impossible_width;
    Some(impossible_start..impossible_end)
}

fn merge_ranges(sorted_ranges: Vec<std::ops::Range<i32>>) -> Vec<std::ops::Range<i32>> {
    let mut merged_ranges: Vec<std::ops::Range<i32>> = Vec::new();

    for range in sorted_ranges.into_iter() {
        if let Some(last) = merged_ranges.last_mut() {
            if last.end >= range.start {
                let new_end = last.end.max(range.end);
                last.end = new_end;
                continue;
            }
        }
        merged_ranges.push(range);
    }
    merged_ranges
}

fn parse_data(data: &str) -> Vec<Sensor> {
    data.lines().map(|line| line.parse().unwrap()).collect()
}
