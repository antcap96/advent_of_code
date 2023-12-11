use ndarray;

fn parse_data(data: &str) -> ndarray::Array2<i64> {
    let cols = data.lines().next().unwrap().len();
    let test = data
        .lines()
        .map(|line| {
            line.chars().map(|c| match c {
                '.' => 0,
                '#' => 1,
                _ => panic!("invalid char '{}' in input", c),
            })
        })
        .flatten()
        .collect::<Vec<_>>();

    ndarray::Array2::from_shape_vec((test.len()/cols, cols), test).unwrap()
}

pub fn answer() {
    let data = include_str!("input.txt");

    let input = parse_data(data);

    let ans1 = answer1(&input);
    let ans2 = answer2(&input);

    println!("answer1: {}", ans1);
    println!("answer1: {}", ans2);
}

fn answer_(input: &ndarray::Array2<i64>, expansion_factor: i64) -> i64 {
    let sum = input.sum();

    (0..=1)
        .into_iter()
        .map(|i| {
            let n_galaxies = input.sum_axis(ndarray::Axis(i));

            let cum_sum = n_galaxies.iter().scan(0, |state, &x| {
                let res = *state;
                *state += x;
                Some(res)
            });

            let times_traveled = cum_sum
                .clone()
                .zip(cum_sum.map(|x| sum - x))
                .map(|(x, y)| x * y);

            let weights = n_galaxies
                .iter()
                .map(|&x| if x == 0 { expansion_factor } else { 1 });

            weights.zip(times_traveled).map(|(x, y)| x * y).sum::<i64>()
        })
        .sum()
}

fn answer1(input: &ndarray::Array2<i64>) -> i64 {
    answer_(input, 2)
}

fn answer2(input: &ndarray::Array2<i64>) -> i64 {
    answer_(input, 1_000_000)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test() {
        let data = include_str!("test.txt");

        let input = parse_data(data);

        assert_eq!(answer1(&input), 374);
    }

    #[test]
    fn test_10() {
        let data = include_str!("test.txt");

        let input = parse_data(data);

        assert_eq!(answer_(&input, 10), 1030);
    }

    #[test]
    fn test_100() {
        let data = include_str!("test.txt");

        let input = parse_data(data);

        assert_eq!(answer_(&input, 100), 8410);
    }
}
