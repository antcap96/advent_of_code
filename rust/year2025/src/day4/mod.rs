use ndarray::Array2;

fn has_access(paper: &Array2<bool>, i: usize, j: usize) -> bool {
    let sub = |x: usize| x.wrapping_sub(1);
    let nop = |x: usize| x;
    let add = |x: usize| x.wrapping_add(1);
    let get = |x| *paper.get(x).unwrap_or(&false) as u8;

    (get((sub(i), sub(j)))
        + get((sub(i), nop(j)))
        + get((sub(i), add(j)))
        + get((nop(i), sub(j)))
        + get((nop(i), add(j)))
        + get((add(i), sub(j)))
        + get((add(i), nop(j)))
        + get((add(i), add(j))))
        < 4
}

fn answer1(paper: &Array2<bool>) -> usize {
    let mut count = 0;

    for i in 0..paper.nrows() {
        for j in 0..paper.ncols() {
            if !paper[(i, j)] {
                continue;
            }

            if has_access(paper, i, j) {
                count += 1;
            }
        }
    }
    count
}

fn remove_and_count(paper: &mut Array2<bool>) -> usize {
    let mut count = 0;

    for i in 0..paper.nrows() {
        for j in 0..paper.ncols() {
            if !paper[(i, j)] {
                continue;
            }

            if has_access(paper, i, j) {
                count += 1;
                paper[(i, j)] = false
            }
        }
    }
    count
}

fn answer2(paper: &Array2<bool>) -> usize {
    let mut paper = paper.clone();
    let mut count = 0;
    loop {
        let step = remove_and_count(&mut paper);
        if step == 0 {
            break;
        };
        count += step;
    }
    count
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let paper = parse_input(&input);

    let ans = answer1(&paper);
    println!("Answer 1: {:?}", ans);

    let ans = answer2(&paper);
    println!("Answer 2: {:?}", ans);
}

fn parse_input(data: &str) -> Array2<bool> {
    let rows = data.lines().count();
    let cols = data.lines().next().unwrap().bytes().count();

    let arr = ndarray::Array::from_iter(data.bytes().filter(|&b| b != b'\n').map(|b| b == b'@'));

    arr.into_shape_with_order((rows, cols)).unwrap()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test1() {
        let input = include_str!("test.txt");

        assert_eq!(answer1(&parse_input(input)), 13);
    }

    #[test]
    fn test2() {
        let input = include_str!("test.txt");

        assert_eq!(answer2(&parse_input(input)), 43);
    }
}
