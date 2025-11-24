fn find(expenses: &[u32], target: u32, count: usize) -> Option<Vec<u32>> {
    if count == 1 {
        expenses.iter().find(|&&x| x == target).map(|&x| vec![x])
    } else {
        for expense in expenses {
            if target > *expense {
                if let Some(mut result) = find(expenses, target - expense, count - 1) {
                    result.push(*expense);
                    return Some(result);
                }
            }
        }
        None
    }
}

fn answer1(expenses: &[u32]) -> Option<u32> {
    find(expenses, 2020, 2).map(|v| v.iter().product())
}

fn answer2(expenses: &[u32]) -> Option<u32> {
    find(expenses, 2020, 3).map(|v| v.iter().product())
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let expenses = parse_input(&input).unwrap();

    let ans = answer1(&expenses);
    println!("Answer 1: {:?}", ans);

    let ans = answer2(&expenses);
    println!("Answer 2: {:?}", ans);
}

fn parse_input(data: &str) -> Result<Vec<u32>, std::num::ParseIntError> {
    data.trim()
        .lines()
        .map(|line| line.parse())
        .collect::<Result<Vec<u32>, _>>()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test1() {
        let input = include_str!("test.txt");

        assert_eq!(answer1(&parse_input(input).unwrap()), Some(514579));
    }

    #[test]
    fn test2() {
        let input = include_str!("test.txt");

        assert_eq!(answer2(&parse_input(input).unwrap()), Some(241861950));
    }
}
