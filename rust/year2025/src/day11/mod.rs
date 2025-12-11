use std::collections::{hash_map, HashMap};

struct Data<'a> {
    connections: HashMap<&'a str, Box<[&'a str]>>,
}

fn bfs<'a>(
    cache: &mut HashMap<&'a str, usize>,
    connections: &'a HashMap<&str, Box<[&str]>>,
    at: &'a str,
) -> usize {
    if let hash_map::Entry::Occupied(entry) = cache.entry(at) {
        return *entry.get();
    };
    let value = connections
        .get(at)
        .map(|neighboors| {
            neighboors
                .iter()
                .map(|next| bfs(cache, connections, next))
                .sum()
        })
        .unwrap_or(0);
    
    cache.insert(at, value);

    value
}

fn count_paths<'a>(
    connections: &'a HashMap<&str, Box<[&str]>>,
    from: &'a str,
    to: &'a str,
) -> usize {
    let mut cache = HashMap::from_iter(std::iter::once((to, 1)));

    bfs(&mut cache, connections, from)
}

fn answer1(data: &Data) -> usize {
    count_paths(&data.connections, "you", "out")
}

fn answer2(data: &Data) -> usize {

    let path1 = count_paths(&data.connections, "svr", "fft")
        * count_paths(&data.connections, "fft", "dac")
        * count_paths(&data.connections, "dac", "out");
    let path2 = count_paths(&data.connections, "svr", "dac")
        * count_paths(&data.connections, "dac", "fft")
        * count_paths(&data.connections, "fft", "out");

    path1 + path2
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let instructions = parse_input(&input).unwrap();

    let ans = answer1(&instructions);
    println!("Answer 1: {:?}", ans);

    let ans = answer2(&instructions);
    println!("Answer 2: {:?}", ans);
}

fn parse_input<'a>(data: &'a str) -> Result<Data<'a>, String> {
    let connections = data
        .trim()
        .lines()
        .map(|line| {
            let (from, to) = line
                .split_once(": ")
                .ok_or(format!("unable to find delimitor in '{line}'"))?;

            let to: Box<[&str]> = to.split_whitespace().collect();

            Ok((from, to))
        })
        .collect::<Result<_, String>>()?;

    Ok(Data { connections })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test1() {
        let input = include_str!("test1.txt");

        assert_eq!(answer1(&parse_input(input).unwrap()), 5);
    }

    #[test]
    fn test2() {
        let input = include_str!("test2.txt");

        assert_eq!(answer2(&parse_input(input).unwrap()), 2);
    }
}
