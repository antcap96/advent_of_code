use std::collections::HashSet;

fn main() {
    answer();
}

fn answer() {
    let data = std::fs::read_to_string("input").expect("Failed to load data");

    let data = parse_data(&data);

    let cost = get_rucksacks_error_cost(&data);

    println!("Rucksacks cost: {}", cost);

    let cost = get_elves_badges_cost(&data);

    println!("Elves cost: {}", cost);
}

fn get_elves_badges_cost(data: &[String]) -> u32 {
    let groups = data.chunks(3);

    let chars: Vec<char> = groups
        .map(|group| {
            group
                .iter()
                .map(|rucksack| rucksack.chars().collect::<HashSet<_>>())
                .reduce(|mut acc, group| {
                    acc.retain(|c| group.contains(c));
                    acc
                })
                .expect("Chucks should not be empty")
                .iter()
                .next()
                .expect("Chucks of 3 should have at least one common char")
                .clone()
        })
        .collect();

    error_cost(&chars)
}

fn get_rucksacks_error_cost(data: &[String]) -> u32 {
    let compartments = split_rucksacks(&data);

    let errors = get_errors(&compartments);

    let cost = error_cost(&errors);
    cost
}

fn parse_data(data: &str) -> Vec<String> {
    data.lines().map(|line| line.to_owned()).collect()
}

fn split_rucksacks(data: &[String]) -> Vec<(String, String)> {
    data.iter()
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

fn error_cost(errors: &Vec<char>) -> u32 {
    errors
        .iter()
        .map(|&c| {
            if c.is_lowercase() {
                c as u32 - 'a' as u32 + 1
            } else {
                c as u32 - 'A' as u32 + 27
            }
        })
        .sum()
}
