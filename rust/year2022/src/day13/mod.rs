use std::{fmt::Debug, str::FromStr};

#[derive(Clone)]
enum Element {
    Value(u32),
    List(Vec<Element>),
}

impl Element {
    fn list_of(element: Element) -> Element {
        Element::List(vec![element])
    }
}

impl FromStr for Element {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut chars = s.chars();
        if chars.next() == Some('[') {
            parse_element_list(&mut chars)
        } else {
            Ok(Element::Value(s.parse().map_err(|_| ())?))
        }
    }
}

fn parse_element_list(line: &mut impl Iterator<Item = char>) -> Result<Element, ()> {
    let mut output = Vec::new();

    let mut number = String::new();
    while let Some(next) = line.next() {
        match next {
            '[' => {
                output.push(parse_element_list(line)?);
            }
            _ if next.is_ascii_digit() => {
                number.push(next);
            }
            ']' | ',' => {
                if !number.is_empty() {
                    output.push(Element::Value(number.parse().map_err(|_| ())?));
                    number.clear();
                }
                if next == ']' {
                    break;
                }
            }
            _ => Err(())?,
        }
    }

    Ok(Element::List(output))
}

impl Debug for Element {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Element::Value(v) => write!(f, "{}", v),
            Element::List(l) => f.debug_list().entries(l.iter()).finish(),
        }
    }
}

fn ordering(element1: &Element, element2: &Element) -> std::cmp::Ordering {
    match (element1, element2) {
        (Element::Value(value1), Element::Value(value2)) => value1.cmp(value2),
        (Element::List(list1), Element::List(list2)) => {
            for (el1, el2) in list1.iter().zip(list2.iter()) {
                let comparison = ordering(el1, el2);
                if comparison != std::cmp::Ordering::Equal {
                    return comparison;
                }
            }
            list1.len().cmp(&list2.len())
        }
        (Element::List(_), Element::Value(_)) => {
            ordering(element1, &Element::List(vec![element2.clone()]))
        }
        (Element::Value(_), Element::List(_)) => {
            ordering(&Element::List(vec![element1.clone()]), element2)
        }
    }
}

impl PartialEq for Element {
    fn eq(&self, other: &Self) -> bool {
        ordering(self, other) == std::cmp::Ordering::Equal
    }
}

impl Eq for Element {}

impl PartialOrd for Element {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(ordering(self, other))
    }
}

impl Ord for Element {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        ordering(self, other)
    }
}

pub fn answer() {
    let data =
        std::fs::read_to_string("year2022/src/day13/input.txt").expect("Unable to read file");

    let elements = parse_data(&data);

    let result1 = answer1(&elements);
    println!("Answer 1: {}", result1);

    let result2 = answer2(&elements);
    println!("Answer 2: {}", result2);
}

fn answer1(elements: &[Element]) -> u32 {
    let pairs = elements.chunks(2).map(|chunk| {
        let a = &chunk[0];
        let b = &chunk[1];
        (a, b)
    });

    pairs
        .zip(1..)
        .filter(|((a, b), _)| a < b)
        .fold(0, |acc, (_, i)| acc + i)
}

fn answer2(elements: &[Element]) -> u32 {
    let divider1 = Element::list_of(Element::list_of(Element::Value(2)));
    let divider2 = Element::list_of(Element::list_of(Element::Value(6)));

    let idx1 = elements.iter().filter(|el| **el < divider1).count() + 1;
    let idx2 = elements.iter().filter(|el| **el < divider2).count() + 2; // +1 for divider1

    idx1 as u32 * idx2 as u32
}

fn parse_data(data: &str) -> Vec<Element> {
    data.lines()
        .filter(|line| !line.is_empty())
        .map(|line| line.parse().unwrap())
        .collect()
}
