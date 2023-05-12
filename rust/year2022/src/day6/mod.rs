use std::collections::HashMap;

pub fn answer() {
    let data = std::fs::read_to_string("year2022/src/day6/input.txt").expect("Unable to read file");

    let answer1 = find_first_n_distinct(&data, 4);
    println!("Answer 1: {:?}", answer1);

    let answer2 = find_first_n_distinct(&data, 14);
    println!("Answer 2: {:?}", answer2);
}

fn find_first_n_distinct(data: &str, n: usize) -> Option<usize> {
    let mut memory: HashMap<char, usize> = HashMap::new();
    for (i, character) in data.chars().enumerate() {
        if i >= n {
            memory.retain(|_k, &mut v| v > i - n)
        }
        memory.insert(character, i);
        if memory.len() == n {
            return Some(i + 1);
        }
    }
    return None;
}
