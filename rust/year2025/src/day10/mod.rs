use itertools::Itertools;

#[derive(Debug)]
struct Line {
    lights: Box<[bool]>,
    buttons: Box<[Box<[usize]>]>,
    joltage: Box<[usize]>,
}

fn parse_lights(text: &str) -> Result<Box<[bool]>, String> {
    text.strip_prefix("[")
        .and_then(|text| text.strip_suffix("]"))
        .map(|text| text.bytes().map(|b| b == b'#').collect::<Box<[bool]>>())
        .ok_or("Incorrect *fixes in lights".to_owned())
}

fn parse_button(text: &str) -> Result<Box<[usize]>, String> {
    text.strip_prefix("(")
        .and_then(|text| text.strip_suffix(")"))
        .ok_or("Incorrect *fixes in button".to_owned())
        .and_then(|text| {
            text.split(',')
                .map(|num| {
                    num.parse()
                        .map_err(|_| format!("Failed to parse num '{num}'"))
                })
                .collect::<Result<Box<[usize]>, String>>()
        })
}

fn parse_joltage(text: &str) -> Result<Box<[usize]>, String> {
    text.strip_prefix("{")
        .and_then(|text| text.strip_suffix("}"))
        .ok_or("Incorrect *fixes in joltage".to_owned())
        .and_then(|text| {
            text.split(',')
                .map(|num| {
                    num.parse()
                        .map_err(|_| format!("Failed to parse num '{num}'"))
                })
                .collect::<Result<Box<[usize]>, String>>()
        })
}

fn parse_line(text: &str) -> Result<Line, String> {
    let mut chunks = text.split_ascii_whitespace().peekable();
    let lights = chunks
        .next()
        .ok_or(format!("Missing lights '{text}'"))
        .and_then(parse_lights)?;

    let buttons = chunks
        .peeking_take_while(|str| !str.starts_with("{"))
        .map(parse_button)
        .collect::<Result<_, _>>()?;

    let joltage = chunks
        .next()
        .ok_or(format!("Missing joltage '{text}'"))
        .and_then(parse_joltage)?;

    Ok(Line {
        lights,
        buttons,
        joltage,
    })
}

fn match_lights(target: &[bool], buttons: &[Box<[usize]>]) -> usize {
    let mut test: Vec<bool> = vec![false; target.len()];
    for depth in 1.. {
        if buttons
            .iter()
            .combinations_with_replacement(depth)
            .any(|items| {
                test.iter_mut().for_each(|el| *el = false);
                items
                    .iter()
                    .map(|el| el.iter())
                    .flatten()
                    .for_each(|&idx| test[idx] = !test[idx]);
                target.as_ref() == test
            })
        {
            return depth;
        }
    }
    unreachable!("infinite loop");
}

fn answer1(data: &[Line]) -> usize {
    data.iter()
        .map(|line| match_lights(&line.lights, &line.buttons))
        .sum()
}

fn match_joltage(
    test: &mut Vec<usize>,
    target: &[usize],
    buttons: &[Box<[usize]>],
) -> Option<usize> {
    if test == target {
        return Some(0);
    }
    let mut min: Option<usize> = None;
    for button in buttons {
        button.iter().for_each(|&idx| test[idx] += 1);
        if test.iter().zip(target.iter()).any(|(x, t)| x > t) {
            button.iter().for_each(|&idx| test[idx] -= 1);
            continue;
        }
        min = match (min, match_joltage(test, target, buttons)) {
            (Some(a), Some(b)) => Some(a.min(b + 1)),
            (None, Some(b)) => Some(b + 1),
            (Some(a), None) => Some(a),
            (None, None) => None,
        };
        button.iter().for_each(|&idx| test[idx] -= 1);
    }
    min
}

fn answer2(data: &[Line]) -> usize {
    data.iter()
        .enumerate()
        .map(|(i, line)| {
            dbg!(i);
            let mut test = vec![0; line.joltage.len()];
            match_joltage(&mut test, &line.joltage, &line.buttons)
                .expect(&format!("unable to find match for {line:?}"))
        })
        .sum()
}

pub fn answer(path: &str) {
    // let mut test = vec![0; 4];
    // let target = vec![3, 5, 4, 7];
    // let buttons = [Box::from(vec![3]), Box::from(vec![1, 3]), Box::from(vec![2]), Box::from(vec![2, 3]), Box::from(vec![0, 2]), Box::from(vec![0, 1])];
    // dbg!(match_joltage(&mut test, &target, &buttons));
    // return;

    let input = std::fs::read_to_string(path).unwrap();

    let data = parse_input(&input).unwrap();

    let ans = answer1(&data);
    println!("Answer 1: {:?}", ans);

    let ans = answer2(&data);
    println!("Answer 2: {:?}", ans);
}

fn parse_input(input: &str) -> Result<Box<[Line]>, String> {
    input
        .trim()
        .lines()
        .map(parse_line)
        .collect::<Result<Box<_>, _>>()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test1() {
        let input = include_str!("test.txt");

        assert_eq!(answer1(&parse_input(input).unwrap()), 7);
    }

    #[test]
    #[ignore]
    fn test2() {
        let input = include_str!("test.txt");

        assert_eq!(answer2(&parse_input(input).unwrap()), 33);
    }
}
