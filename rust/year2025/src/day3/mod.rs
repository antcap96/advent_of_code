fn digit_of(x: &u8) -> usize {
    (x - b'0') as usize
}

fn joltage(bank: &str, batteries: usize) -> usize {
    let bytes = bank.as_bytes();
    assert!(bytes.len() >= batteries);
    let mut start = 0;
    let mut result = 0;
    for i in (0..batteries).rev() {
        let (index, digit) = bytes[start..(bytes.len() - i)]
            .iter()
            .enumerate()
            .max_by(|(l_idx, l_num), (r_idx, r_num)| l_num.cmp(r_num).then(r_idx.cmp(&l_idx)))
            .expect("should not be possible due to assert");
        result += digit_of(digit) * 10usize.pow(i as u32);
        start += index + 1;
    }

    result
}

fn answer1(banks: &[&str]) -> usize {
    banks.into_iter().map(|bank| joltage(bank, 2)).sum()
}

fn answer2(banks: &[&str]) -> usize {
    banks.into_iter().map(|bank| joltage(bank, 12)).sum()
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let banks = parse_input(&input);

    let ans = answer1(&banks);
    println!("Answer 1: {:?}", ans);

    let ans = answer2(&banks);
    println!("Answer 2: {:?}", ans);
}

fn parse_input(data: &str) -> Vec<&str> {
    data.trim().lines().collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test1() {
        let input = include_str!("test.txt");

        assert_eq!(answer1(&parse_input(input)), 357);
    }

    #[test]
    fn test_each_answer1() {
        assert_eq!(joltage("987654321111111", 2), 98);
        assert_eq!(joltage("811111111111119", 2), 89);
        assert_eq!(joltage("234234234234278", 2), 78);
        assert_eq!(joltage("818181911112111", 2), 92);
        assert_eq!(joltage("991", 2), 99);
    }

    #[test]
    fn test2() {
        let input = include_str!("test.txt");

        assert_eq!(answer2(&parse_input(input)), 3121910778619);
    }

    #[test]
    fn test_each_answer2() {
        assert_eq!(joltage("987654321111111", 12), 987654321111);
        assert_eq!(joltage("811111111111119", 12), 811111111119);
        assert_eq!(joltage("234234234234278", 12), 434234234278);
        assert_eq!(joltage("818181911112111", 12), 888911112111);
    }
}
