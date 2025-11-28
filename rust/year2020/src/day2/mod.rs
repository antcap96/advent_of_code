struct Line<'a> {
    policy: Policy,
    password: &'a [u8],
}

struct Policy {
    first: usize,
    second: usize,
    key: u8,
}

fn answer1(lines: &[Line]) -> usize {
    lines.iter().filter(|line| 
        {let count = line.password.iter().filter(|&&c| c == line.policy.key).count();
            line.policy.first <= count && line.policy.second >= count
        
        }

    ).count()
}

fn answer2(lines: &[Line]) -> usize {
    lines.iter().filter(|line| 
        (line.password[line.policy.first-1] == line.policy.key) ^
        (line.password[line.policy.second-1] == line.policy.key)
    ).count()
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let expenses = parse_input(&input).unwrap();

    let ans = answer1(&expenses);
    println!("Answer 1: {:?}", ans);

    let ans = answer2(&expenses);
    println!("Answer 2: {:?}", ans);
}

fn parse_policy(data: &[u8]) -> nom::IResult<&[u8], Policy> {
    let (data, first) = nom::character::complete::usize(data)?;
    let (data, _) = nom::bytes::complete::tag("-")(data)?;
    let (data, second) = nom::character::complete::usize(data)?;
    let (data, _) = nom::bytes::complete::tag(" ")(data)?;
    let (data, key) = nom::bytes::complete::take(1usize)(data)?;
    let key = key[0];
    Ok((data, Policy { first, second, key }))
}

fn parse_password(data: &[u8]) -> nom::IResult<&[u8], &[u8]> {
    nom::bytes::complete::take_till(|_| false)(data)
}

fn parse_line<'a>(data: &'a [u8]) -> Result<Line<'a>, nom::Err<nom::error::Error<&'a [u8]>>> {
    let (data, policy) = parse_policy(data)?;
    let (data, _) = nom::bytes::complete::tag(": ")(data)?;
    let (_, password) = parse_password(data)?;

    Ok(Line { policy, password })
}

fn parse_input<'a>(data: &'a str) -> Result<Vec<Line<'a>>, nom::Err<nom::error::Error<&'a [u8]>>> {
    data.trim()
        .lines()
        .map(|line| parse_line(line.as_bytes()))
        .collect::<Result<Vec<Line>, _>>()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test1() {
        let input = include_str!("test.txt");

        assert_eq!(answer1(&parse_input(input).unwrap()), 2);
    }

    #[test]
    fn test2() {
        let input = include_str!("test.txt");

        assert_eq!(answer2(&parse_input(input).unwrap()), 1);
    }
}
