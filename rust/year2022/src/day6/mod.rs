use std::collections::HashMap;

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let answer1 = find_first_n_distinct(&input, 4);
    println!("Answer 1: {:?}", answer1);

    let answer2 = find_first_n_distinct(&input, 14);
    println!("Answer 2: {:?}", answer2);
}

fn find_first_n_distinct(data: &str, n: usize) -> Option<usize> {
    let mut memory: HashMap<char, usize> = HashMap::new();

    for (i, character) in data.chars().enumerate().take(n) {
        memory.insert(character, i);
    }

    for (idx, (removed, new)) in data.chars().zip(data.chars().skip(n)).enumerate() {
        if memory.len() == n {
            return Some(idx + n);
        }

        // Remove the oldest character if it hasn't appeared since
        if memory.get(&removed) == Some(&idx) {
            memory.remove(&removed);
        }

        memory.insert(new, idx + n);
    }
    None
}
