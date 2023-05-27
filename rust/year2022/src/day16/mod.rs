use std::collections::{HashMap, HashSet};

#[derive(Debug)]
struct Valve {
    flow_rate: i32,
    tunnels: Vec<String>,
}

struct SimplifiedSystem {
    distances: ndarray::Array2<i32>,
    key_map: HashMap<String, usize>,
    valves: HashMap<String, Valve>,
}

impl SimplifiedSystem {
    fn new(system: HashMap<String, Valve>) -> SimplifiedSystem {
        let key_map: HashMap<String, usize> = system.keys().cloned().zip(0..).collect();

        let distances = calculate_distances(&system, &key_map);

        SimplifiedSystem {
            distances,
            key_map,
            valves: system,
        }
    }
}

fn calculate_distances(
    system: &HashMap<String, Valve>,
    key_map: &HashMap<String, usize>,
) -> ndarray::Array2<i32> {
    let mut distances = ndarray::Array2::zeros((system.len(), system.len()));
    
    for start in system.keys() {
        let mut next_queue = vec![start];
        let mut distance = 2;
        let start_idx = *key_map.get(start).unwrap();
        distances[[start_idx, start_idx]] = 1;
        while !next_queue.is_empty() {
            let queue = next_queue;
            next_queue = vec![];
            for next in queue {
                let valve = system.get(next).unwrap();
                for tunnel in &valve.tunnels {
                    let next_idx = *key_map.get(tunnel).unwrap();
                    if distances[[start_idx, next_idx]] == 0 {
                        distances[[start_idx, next_idx]] = distance;
                        next_queue.push(tunnel);
                    }
                }
            }
            distance += 1;
        }
    }
    distances
}

#[derive(Clone)]
struct SearchState<'a> {
    position: &'a str,
    closed: HashSet<&'a str>,
}

impl<'a> SearchState<'a> {
    fn new(closed: HashSet<&'a str>) -> Self {
        Self {
            position: "AA",
            closed,
        }
    }
}

pub fn answer() {
    let data =
        std::fs::read_to_string("year2022/src/day16/input.txt").expect("Failed to read file");

    let system = parse_data(&data);

    let simplified_system = SimplifiedSystem::new(system);

    let closed = simplified_system
        .valves
        .iter()
        .filter(|(_k, v)| v.flow_rate > 0)
        .map(|(k, _v)| k.as_str())
        .collect();

    let answer1 = find_most_pressure_released(&simplified_system, 30, SearchState::new(closed));

    println!("Answer 1 {}", answer1);
}

fn find_most_pressure_released<'a>(
    system: &'a SimplifiedSystem,
    minutes: i32,
    state: SearchState<'a>,
) -> i32 {
    if minutes <= 0 {
        return 0;
    }

    let mut cost = 0;

    for location in &state.closed {
        let time = system.distances[[system.key_map[state.position], system.key_map[*location]]];

        let mut new_state = state.clone();
        new_state.closed.remove(location);
        new_state.position = location;
        let new_time = minutes - time;
        let release = new_time * system.valves.get(*location).unwrap().flow_rate;

        let release_rest = find_most_pressure_released(system, new_time, new_state);

        let total_release = release + release_rest;
        cost = cost.max(total_release);
    }
    cost
}

fn parse_valve(input: &str) -> Result<(String, Valve), nom::Err<nom::error::Error<&str>>> {
    let (input, _) = nom::bytes::complete::tag("Valve ")(input)?;
    let (input, id) = nom::bytes::complete::take(2u32)(input)?;
    let (input, _) = nom::bytes::complete::tag(" has flow rate=")(input)?;
    let (input, flow_rate) = nom::character::complete::i32(input)?;
    let (input, _) = nom::branch::alt((
        nom::bytes::complete::tag("; tunnels lead to valves "),
        nom::bytes::complete::tag("; tunnel leads to valve "),
    ))(input)?;
    let (_, tunnels) = nom::multi::separated_list1(
        nom::bytes::complete::tag(", "),
        nom::bytes::complete::take(2u32),
    )(input)?;

    let tunnels = tunnels.iter().map(|&tunnel| tunnel.to_owned()).collect();

    Ok((id.to_owned(), Valve { flow_rate, tunnels }))
}

fn parse_data(data: &str) -> HashMap<String, Valve> {
    let valves = data
        .lines()
        .map(|line| parse_valve(line).unwrap())
        .collect::<HashMap<String, Valve>>();

    valves
}
