use nom::{
    branch::alt,
    bytes::complete::tag,
    character::complete::{char, i32, line_ending},
    multi::separated_list1,
};

#[derive(Debug)]
struct Reveal {
    red: i32,
    green: i32,
    blue: i32,
}

impl Reveal {
    fn new() -> Reveal {
        Reveal {
            red: 0,
            green: 0,
            blue: 0,
        }
    }

    fn from_pairs(pairs: &[(i32, &str)]) -> Result<Reveal, String> {
        let mut red = 0;
        let mut green = 0;
        let mut blue = 0;

        for (count, s) in pairs {
            match *s {
                "red" => {
                    red = *count;
                }
                "green" => {
                    green = *count;
                }
                "blue" => {
                    blue = *count;
                }
                _ => return Err(format!("unexpected color: '{}'", s)),
            }
        }

        Ok(Reveal { red, green, blue })
    }

    fn max(&self, other: &Reveal) -> Reveal {
        Reveal {
            red: self.red.max(other.red),
            green: self.green.max(other.green),
            blue: self.blue.max(other.blue),
        }
    }

    fn power(&self) -> i32 {
        self.red * self.green * self.blue
    }
}

#[derive(Debug)]
struct Game {
    id: i32,
    reveals: Vec<Reveal>,
}

fn parse_pair(input: &str) -> nom::IResult<&str, (i32, &str)> {
    let (input, _) = char(' ')(input)?;
    let (input, count) = i32(input)?;
    let (input, _) = char(' ')(input)?;
    let mut color_parser = alt((tag("red"), tag("green"), tag("blue")));
    let (input, color) = color_parser(input)?;

    Ok((input, (count, color)))
}

fn parse_reveal(input: &str) -> nom::IResult<&str, Reveal> {
    let (input, pairs) = separated_list1(char(','), parse_pair)(input)?;

    Ok((input, Reveal::from_pairs(&pairs).unwrap()))
}

fn parse_game(input: &str) -> nom::IResult<&str, Game> {
    let (input, _) = tag("Game ")(input)?;
    let (input, id) = i32(input)?;
    let (input, _) = char(':')(input)?;
    let (input, reveals) = separated_list1(char(';'), parse_reveal)(input)?;

    Ok((input, Game { id, reveals }))
}

fn parse_data(input: &str) -> Vec<Game> {
    separated_list1(line_ending, parse_game)(input).unwrap().1
}

fn is_valid(game: &Game) -> bool {
    let min_count = min_counts(game);

    min_count.red <= 12 && min_count.green <= 13 && min_count.blue <= 14
}

fn min_counts(game: &Game) -> Reveal {
    game.reveals.iter().fold(Reveal::new(), |a, b| a.max(b))
}

fn answer1(input: &[Game]) -> i32 {
    input
        .iter()
        .filter(|game| is_valid(game))
        .map(|game| game.id)
        .sum()
}

fn answer2(input: &[Game]) -> i32 {
    input.iter().map(|game| min_counts(game).power()).sum()
}

pub fn answer(path: &str) {
    let data = std::fs::read_to_string(path).unwrap();

    let input = parse_data(&data);

    let ans1 = answer1(&input);
    println!("answer1: {}", ans1);

    let ans2 = answer2(&input);
    println!("answer2: {}", ans2);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test() {
        let data = include_str!("test.txt");

        let input = parse_data(data);

        assert_eq!(answer1(&input), 8);
    }

    #[test]
    fn test2() {
        let data = include_str!("test.txt");

        let input = parse_data(data);

        assert_eq!(answer2(&input), 2286);
    }
}
