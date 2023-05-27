use std::collections::{HashMap, HashSet};

#[derive(Debug)]
struct Valve {
    flow_rate: i32,
    tunnels: Vec<String>,
}

impl Valve {
    fn new(flow_rate: i32, tunnels: Vec<String>) -> Self {
        Self { flow_rate, tunnels }
    }
}

#[derive(Debug)]
struct System {
    valves: HashMap<String, Valve>,
}

impl System {
    fn new(valves: HashMap<String, Valve>) -> Self {
        Self { valves }
    }

    fn possible_actions(&self, state: &SearchState) -> Vec<Action> {
        let valve = self.valves.get(state.position).unwrap();

        let mut actions = vec![];

        if state.closed.contains(state.position) && valve.flow_rate > 0 {
            actions.push(Action::Open);
        }

        for tunnel in &valve.tunnels {
            if state
                .previous_position
                .map(|value| value != tunnel)
                .unwrap_or(true)
            {
                actions.push(Action::Move(tunnel.as_str()));
            }
        }

        actions
    }

    fn perform_action<'a>(
        &self,
        action: Action<'a>,
        minutes: i32,
        state: &mut SearchState<'a>,
    ) -> u32 {
        match action {
            Action::Open => {
                let valve = self.valves.get(state.position).unwrap();
                state.closed.remove(state.position);
                state.previous_position = None;
                (valve.flow_rate * (minutes - 1)) as u32
            }
            Action::Move(tunnel) => {
                state.previous_position = Some(state.position);
                state.position = tunnel;
                0
            }
        }
    }
}

#[derive(Debug)]
enum Action<'a> {
    Open,
    Move(&'a str),
}

#[derive(Clone)]
struct SearchState<'a> {
    position: &'a str,
    previous_position: Option<&'a str>,
    closed: HashSet<&'a str>,
}

impl<'a> SearchState<'a> {
    fn new(closed: HashSet<&'a str>) -> Self {
        Self {
            position: "AA",
            previous_position: None,
            closed,
        }
    }
}

pub fn answer() {
    let data =
        std::fs::read_to_string("year2022/src/day16/input.txt").expect("Failed to read file");

    let system = parse_data(&data);

    let closed = system
        .valves
        .keys()
        .map(|k| k.as_str())
        .filter(|&k| system.valves.get(k).unwrap().flow_rate > 0)
        .collect();

    let answer1 = find_most_pressure_released(&system, 30, SearchState::new(closed));

    println!("Answer 1 {}", answer1);
}

fn find_most_pressure_released<'a>(
    system: &'a System,
    minutes: i32,
    state: SearchState<'a>,
) -> u32 {
    if minutes > 25 {
        dbg!(minutes);
    }
    if minutes <= 0 {
        return 0;
    }
    let actions = system.possible_actions(&state);

    // dbg!(minutes, &state.position, &state.previous_position, &actions);

    let mut cost = 0;

    let into_iter = actions.into_iter();

    for action in into_iter {
        let mut new_state = state.clone();
        let release = system.perform_action(action, minutes, &mut new_state);

        let release_rest = find_most_pressure_released(system, minutes - 1, new_state);

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

    Ok((id.to_owned(), Valve::new(flow_rate, tunnels)))
}

fn parse_data(data: &str) -> System {
    let valves = data
        .lines()
        .map(|line| parse_valve(line).unwrap())
        .collect::<HashMap<String, Valve>>();

    System::new(valves)
}
