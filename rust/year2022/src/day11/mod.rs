use itertools::Itertools;
use std::collections::{HashMap, VecDeque};

struct NumberRemainder {
    storage: HashMap<i32, i32>,
}

/// Stores the remainder of a number in a hashmap for a given set of denominators.
impl NumberRemainder {
    fn from_i32(i: &i32, denominators: &[i32]) -> Self {
        let mut storage = HashMap::new();
        for denominator in denominators {
            storage.insert(*denominator, i % denominator);
        }
        Self { storage }
    }

    fn is_divisible_by(&self, denominator: &i32) -> bool {
        self.storage[denominator] == 0
    }

    fn add_i32(&self, other: &i32) -> Self {
        Self {
            storage: self
                .storage
                .iter()
                .map(|(k, v)| (*k, (v + other) % k))
                .collect(),
        }
    }

    fn add_number_remainder(&self, other: &Self) -> Self {
        Self {
            storage: self
                .storage
                .keys()
                .map(|k| (*k, (self.storage[k] + other.storage[k]) % k))
                .collect(),
        }
    }

    fn mul_i32(&self, other: &i32) -> Self {
        Self {
            storage: self
                .storage
                .iter()
                .map(|(k, v)| (*k, (v * other) % k))
                .collect(),
        }
    }

    fn mul_number_remainder(&self, other: &Self) -> Self {
        Self {
            storage: self
                .storage
                .keys()
                .map(|k| (*k, (self.storage[k] * other.storage[k]) % k))
                .collect(),
        }
    }
}

type Monkey1Operation = Box<dyn Fn(i32) -> i32>;
struct Monkey1 {
    items: VecDeque<i32>,
    operation: Monkey1Operation,
    test_divisible_by: i32,
    true_condition_id: usize,
    false_condition_id: usize,
}

type Monkey2Operation = Box<dyn Fn(NumberRemainder) -> NumberRemainder>;
struct Monkey2 {
    items: VecDeque<NumberRemainder>,
    operation_remainder: Monkey2Operation,
    test_divisible_by: i32,
    true_condition_id: usize,
    false_condition_id: usize,
}

pub fn answer() {
    let data =
        std::fs::read_to_string("year2022/src/day11/input.txt").expect("Unable to read file");

    let (monkeys, monkeys2) = parse_data(&data);

    let monkey_business = answer1(monkeys);
    println!("{:?}", monkey_business);

    let monkey_business2 = answer2(monkeys2);
    println!("{:?}", monkey_business2);
}

fn answer1(mut monkeys: Vec<Monkey1>) -> usize {
    let counts = inspect_count1(&mut monkeys);

    #[allow(clippy::let_and_return)]
    let monkey_business = counts
        .into_iter()
        .sorted_by(|a, b| b.cmp(a))
        .take(2)
        .product::<usize>();
    monkey_business
}

fn inspect_count1(monkeys: &mut Vec<Monkey1>) -> Vec<usize> {
    let mut count = vec![0; monkeys.len()];

    for _round in 0..20 {
        for monkey_id in 0..monkeys.len() {
            while let Some(item) = monkeys[monkey_id].items.pop_front() {
                count[monkey_id] += 1;

                let new_item = (monkeys[monkey_id].operation)(item) / 3;
                let id_to = if new_item % monkeys[monkey_id].test_divisible_by == 0 {
                    monkeys[monkey_id].true_condition_id
                } else {
                    monkeys[monkey_id].false_condition_id
                };
                monkeys[id_to].items.push_back(new_item);
            }
        }
    }

    count
}

fn answer2(mut monkeys: Vec<Monkey2>) -> usize {
    let counts = inspect_count2(&mut monkeys);

    #[allow(clippy::let_and_return)]
    let monkey_business = counts
        .into_iter()
        .sorted_by(|a, b| b.cmp(a))
        .take(2)
        .product::<usize>();
    monkey_business
}

fn inspect_count2(monkeys: &mut Vec<Monkey2>) -> Vec<usize> {
    let mut count = vec![0; monkeys.len()];

    for _round in 0..10000 {
        for monkey_id in 0..monkeys.len() {
            while let Some(item) = monkeys[monkey_id].items.pop_front() {
                count[monkey_id] += 1;

                let new_item = (monkeys[monkey_id].operation_remainder)(item);
                let id_to = if new_item.is_divisible_by(&monkeys[monkey_id].test_divisible_by) {
                    monkeys[monkey_id].true_condition_id
                } else {
                    monkeys[monkey_id].false_condition_id
                };
                monkeys[id_to].items.push_back(new_item);
            }
        }
    }

    count
}

fn parse_data(data: &str) -> (Vec<Monkey1>, Vec<Monkey2>) {
    let denominators = data
        .lines()
        .skip(3)
        .step_by(7)
        .map(|line| {
            line["  Test: divisible by ".len()..]
                .parse::<i32>()
                .unwrap()
        })
        .collect::<Vec<_>>();

    let (monkeys, monkeys2) = data
        .lines()
        .chunks(7)
        .into_iter()
        .map(|mut chunk| {
            // Monkey {id}:
            chunk.next();

            //   Starting items: {worried_level, ...}
            let items: VecDeque<i32> = chunk.next().unwrap()["  Starting items: ".len()..]
                .split(", ")
                .map(|item| item.parse().unwrap())
                .collect();

            //   Operation: new = old {op} {other}
            let (operation, operation_remainder) =
                parse_operation(&chunk.next().unwrap()["  Operation: new = old ".len()..]);

            //   Test: divisible by {num}
            let test_divisible_by = chunk.next().unwrap()["  Test: divisible by ".len()..]
                .parse()
                .unwrap();

            //     If true: throw to monkey {id}
            let true_condition_id = chunk.next().unwrap()["    If true: throw to monkey ".len()..]
                .parse()
                .unwrap();

            //     If false: throw to monkey {id}
            let false_condition_id = chunk.next().unwrap()
                ["    If false: throw to monkey ".len()..]
                .parse()
                .unwrap();

            let items2 = items
                .iter()
                .map(|item| NumberRemainder::from_i32(item, &denominators))
                .collect();
            (
                Monkey1 {
                    items,
                    operation,
                    test_divisible_by,
                    true_condition_id,
                    false_condition_id,
                },
                Monkey2 {
                    items: items2,
                    operation_remainder,
                    test_divisible_by,
                    true_condition_id,
                    false_condition_id,
                },
            )
        })
        .unzip();

    (monkeys, monkeys2)
}

fn parse_operation(expression: &str) -> (Monkey1Operation, Monkey2Operation) {
    let mut iter = expression.split_whitespace();
    let op = iter.next().unwrap();
    let y = iter.next().unwrap();

    if y == "old" {
        match op {
            "+" => (
                Box::new(|x| x + x),
                Box::new(move |remainder| remainder.add_number_remainder(&remainder)),
            ),
            "*" => (
                Box::new(|x| x * x),
                Box::new(move |remainder| remainder.mul_number_remainder(&remainder)),
            ),
            _ => unreachable!(),
        }
    } else {
        let y: i32 = y.parse().unwrap();
        match op {
            "+" => (
                Box::new(move |x| x + y),
                Box::new(move |remainder| remainder.add_i32(&y)),
            ),
            "*" => (
                Box::new(move |x| x * y),
                Box::new(move |remainder| remainder.mul_i32(&y)),
            ),
            _ => unreachable!(),
        }
    }
}
