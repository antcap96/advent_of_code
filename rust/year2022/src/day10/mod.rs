use itertools::Itertools;
use std::str::FromStr;

#[derive(Debug)]
enum Operation {
    Noop,
    Addx(i32),
}

impl FromStr for Operation {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "noop" => Ok(Operation::Noop),
            s if s.starts_with("addx") => s
                .split_whitespace()
                .nth(1)
                .ok_or(())?
                .parse()
                .map(Operation::Addx)
                .map_err(|_| ()),
            _ => Err(()),
        }
    }
}

impl Operation {
    fn cycles(&self) -> u32 {
        match self {
            Operation::Noop => 1,
            Operation::Addx(_) => 2,
        }
    }
}

#[derive(Debug)]
struct CPU {
    register: i32,
    cycle: u32,
}

impl CPU {
    fn new() -> Self {
        Self {
            register: 1,
            cycle: 0,
        }
    }

    fn execute(&mut self, operation: &Operation) {
        match operation {
            Operation::Noop => {}
            Operation::Addx(x) => self.register += x,
        }
        self.cycle += operation.cycles();
    }
}

struct CRT {
    screen: Vec<bool>,
}

impl CRT {
    fn new() -> CRT {
        CRT {
            screen: vec![false; 240],
        }
    }

    fn screen(&self) -> String {
        self.screen
            .chunks(40)
            .map(|chuck| {
                chuck
                    .iter()
                    .map(|bit| if *bit { '#' } else { '.' })
                    .collect::<String>()
            })
            .join("\n")
    }
}

// during
pub fn answer() {
    let data =
        std::fs::read_to_string("year2022/src/day10/input.txt").expect("Unable to read file");

    let operations = parse_data(&data);

    let (crt, total) = get_answers(operations);

    println!("Answer 1: {}", total);

    println!("Answer 2:\n{}", crt.screen());
}

fn get_answers(operations: Vec<Operation>) -> (CRT, i32) {
    let mut cpu = CPU::new();
    let mut crt = CRT::new();

    let mut total = 0;
    let mut cycle = 0;
    let mut cycle_check = 20;

    for op in operations {
        let register_during_execution = cpu.register;
        cpu.execute(&op);
        while cycle < cpu.cycle {
            crt.screen[cycle as usize] =
                (register_during_execution - (cycle % 40) as i32).abs() <= 1;

            cycle += 1;
            if cycle == cycle_check {
                total += register_during_execution * cycle_check as i32;
                cycle_check += 40;
            }
        }
    }
    (crt, total)
}

fn parse_data(data: &str) -> Vec<Operation> {
    data.lines().map(|line| line.parse().unwrap()).collect()
}
