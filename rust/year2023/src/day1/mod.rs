use std::str::Chars;

trait CharsStartsWith {
    fn starts_with(&self, s: &str) -> bool;
}

impl<'a> CharsStartsWith for Chars<'a> {
    fn starts_with(&self, name: &str) -> bool {
        self.clone().take(name.len()).eq(name.chars())
    }
}

struct DigitIter<'a> {
    chars: Chars<'a>,
}

impl<'a> Iterator for DigitIter<'a> {
    type Item = i32;

    fn next(&mut self) -> Option<Self::Item> {
        for ch in self.chars.by_ref() {
            if ch.is_ascii_digit() {
                return Some(digit_to_int(ch));
            }
        }
        None
    }
}

impl<'a> DigitIter<'a> {
    fn new(chars: Chars<'a>) -> DigitIter<'a> {
        DigitIter { chars }
    }
}

struct DigitSpelledOutIter<'a> {
    chars: Chars<'a>,
}

const SPELLED_OUT: [(&str, i32); 9] = [
    ("one", 1),
    ("two", 2),
    ("three", 3),
    ("four", 4),
    ("five", 5),
    ("six", 6),
    ("seven", 7),
    ("eight", 8),
    ("nine", 9),
];

impl<'a> Iterator for DigitSpelledOutIter<'a> {
    type Item = i32;

    fn next(&mut self) -> Option<Self::Item> {
        loop {
            for (name, value) in SPELLED_OUT {
                if self.chars.starts_with(name) {
                    self.chars.next();
                    return Some(value);
                }
            }
            match self.chars.next() {
                Some(ch) if ch.is_ascii_digit() => {
                    return Some(digit_to_int(ch));
                }
                Some(_) => continue,
                None => return None,
            }
        }
    }
}

impl<'a> DigitSpelledOutIter<'a> {
    fn new(chars: Chars<'a>) -> DigitSpelledOutIter<'a> {
        DigitSpelledOutIter { chars }
    }
}

fn digit_to_int(ch: char) -> i32 {
    ch as i32 - '0' as i32
}

fn answer1(input: &str) -> i32 {
    input
        .lines()
        .map(|line| calibration_value(DigitIter::new(line.chars())))
        .sum()
}

fn answer2(input: &str) -> i32 {
    input
        .lines()
        .map(|line| calibration_value(DigitSpelledOutIter::new(line.chars())))
        .sum()
}

fn calibration_value(mut iter: impl Iterator<Item = i32>) -> i32 {
    let first = iter.next().expect("at least 1 digit per line");
    let last = iter.last().unwrap_or(first);

    first * 10 + last
}

pub fn answer() {
    let input = include_str!("input.txt");

    let ans1 = answer1(input);
    println!("answer1: {}", ans1);

    let ans2 = answer2(input);
    println!("answer2: {}", ans2);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test1() {
        let input = include_str!("test1.txt");

        assert_eq!(answer1(input), 142);
    }

    #[test]
    fn test2() {
        let input = include_str!("test2.txt");

        assert_eq!(answer2(input), 281);
    }
}
