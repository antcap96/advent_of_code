struct Data<'a> {
    //numbers: Box<[Box<[usize]>]>,
    digits: Box<[Box<[&'a [u8]]>]>,
    operations: Box<[Operation]>,
}

enum Operation {
    Add,
    Mul,
}

impl Operation {
    fn apply(&self, x: usize, y: usize) -> usize {
        match self {
            Self::Add => x + y,
            Self::Mul => x * y,
        }
    }
}

impl TryFrom<u8> for Operation {
    type Error = String;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            b'*' => Ok(Operation::Mul),
            b'+' => Ok(Operation::Add),
            _ => Err(format!("Invalid char {}", value as char)),
        }
    }
}

fn answer1(data: &Data) -> usize {
    (0..(data.operations.len()))
        .map(|i| {
            data.numbers
                .iter()
                .map(|list| list[i])
                .reduce(|acc, x| data.operations[i].apply(acc, x))
                .unwrap()
        })
        .sum()
}

fn answer2(data: &Data) -> usize {
    todo!()
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
    let lines: Vec<&str> = input.trim().lines().collect();

    let numbers: Box<[Box<[usize]>]> = lines[0..(lines.len() - 1)]
        .iter()
        .map(|line| {
            line.split_ascii_whitespace()
                .map(|num| num.parse().map_err(|_| format!("invalid number {}", num)))
                .collect::<Result<Box<[usize]>, String>>()
        })
        .collect::<Result<Box<_>, String>>()?;

    let operations = lines
        .last()
        .unwrap()
        .split_ascii_whitespace()
        .map(|op| match op.as_bytes() {
            [c] => (*c).try_into(),
            _ => Err(format!("Invalid op {}", op)),
        })
        .collect::<Result<Box<_>, String>>()?;

    Ok(Data {
        numbers,
        operations,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test1() {
        let input = include_str!("test.txt");

        assert_eq!(answer1(&parse_input(input).unwrap()), 4277556);
    }

    #[test]
    fn test2() {
        let input = include_str!("test.txt");

        assert_eq!(answer2(&parse_input(input).unwrap()), 14);
    }
}
