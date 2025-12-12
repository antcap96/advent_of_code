#[derive(Clone, Copy)]
struct Mod100 {
    num: u8,
}

impl Mod100 {
    fn add(self, other: Mod100) -> Mod100 {
        Mod100 {
            num: (self.num + other.num) % 100,
        }
    }

    fn rev(self) -> Mod100 {
        Mod100 {
            num: 100 - self.num,
        }
    }
}

impl From<usize> for Mod100 {
    fn from(value: usize) -> Self {
        Mod100 {
            num: (value % 100).try_into().unwrap(),
        }
    }
}

#[derive(Clone, Copy)]
struct Step {
    direction: Direction,
    amount: usize,
}

#[derive(Clone, Copy)]
enum Direction {
    L,
    R,
}

impl TryFrom<char> for Direction {
    type Error = ();
    fn try_from(value: char) -> Result<Self, Self::Error> {
        match value {
            'L' => Ok(Direction::L),
            'R' => Ok(Direction::R),
            _ => Err(()),
        }
    }
}

fn step_dial(dial: Mod100, step: &Step) -> Mod100 {
    match step.direction {
        Direction::L => dial.add(Mod100::from(step.amount).rev()),
        Direction::R => dial.add(Mod100::from(step.amount)),
    }
}

fn answer1(instructions: &[Step]) -> usize {
    let mut dial: Mod100 = 50.into();
    let mut count = 0;

    for step in instructions {
        dial = step_dial(dial, step);
        if dial.num == 0 {
            count += 1;
        }
    }
    count
}

fn answer2(instructions: &[Step]) -> usize {
    let mut dial: i16 = 50;
    let mut count = 0;

    for step in instructions {
        assert!((0..100).contains(&dial));
        let extra = step.amount / 100;
        count += extra;
        let rem = (step.amount % 100) as i16;
        dial = match step.direction {
            Direction::L => dial - rem,
            Direction::R => dial + rem,
        };
        match dial {
            0 => count += 1,
            ..0 => {
                if -rem != dial {
                    count += 1;
                }
                dial += 100;
            }
            100.. => {
                dial -= 100;
                count += 1;
            }
            _ => {}
        }
    }
    if dial == 0 {
        count += 1
    }
    count
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let instructions = parse_input(&input).unwrap();

    let ans = answer1(&instructions);
    println!("Answer 1: {:?}", ans);

    let ans = answer2(&instructions);
    println!("Answer 2: {:?}", ans);
}

fn parse_input(data: &str) -> Result<Vec<Step>, ()> {
    Ok(data
        .trim()
        .lines()
        .map(parse_instruction)
        .collect::<Vec<Step>>())
}

fn parse_instruction(bytes: &str) -> Step {
    let (c, num) = bytes.split_at(1);
    let c = c.chars().next().unwrap();
    Step {
        direction: c.try_into().unwrap(),
        amount: num.parse().unwrap(),
    }
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

        assert_eq!(answer2(&parse_input(input).unwrap()), 6);
    }
}
