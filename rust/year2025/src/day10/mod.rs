use good_lp::{
    constraint, default_solver, variable, Expression, ProblemVariables, ResolutionError, Solution,
    SolverModel,
};
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
                    .flat_map(|el| el.iter())
                    .for_each(|&idx| test[idx] = !test[idx]);
                target == test
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

fn match_joltage(target: &[usize], buttons: &[Box<[usize]>]) -> Result<usize, ResolutionError> {
    let mut joltage_contributors: Vec<Vec<usize>> = vec![vec![]; target.len()];
    for i in 0..buttons.len() {
        for button in &buttons[i] {
            joltage_contributors[*button].push(i);
        }
    }

    let mut variable_set = ProblemVariables::new();
    let variables: Vec<_> = (0..buttons.len())
        .map(|_| variable_set.add(variable().integer().min(0)))
        .collect();

    let constraints = joltage_contributors
        .iter()
        .map(|elems| {
            elems
                .iter()
                .map(|&button| variables[button])
                .sum::<Expression>()
        })
        .zip(target)
        .map(|(expr, joltage)| constraint::eq(expr, *joltage as u32));

    let button_presses = variables.iter().sum::<Expression>();

    let mut solver = variable_set
        .minimise(&button_presses)
        .using(default_solver)
        .with_all(constraints);
    solver.set_parameter("log", "0");
    solver
        .solve()
        .map(|solution| solution.eval(button_presses) as usize)
}

fn answer2(data: &[Line]) -> usize {
    data.iter()
        .map(|line| {
            match_joltage(&line.joltage, &line.buttons)
                .unwrap_or_else(|_| panic!("unable to find match for {line:?}"))
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
    fn test2() {
        let input = include_str!("test.txt");

        assert_eq!(answer2(&parse_input(input).unwrap()), 33);
    }
}
