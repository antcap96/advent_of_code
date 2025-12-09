use itertools::Itertools;

#[derive(Debug)]
struct Point {
    x: usize,
    y: usize,
}

fn answer1(data: &[Point]) -> usize {
    data.iter()
        .cartesian_product(data.iter())
        .map(|(p1, p2)| (p1.x.abs_diff(p2.x) + 1) * (p1.y.abs_diff(p2.y) + 1))
        .max()
        .expect("non empty data")
}

fn intersects(amin: usize, amax: usize, b1: usize, b2: usize) -> bool {
    let bmin = b1.min(b2);
    let bmax = b1.max(b2);
    let arange = amin..=amax;
    arange.contains(&b1) || arange.contains(&b2) || (bmin < amin && bmax > amax)
}

fn answer2(data: &[Point]) -> usize {
    data.iter()
        .cartesian_product(data.iter())
        .filter(|(p1, p2)| {
            let mut lines = data
                .iter()
                .zip(data.iter().skip(1).chain(std::iter::once(&data[0])));
            !lines.any(|(p3, p4)| {
                let xmin = p1.x.min(p2.x);
                let xmax = p1.x.max(p2.x);
                let ymin = p1.y.min(p2.y);
                let ymax = p1.y.max(p2.y);

                if p3.x == p4.x {
                    ((xmin + 1)..=(xmax - 1)).contains(&p3.x) && intersects(ymin, ymax, p3.y, p4.y)
                } else {
                    ((ymin + 1)..=(ymax - 1)).contains(&p3.y) && intersects(xmin, xmax, p3.x, p4.x)
                }
            })
        })
        .map(|(p1, p2)| (p1.x.abs_diff(p2.x) + 1) * (p1.y.abs_diff(p2.y) + 1))
        .max()
        .expect("non empty data")
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let data = parse_input(&input).unwrap();

    let ans = answer1(&data);
    println!("Answer 1: {:?}", ans);

    let ans = answer2(&data);
    println!("Answer 2: {:?}", ans);
}

fn parse_point(line: &str) -> Result<Point, String> {
    let err = || format!("Failled to parse '{line}' as num");

    let mut iter = line
        .split(',')
        .map(|num| num.parse::<usize>().map_err(|_| err()));

    Ok(Point {
        x: iter.next().ok_or_else(err)??,
        y: iter.next().ok_or_else(err)??,
    })
}

fn parse_input(input: &str) -> Result<Box<[Point]>, String> {
    input
        .trim()
        .lines()
        .map(parse_point)
        .collect::<Result<Box<_>, _>>()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test1() {
        let input = include_str!("test.txt");

        assert_eq!(answer1(&parse_input(input).unwrap()), 50);
    }

    #[test]
    fn test2() {
        let input = include_str!("test.txt");

        assert_eq!(answer2(&parse_input(input).unwrap()), 24);
    }
}
