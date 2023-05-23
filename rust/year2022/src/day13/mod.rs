use std::fmt::Debug;

use itertools::Itertools;

#[derive(Clone)]
enum Element {
    Value(u32),
    List(Vec<Element>),
}

impl Debug for Element {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Element::Value(v) => write!(f, "{}", v),
            Element::List(l) => write!(f, "[{}]", l.iter().map(|x| format!("{:?}", x)).join(",")),
        }
    }
}

pub fn answer() {
    let data =
        std::fs::read_to_string("year2022/src/day13/input.txt").expect("Unable to read file");

    let pairs = parse_data(&data);

    dbg!(&pairs);

    let result_1 = pairs
        .iter()
        .map(|(a, b)| is_ordered(a, b))
        .enumerate()
        .map(|x| {
            dbg!(x);
            x
        })
        .filter(|(_, x)| matches!(x, Some(true)))
        .fold(0, |acc, (i, _)| acc + i + 1);

    println!("Answer 1: {}", result_1);
}

fn is_ordered(el1: &Element, el2: &Element) -> Option<bool> {
    dbg!(el1, el2);
    match (el1, el2) {
        (Element::Value(a), Element::Value(b)) => match a.cmp(b) {
            std::cmp::Ordering::Less => Some(true),
            std::cmp::Ordering::Greater => Some(false),
            std::cmp::Ordering::Equal => None,
        },
        (Element::List(l1), Element::List(l2)) => {
            for (el1, el2) in l1.iter().zip(l2.iter()) {
                let comparison = is_ordered(el1, el2);
                if comparison.is_some() {
                    return comparison;
                }
            }
            match l1.len().cmp(&l2.len()) {
                std::cmp::Ordering::Less => Some(true),
                std::cmp::Ordering::Greater => Some(false),
                std::cmp::Ordering::Equal => None,
            }
        }
        (Element::List(_), Element::Value(_)) => is_ordered(el1, &Element::List(vec![el2.clone()])),
        (Element::Value(_), Element::List(_)) => is_ordered(&Element::List(vec![el1.clone()]), el2),
    }
}

fn parse_data(data: &str) -> Vec<(Element, Element)> {
    data.lines()
        .chunks(3)
        .into_iter()
        .map(|mut chunk| {
            let mut line = chunk.next().unwrap().chars();
            let packet1 = parse_packet(&mut line);
            let mut line = chunk.next().unwrap().chars();
            let packet2 = parse_packet(&mut line);
            (packet1, packet2)
        })
        .collect()
}

fn parse_packet(line: &mut impl Iterator<Item = char>) -> Element {
    let mut output = Vec::new();

    let mut number = String::new();
    while let Some(next) = line.next() {
        match next {
            '[' => {
                output.push(parse_packet(line));
            }
            ']' => {
                if !number.is_empty() {
                    output.push(Element::Value(number.parse().unwrap()));
                    number.clear();
                }
                break;
            }
            ',' => {
                if !number.is_empty() {
                    output.push(Element::Value(number.parse().unwrap()));
                    number.clear();
                }
            }
            _ if next.is_ascii_digit() => {
                number.push(next);
            }
            _ => unreachable!(),
        }
    }

    Element::List(output)
}
