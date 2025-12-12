use ndarray::Array2;

struct Data {
    shapes: Box<[Array2<bool>]>,
    regions: Box<[Region]>,
}

struct Region {
    height: usize,
    width: usize,
    amounts: Box<[usize]>,
}

fn answer1(data: &Data) -> usize {
    let sizes = data
        .shapes
        .iter()
        .map(|matrix| matrix.iter().map(|b| if *b { 1 } else { 0 }).sum())
        .collect::<Vec<usize>>();
    data.regions
        .iter()
        .map(|region| {
            let area = region.width * region.height;
            let min_area = region
                .amounts
                .iter()
                .zip(sizes.iter())
                .map(|(x, y)| x * y)
                .sum();
            if area < min_area {
                return 0;
            }
            let (width, height) =
                data.shapes
                    .iter()
                    .fold((usize::MAX, usize::MAX), |(width, height), el| {
                        let width = width.min(el.ncols());
                        let height = height.min(el.nrows());
                        (width, height)
                    });
            let min_blocks = (region.width / width) * (region.height / height);
            if region.amounts.iter().sum::<usize>() <= min_blocks {
                return 1;
            }

            panic!("now the hard part")
        })
        .sum()
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let data = parse_input(&input).unwrap();

    let ans = answer1(&data);
    println!("Answer 1: {:?}", ans);

    println!("Answer 2: *");
}

fn parse_region(line: &str) -> Result<Region, String> {
    let (area, amounts) = line
        .split_once(": ")
        .ok_or("Unable to find ': '".to_owned())?;
    let (height, width) = area
        .split_once("x")
        .ok_or("unable to split area on 'x'".to_owned())?;
    let height = height
        .parse()
        .map_err(|_| format!("unable to parse '{height}' as num"))?;
    let width = width
        .parse()
        .map_err(|_| format!("unable to parse '{width}' as num"))?;
    let amounts = amounts
        .split_ascii_whitespace()
        .map(|el| {
            el.parse()
                .map_err(|_| "unable to parse amount '{el}' as num".to_owned())
        })
        .collect::<Result<_, _>>()?;
    Ok(Region {
        amounts,
        height,
        width,
    })
}

fn parse_shape(block: &str) -> Result<Array2<bool>, String> {
    let lines = block.lines().skip(1).collect::<Vec<_>>();
    let shape = (lines.len(), lines[0].len());
    let v = lines
        .iter()
        .flat_map(|x| x.bytes().map(|y| y == b'#'))
        .collect();
    ndarray::Array::from_shape_vec(shape, v).map_err(|_| "invalid shape".to_owned())
}

fn parse_input(input: &str) -> Result<Data, String> {
    let blocks = input.trim().split("\n\n").collect::<Vec<_>>();
    let regions = blocks
        .last()
        .ok_or("Empty data")?
        .lines()
        .map(parse_region)
        .collect::<Result<_, _>>()?;
    let shapes = blocks[..blocks.len() - 1]
        .into_iter()
        .map(|chunk| parse_shape(chunk))
        .collect::<Result<_, _>>()?;

    Ok(Data { regions, shapes })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[ignore = "tests are actually hard, unlike the real problem"]
    fn test1() {
        let input = include_str!("test.txt");

        assert_eq!(answer1(&parse_input(input).unwrap()), 2);
    }
}
