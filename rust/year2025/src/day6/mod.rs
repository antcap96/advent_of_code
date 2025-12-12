#[derive(Debug)]
struct Data<'a> {
    digits_list: Vec<Vec<&'a [u8]>>,
    operations: Box<[Operation]>,
}

#[derive(Debug)]
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
    fn zero(&self) -> usize {
        match self {
            Self::Add => 0,
            Self::Mul => 1,
        }
    }

    fn compute(&self, iter: impl Iterator<Item = usize>) -> usize {
        iter.fold(self.zero(), |acc, x| self.apply(acc, x))
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
            let column = data.digits_list.iter().map(|list| list[i]);

            data.operations[i].compute(
                column.map(|digits| std::str::from_utf8(digits).unwrap().trim().parse().unwrap()),
            )
        })
        .sum()
}

fn answer2(data: &Data) -> usize {
    (0..(data.operations.len()))
        .map(|i| {
            let column = data.digits_list.iter().map(|list| list[i]);
            let computed_digits = column.fold(Vec::new(), |mut acc, digits| {
                if acc.is_empty() {
                    acc.resize(digits.len(), 0);
                }
                acc.iter_mut().zip(digits).for_each(|(x, digit)| {
                    if *digit != b' ' {
                        *x *= 10;
                        *x += (digit - b'0') as usize;
                    }
                });
                acc
            });
            data.operations[i].compute(computed_digits.into_iter())
        })
        .sum()
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let data = parse_input(&input).unwrap();

    let ans = answer1(&data);
    println!("Answer 1: {:?}", ans);

    let ans = answer2(&data);
    println!("Answer 2: {:?}", ans);
}

fn parse_input<'a>(input: &'a str) -> Result<Data<'a>, String> {
    let lines: Vec<&[u8]> = input.trim_end().lines().map(|l| l.as_bytes()).collect();
    assert!(!lines.is_empty());

    let longest_line = lines.iter().map(|l| l.len()).max().unwrap();
    let breaks = (0..longest_line).filter(|i| {
        lines
            .iter()
            .all(|line| line.get(*i).unwrap_or(&b' ') == &b' ')
    });

    let mut prev = 0;
    let mut digits: Vec<Vec<&[u8]>> = vec![Vec::new(); lines.len() - 1];
    for b in breaks.chain([lines[0].len()]) {
        for i in 0..digits.len() {
            digits[i].push(&lines[i][prev..b]);
        }
        prev = b + 1;
    }

    let operations = std::str::from_utf8(lines.last().unwrap())
        .unwrap()
        .split_ascii_whitespace()
        .map(|op| match op.as_bytes() {
            [c] => (*c).try_into(),
            _ => Err(format!("Invalid op {}", op)),
        })
        .collect::<Result<Box<_>, String>>()?;

    Ok(Data {
        digits_list: digits,
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

        assert_eq!(answer2(&parse_input(input).unwrap()), 3263827);
    }
}
