pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let mut calories = parse_data(&input);

    calories.sort_unstable();

    let maximum = calories.last().expect("should not be empty");
    let total: i32 = calories.iter().rev().take(3).sum();

    println!("maximum: {}", maximum);
    println!("top3: {}", total);
}

fn parse_data(data: &str) -> Vec<i32> {
    let elves_calories = data.split("\n\n");

    let elves_total_calories = elves_calories.map(|elf_calories| {
        elf_calories
            .split('\n')
            .map(|value| {
                if value.is_empty() {
                    0
                } else {
                    value
                        .parse::<i32>()
                        .expect("failed to parse calories as int")
                }
            })
            .sum::<i32>()
    });

    elves_total_calories.collect::<Vec<_>>()
}
