use std::error::Error;

struct ForestIter {
    row: usize,
    col: usize,
    row_step: usize,
    col_step: usize,
    ncols: usize,
    nrows: usize,
}

impl ForestIter {
    fn new(nrows: usize, ncols: usize, row_step: usize, col_step: usize) -> Self {
        Self {
            row: 0,
            col: 0,
            nrows,
            ncols,
            row_step,
            col_step,
        }
    }

    fn count_trees(self, forest: &ndarray::Array2<bool>) -> usize {
        self.map(|idx| forest[idx])
            .filter(|&x| x)
            .count()
    }
}

impl Iterator for ForestIter {
    type Item = (usize, usize);

    fn next(&mut self) -> Option<Self::Item> {
        self.row += self.row_step;
        self.col += self.col_step;
        self.col %= self.ncols;

        (self.row < self.nrows).then_some((self.row, self.col))
    }
}

fn answer1(forest: &ndarray::Array2<bool>) -> usize {
    let ncols = forest.ncols();
    let nrows = forest.nrows();
    let iter = ForestIter::new(nrows, ncols, 1, 3);

    iter.count_trees(forest)
}

fn answer2(forest: &ndarray::Array2<bool>) -> usize {
    let ncols = forest.ncols();
    let nrows = forest.nrows();

    let iter = [
        ForestIter::new(nrows, ncols, 1, 1),
        ForestIter::new(nrows, ncols, 1, 3),
        ForestIter::new(nrows, ncols, 1, 5),
        ForestIter::new(nrows, ncols, 1, 7),
        ForestIter::new(nrows, ncols, 2, 1),
    ];

    iter.into_iter()
        .map(|iter| iter.count_trees(forest))
        .product()
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let forest = parse_input(&input).unwrap();

    let ans = answer1(&forest);
    println!("Answer 1: {:?}", ans);

    let ans = answer2(&forest);
    println!("Answer 2: {:?}", ans);
}

fn parse_input(data: &str) -> Result<ndarray::Array2<bool>, &dyn Error> {
    // This is terible, not sure how to create the matrix without alocation extra memory.
    let parsed = data
        .lines()
        .map(|line| line.chars().map(|c| c == '#').collect::<Vec<_>>())
        .collect::<Vec<_>>();

    let columns = parsed[0].len();

    Ok(ndarray::Array::from_shape_vec(
        (parsed.len(), columns),
        parsed.into_iter().flatten().collect(),
    )
    .unwrap())
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

        assert_eq!(answer2(&parse_input(input).unwrap()), 336);
    }
}
