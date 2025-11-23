use nom::Finish;
// WIP

#[derive(Debug)]
struct OreRobot {
    ore_cost: i32,
}
#[derive(Debug)]
struct ClayRobot {
    ore_cost: i32,
}
#[derive(Debug)]
struct ObsidianRobot {
    ore_cost: i32,
    clay_cost: i32,
}
#[derive(Debug)]
struct GeodeRobot {
    ore_cost: i32,
    obsidian_cost: i32,
}

#[derive(Debug)]
struct Blueprint {
    ore_robot: OreRobot,
    clay_robot: ClayRobot,
    obsidian_robot: ObsidianRobot,
    geode_robot: GeodeRobot,
}

#[derive(Clone, Debug)]
struct SimulationState {
    ore_robots: i32,
    clay_robots: i32,
    obsidian_robots: i32,
    geode_robots: i32,
    ore: i32,
    clay: i32,
    obsidian: i32,
    geodes: i32,
}

impl SimulationState {
    fn new() -> SimulationState {
        SimulationState {
            ore_robots: 1,
            clay_robots: 0,
            obsidian_robots: 0,
            geode_robots: 0,
            ore: 0,
            clay: 0,
            obsidian: 0,
            geodes: 0,
        }
    }

    fn update(&mut self) {
        self.ore += self.ore_robots;
        self.clay += self.clay_robots;
        self.obsidian += self.obsidian_robots;
        self.geodes += self.geode_robots;
    }
}

fn max_geodes(blueprint: &Blueprint) -> i32 {
    let state = SimulationState::new();

    step(state, blueprint, 0)
}

fn step(state: SimulationState, blueprint: &Blueprint, i: u32) -> i32 {
    if i > 24 {
        return state.geodes;
    }
    if i < 23 {
        dbg!(i, &state);
    }
    let mut maximum = 0;
    let max_by_obsidian = state.obsidian / blueprint.geode_robot.obsidian_cost;
    let max_by_ore = state.ore / blueprint.geode_robot.ore_cost;
    let max_geodes = max_by_obsidian.min(max_by_ore);

    for new_geodes in 0..=max_geodes {
        let mut new_state = state.clone();
        new_state.geode_robots += new_geodes;
        let max_by_obsidian = new_state.ore / blueprint.obsidian_robot.ore_cost;
        let max_by_clay = new_state.clay / blueprint.obsidian_robot.clay_cost;
        let max_obsidian = max_by_obsidian.min(max_by_clay);

        for new_obsidian in 0..=max_obsidian {
            let mut new_state2 = new_state.clone();
            new_state2.obsidian_robots += new_obsidian;
            let max_clay = new_state2.ore / blueprint.clay_robot.ore_cost;

            for new_clay in 0..=max_clay {
                let mut new_state3 = new_state2.clone();
                new_state3.clay_robots += new_clay;
                let max_ore = new_state3.ore / blueprint.ore_robot.ore_cost;

                for new_ore in 0..=max_ore {
                    let mut new_state4 = new_state3.clone();
                    new_state4.ore_robots += new_ore;
                    new_state4.update();
                    let geodes = step(new_state4, blueprint, i + 1);

                    if geodes > maximum {
                        maximum = geodes;
                    }
                }
            }
        }
    }
    maximum
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let blueprints = parse_blueprint_wrapper(&input);

    for blueprint in &blueprints {
        let max_geodes = max_geodes(blueprint);
        dbg!(max_geodes);
    }
}

fn parse_blueprint_id(data: &str) -> nom::IResult<&str, i32> {
    let (data, _) = nom::bytes::complete::tag("Blueprint ")(data)?;
    let (data, id) = nom::character::complete::i32(data)?;
    let (data, _) = nom::bytes::complete::tag(": ")(data)?;

    Ok((data, id))
}

fn parse_ore_robot(data: &str) -> nom::IResult<&str, OreRobot> {
    let (data, _) = nom::bytes::complete::tag("Each ore robot costs ")(data)?;
    let (data, ore_cost) = nom::character::complete::i32(data)?;
    let (data, _) = nom::bytes::complete::tag(" ore. ")(data)?;

    Ok((data, OreRobot { ore_cost }))
}

fn parse_clay_robot(data: &str) -> nom::IResult<&str, ClayRobot> {
    let (data, _) = nom::bytes::complete::tag("Each clay robot costs ")(data)?;
    let (data, ore_cost) = nom::character::complete::i32(data)?;
    let (data, _) = nom::bytes::complete::tag(" ore. ")(data)?;

    Ok((data, ClayRobot { ore_cost }))
}

fn parse_obsidian_robot(data: &str) -> nom::IResult<&str, ObsidianRobot> {
    let (data, _) = nom::bytes::complete::tag("Each obsidian robot costs ")(data)?;
    let (data, ore_cost) = nom::character::complete::i32(data)?;
    let (data, _) = nom::bytes::complete::tag(" ore and ")(data)?;
    let (data, clay_cost) = nom::character::complete::i32(data)?;
    let (data, _) = nom::bytes::complete::tag(" clay. ")(data)?;

    Ok((
        data,
        ObsidianRobot {
            ore_cost,
            clay_cost,
        },
    ))
}

fn parse_geode_robot(data: &str) -> nom::IResult<&str, GeodeRobot> {
    let (data, _) = nom::bytes::complete::tag("Each geode robot costs ")(data)?;
    let (data, ore_cost) = nom::character::complete::i32(data)?;
    let (data, _) = nom::bytes::complete::tag(" ore and ")(data)?;
    let (data, obsidian_cost) = nom::character::complete::i32(data)?;
    let (data, _) = nom::bytes::complete::tag(" obsidian.")(data)?;

    Ok((
        data,
        GeodeRobot {
            ore_cost,
            obsidian_cost,
        },
    ))
}

fn parse_blueprint(data: &str) -> nom::IResult<&str, Blueprint> {
    let (data, _id) = parse_blueprint_id(data)?;
    let (data, ore_robot) = parse_ore_robot(data)?;
    let (data, clay_robot) = parse_clay_robot(data)?;
    let (data, obsidian_robot) = parse_obsidian_robot(data)?;
    let (data, geode_robot) = parse_geode_robot(data)?;

    Ok((
        data,
        Blueprint {
            ore_robot,
            clay_robot,
            obsidian_robot,
            geode_robot,
        },
    ))
}

fn parse_blueprint_wrapper(data: &str) -> Vec<Blueprint> {
    nom::multi::separated_list1(nom::bytes::complete::tag("\n"), parse_blueprint)(data)
        .finish()
        .unwrap()
        .1
}

// fn parse_data(data: &str) -> Vec<Blueprint> {
//     data.lines().map(|line| parse_blueprint(line).finish().unwrap()).collect()
// }
