use std::str::FromStr;

enum ElfPlay {
    Rock,
    Paper,
    Scissors,
}

impl FromStr for ElfPlay {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "A" => Ok(ElfPlay::Rock),
            "B" => Ok(ElfPlay::Paper),
            "C" => Ok(ElfPlay::Scissors),
            _ => Err(s.to_owned()),
        }
    }
}

enum PlayerPlay {
    X,
    Y,
    Z,
}

impl FromStr for PlayerPlay {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "X" => Ok(PlayerPlay::X),
            "Y" => Ok(PlayerPlay::Y),
            "Z" => Ok(PlayerPlay::Z),
            _ => Err(s.to_owned()),
        }
    }
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let data = parse_data(&input);

    let points = calculate_points_question1(&data);

    println!("The answer for question 1 is {} points", points);

    let points = calculate_points_question2(&data);

    println!("The answer for question 2 is {} points", points);
}

fn parse_data(data: &str) -> Vec<(ElfPlay, PlayerPlay)> {
    data.lines()
        .map(|line| {
            let mut line = line.split_whitespace();
            let elf_play = line.next().unwrap().parse().unwrap();
            let player_play = line.next().unwrap().parse().unwrap();
            (elf_play, player_play)
        })
        .collect()
}

fn calculate_points_question1(data: &Vec<(ElfPlay, PlayerPlay)>) -> i32 {
    let mut points = 0;
    for (elf_play, player_play) in data {
        let win_points = match (elf_play, player_play) {
            (ElfPlay::Rock, PlayerPlay::Y) => 6,
            (ElfPlay::Rock, PlayerPlay::X) => 3,
            (ElfPlay::Paper, PlayerPlay::Z) => 6,
            (ElfPlay::Paper, PlayerPlay::Y) => 3,
            (ElfPlay::Scissors, PlayerPlay::X) => 6,
            (ElfPlay::Scissors, PlayerPlay::Z) => 3,
            _ => 0,
        };
        let choice_points = match player_play {
            PlayerPlay::X => 1,
            PlayerPlay::Y => 2,
            PlayerPlay::Z => 3,
        };
        points += win_points + choice_points;
    }
    points
}

fn calculate_points_question2(data: &Vec<(ElfPlay, PlayerPlay)>) -> i32 {
    let mut points = 0;
    for (elf_play, player_play) in data {
        let choice_points = match (elf_play, player_play) {
            (ElfPlay::Rock, PlayerPlay::X) => 3,
            (ElfPlay::Rock, PlayerPlay::Y) => 1,
            (ElfPlay::Rock, PlayerPlay::Z) => 2,
            (ElfPlay::Paper, PlayerPlay::X) => 1,
            (ElfPlay::Paper, PlayerPlay::Y) => 2,
            (ElfPlay::Paper, PlayerPlay::Z) => 3,
            (ElfPlay::Scissors, PlayerPlay::X) => 2,
            (ElfPlay::Scissors, PlayerPlay::Y) => 3,
            (ElfPlay::Scissors, PlayerPlay::Z) => 1,
        };
        let win_points = match player_play {
            PlayerPlay::X => 0,
            PlayerPlay::Y => 3,
            PlayerPlay::Z => 6,
        };
        points += win_points + choice_points;
    }
    points
}
