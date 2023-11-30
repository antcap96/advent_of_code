#[derive(Debug, Clone)]
struct Ship {
    stacks: Vec<Vec<char>>,
}

impl Ship {
    fn pop1(&mut self, from: i32) -> char {
        self.stacks[from as usize].pop().unwrap()
    }

    fn push1(&mut self, to: i32, cargo: char) {
        self.stacks[to as usize].push(cargo)
    }

    fn update1(&mut self, operation: &Operation) {
        for _ in 0..operation.amount {
            let cargo = self.pop1(operation.from);
            self.push1(operation.to, cargo);
        }
    }

    fn popn(&mut self, from: i32, n: i32) -> Vec<char> {
        let mut result = vec![];
        for _ in 0..n {
            result.push(self.pop1(from));
        }
        result.reverse();
        result
    }

    fn pushn(&mut self, to: i32, cargo: Vec<char>) {
        for c in cargo {
            self.push1(to, c);
        }
    }

    fn updaten(&mut self, operation: &Operation) {
        let cargo = self.popn(operation.from, operation.amount);
        self.pushn(operation.to, cargo);
    }

    fn get_top_of_each_stack(&self) -> String {
        let answer: String = self.stacks.iter().map(|arr| arr.last().unwrap()).collect();
        answer
    }
}

#[derive(Debug)]
struct Operation {
    amount: i32,
    from: i32,
    to: i32,
}

impl Operation {
    fn from_str(s: &str) -> Self {
        let mut iter = s.split_whitespace();
        iter.next();
        let amount = iter.next().unwrap().parse().unwrap();
        iter.next();
        let from = iter.next().unwrap().parse::<i32>().unwrap() - 1;
        iter.next();
        let to = iter.next().unwrap().parse::<i32>().unwrap() - 1;
        Self { amount, from, to }
    }
}

pub fn answer() {
    let data = include_str!("input.txt");

    let (ship, operations) = parse_input(data);

    let mut ship1 = ship.clone();
    print_answer1(&mut ship1, &operations);

    let mut ship2 = ship;
    print_answer2(&mut ship2, &operations);
}

fn print_answer1(ship: &mut Ship, operations: &Vec<Operation>) {
    for op in operations {
        ship.update1(op);
    }

    println!("Answer 1: {}", ship.get_top_of_each_stack());
}

fn print_answer2(ship: &mut Ship, operations: &Vec<Operation>) {
    for op in operations {
        ship.updaten(op);
    }

    println!("Answer 2: {}", ship.get_top_of_each_stack());
}

fn parse_input(data: &str) -> (Ship, Vec<Operation>) {
    let mut iter = data.lines();
    let mut rows: Vec<Vec<char>> = vec![];

    for line in iter.by_ref() {
        if line.starts_with(" 1") {
            break;
        }
        rows.push(line.chars().skip(1).step_by(4).collect());
    }

    let mut stacks: Vec<Vec<char>> = vec![vec![]; rows[0].len()];
    for row in rows.iter().rev() {
        for (i, cargo) in row.iter().enumerate() {
            if *cargo != ' ' {
                stacks[i].push(*cargo);
            }
        }
    }
    let ship = Ship { stacks };
    iter.next(); // skip empty line

    let operations = iter.map(Operation::from_str).collect::<Vec<_>>();
    (ship, operations)
}
