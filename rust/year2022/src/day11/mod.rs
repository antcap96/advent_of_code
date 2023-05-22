use itertools::Itertools;
use std::collections::{HashMap, VecDeque};

// Maybe do this
struct RemainStorage {
    storage: HashMap<i32, i32>,
}

struct Monkey {
    items: VecDeque<i32>,
    operation: Box<dyn Fn(i32) -> i32>,
    test_divisible_by: i32,
    true_condition_id: usize,
    false_condition_id: usize,
}

struct Monkey2 {
    items: VecDeque<HashMap<i32, i32>>,
    operation_remainder: Box<dyn Fn(HashMap<i32, i32>) -> HashMap<i32, i32>>,
    test_divisible_by: i32,
    true_condition_id: usize,
    false_condition_id: usize,
}

impl std::fmt::Debug for Monkey {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("Monkey")
            .field("items", &self.items)
            .field("test_divisible_by", &self.test_divisible_by)
            .field("true_condition_id", &self.true_condition_id)
            .field("false_condition_id", &self.false_condition_id)
            .finish()
    }
}

pub fn answer() {
    let data =
        std::fs::read_to_string("year2022/src/day11/input.txt").expect("Unable to read file");

    let (mut monkeys, mut monkeys2) = parse_data(&data);

    let monkey_business = answer1(monkeys);
    let monkey_business2 = answer2(monkeys2);

    println!("{:?}", monkey_business);
    println!("{:?}", monkey_business2);
}

fn answer1(mut monkeys: Vec<Monkey>) -> usize {
    let counts = inspect_count(&mut monkeys);

    let monkey_business = counts.iter().sorted().rev().take(2).product::<usize>();
    monkey_business
}
fn answer2(mut monkeys: Vec<Monkey2>) -> usize {
    let counts = inspect_count2(&mut monkeys);

    dbg!(&counts);

    let monkey_business = counts.iter().sorted().rev().take(2).product::<usize>();
    monkey_business
}

fn inspect_count(monkeys: &mut Vec<Monkey>) -> Vec<usize> {
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
        dbg!(&monkeys);
    }

    count
}
fn inspect_count2(monkeys: &mut Vec<Monkey2>) -> Vec<usize> {
    let mut count = vec![0; monkeys.len()];

    for _round in 0..10000 {
        for monkey_id in 0..monkeys.len() {
            while let Some(item) = monkeys[monkey_id].items.pop_front() {
                count[monkey_id] += 1;

                let new_item = (monkeys[monkey_id].operation_remainder)(item);
                let id_to = if *new_item.get(&monkeys[monkey_id].test_divisible_by).unwrap() == 0 {
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

fn parse_data(data: &str) -> (Vec<Monkey>, Vec<Monkey2>) {
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

            //   Operation: new = old + 6
            let (operation, operation_remainder) =
                parse_operation(&chunk.next().unwrap()["  Operation: new = old ".len()..]);

            //   Test: divisible by 3
            let test_divisible_by = chunk.next().unwrap()["  Test: divisible by ".len()..]
                .parse()
                .unwrap();

            //     If true: throw to monkey 2
            let true_condition_id = chunk.next().unwrap()["    If true: throw to monkey ".len()..]
                .parse()
                .unwrap();

            //     If false: throw to monkey 3
            let false_condition_id = chunk.next().unwrap()
                ["    If false: throw to monkey ".len()..]
                .parse()
                .unwrap();

            let items2 = items
                .iter()
                .map(|item| item_to_remainder(item, &denominators))
                .collect();
            (
                Monkey {
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

fn item_to_remainder(item: &i32, denominators: &[i32]) -> HashMap<i32, i32> {
    let mut remainder = HashMap::new();
    for denominator in denominators {
        remainder.insert(*denominator, item % denominator);
    }
    remainder
}

fn parse_operation(
    expression: &str,
) -> (
    Box<dyn Fn(i32) -> i32>,
    Box<dyn Fn(HashMap<i32, i32>) -> HashMap<i32, i32>>,
) {
    let mut iter = expression.split_whitespace();
    let op = iter.next().unwrap();
    let y = iter.next().unwrap();

    if y == "old" {
        match op {
            "+" => (
                Box::new(|x| x + x),
                Box::new(move |remainder| {
                    remainder.into_iter().map(|(k, v)| (k, (v + v) % k)).collect()
                }),
            ),
            "*" => (
                Box::new(|x| x * x),
                Box::new(move |remainder| {
                    remainder.into_iter().map(|(k, v)| (k, (v * v) % k)).collect()
                }),
            ),
            _ => unreachable!(),
        }
    } else {
        let y: i32 = y.parse().unwrap();
        match op {
            "+" => (
                Box::new(move |x| x + y),
                Box::new(move |remainder| {
                    remainder.into_iter().map(|(k, v)| (k, (v + y) % k)).collect()
                }),
            ),
            "*" => (
                Box::new(move |x| x * y),
                Box::new(move |remainder| {
                    remainder.into_iter().map(|(k, v)| (k, (v * y) % k)).collect()
                }),
            ),
            _ => unreachable!(),
        }
    }
}
