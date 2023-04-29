use std::collections::HashSet;

fn main() {
    answer();
}

fn answer() {
    let data = std::fs::read_to_string("input").expect("Failed to load data");

    let rucksacks = parse_data(&data);

    let errors = get_errors(&rucksacks);

    let cost = error_cost(errors);

    println!("Cost: {}", cost);
}

fn parse_data(data: &str) -> Vec<(String, String)> {
    data.lines()
        .map(|line| {
            let line_len = line.len();
            let a = line[..(line_len / 2)].to_owned();
            let b = line[(line_len / 2)..].to_owned();
            (a, b)
        })
        .collect()
}

fn get_errors(rucksacks: &[(String, String)]) -> Vec<char> {
    let differences = rucksacks.iter().map(|(a, b)| {
        let a_chars = a.chars().collect::<HashSet<_>>();
        let b_chars = b.chars().collect::<HashSet<_>>();
        a_chars.intersection(&b_chars).next().unwrap().clone()
    });

    differences.collect()
}

fn error_cost(errors: Vec<char>) -> u32 {
    errors.iter().map(|&c| 
        if c.is_lowercase() {
            c as u32 - 'a' as u32 + 1
        } else {
            c as u32 - 'A' as u32 + 27
        }
    ).sum()
}
