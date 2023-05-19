struct Trees {
    heights: Vec<Vec<i32>>,
}

fn transpose<T: Copy + Default>(arr: &Vec<Vec<T>>) -> Vec<Vec<T>> {
    let rows = arr.len();
    let cols = arr[0].len();
    let default = T::default();
    let mut output = vec![vec![default; rows]; cols];
    for x in 0..rows {
        for y in 0..cols {
            output[y][x] = arr[x][y];
        }
    }
    output
}

fn combine(
    arr1: &Vec<Vec<bool>>,
    arr2: &Vec<Vec<bool>>,
    arr3: &Vec<Vec<bool>>,
    arr4: &Vec<Vec<bool>>,
) -> Vec<Vec<bool>> {
    let rows = arr1.len();
    let cols = arr1[0].len();
    let default = false;
    let mut output = vec![vec![default; cols]; rows];
    for x in 0..rows {
        for y in 0..cols {
            output[x][y] = arr1[x][y] || arr2[x][y] || arr3[x][y] || arr4[x][y];
        }
    }
    output
}

fn product(
    arr1: &Vec<Vec<i32>>,
    arr2: &Vec<Vec<i32>>,
    arr3: &Vec<Vec<i32>>,
    arr4: &Vec<Vec<i32>>,
) -> Vec<Vec<i32>> {
    let rows = arr1.len();
    let cols = arr1[0].len();
    let default = 0;
    let mut output = vec![vec![default; cols]; rows];
    for x in 0..rows {
        for y in 0..cols {
            output[x][y] = arr1[x][y] * arr2[x][y] * arr3[x][y] * arr4[x][y];
        }
    }
    output
}

fn is_max_seen_so_far(state: &mut i32, height: &i32) -> Option<bool> {
    let result = Some(height > state);
    *state = std::cmp::max(*height, *state);
    result
}

pub fn answer() {
    let data = std::fs::read_to_string("year2022/src/day8/input.txt").expect("Unable to read file");

    let trees = parse_data(&data);

    let count = answer1(&trees);
    println!("Answer 1: {}", count);

    let max_score = answer2(trees);
    println!("Answer 2: {:?}", max_score);
}

fn answer2(trees: Trees) -> i32 {
    let vision_score_left: Vec<Vec<i32>> = compute_vision_score_left(&trees.heights);
    let vision_score_right: Vec<Vec<i32>> = compute_vision_score_right(&trees.heights);
    let vision_score_up: Vec<Vec<i32>> = compute_vision_score_up(&trees.heights);
    let vision_score_down: Vec<Vec<i32>> = compute_vision_score_down(&trees.heights);

    let vision_scores = product(
        &vision_score_left,
        &vision_score_up,
        &vision_score_right,
        &vision_score_down,
    );
    let max_score = vision_scores
        .iter()
        .map(|row| row.iter().max().unwrap())
        .max()
        .unwrap();
    *max_score
}

fn answer1(trees: &Trees) -> i32 {
    let from_left = trees
        .heights
        .iter()
        .map(|row| row.iter().scan(-1, is_max_seen_so_far).collect())
        .collect::<Vec<Vec<bool>>>();

    let from_right = trees
        .heights
        .iter()
        .map(|row| {
            row.iter()
                .rev()
                .scan(-1, is_max_seen_so_far)
                .collect::<Vec<bool>>()
                .into_iter()
                .rev()
                .collect()
        })
        .collect::<Vec<Vec<bool>>>();

    let from_top = transpose(&trees.heights)
        .iter()
        .map(|row| row.iter().scan(-1, is_max_seen_so_far).collect())
        .collect::<Vec<Vec<bool>>>();
    let from_top = transpose(&from_top);

    let from_bottom = transpose(&trees.heights)
        .iter()
        .map(|row| {
            row.iter()
                .rev()
                .scan(-1, is_max_seen_so_far)
                .collect::<Vec<bool>>()
                .into_iter()
                .rev()
                .collect()
        })
        .collect::<Vec<Vec<bool>>>();
    let from_bottom = transpose(&from_bottom);

    let visible = combine(&from_left, &from_top, &from_right, &from_bottom);

    let count: i32 = visible
        .iter()
        .map(|row| row.iter().map(|&bit| if bit { 1 } else { 0 }).sum::<i32>())
        .sum();
    count
}

fn parse_data(data: &str) -> Trees {
    let heights = data
        .lines()
        .map(|line| {
            line.chars()
                .map(|c| c.to_string().parse::<i32>().expect("unknown char"))
                .collect()
        })
        .collect();

    Trees { heights }
}

fn compute_vision_score_left(arr: &Vec<Vec<i32>>) -> Vec<Vec<i32>> {
    let rows = arr.len();
    let cols = arr[0].len();
    let default = 0;
    let mut output = vec![vec![default; cols]; rows];
    for x in 0..rows {
        let mut state = [0; 10];
        for y in 0..cols {
            let height = arr[x][y] as usize;
            output[x][y] = state[height];
            for i in 0..=height {
                state[i] = 1;
            }
            for i in (height + 1)..=9 {
                state[i] += 1;
            }
        }
    }
    output
}

fn compute_vision_score_right(arr: &Vec<Vec<i32>>) -> Vec<Vec<i32>> {
    let rows = arr.len();
    let cols = arr[0].len();
    let default = 0;
    let mut output = vec![vec![default; cols]; rows];
    for x in 0..rows {
        let mut state = [0; 10];
        for y in (0..cols).rev() {
            let height = arr[x][y] as usize;
            output[x][y] = state[height];
            for i in 0..=height {
                state[i] = 1;
            }
            for i in (height + 1)..=9 {
                state[i] += 1;
            }
        }
    }
    output
}

fn compute_vision_score_up(arr: &Vec<Vec<i32>>) -> Vec<Vec<i32>> {
    let rows = arr.len();
    let cols = arr[0].len();
    let default = 0;
    let mut output = vec![vec![default; cols]; rows];
    for y in 0..cols {
        let mut state = [0; 10];
        for x in 0..rows {
            let height = arr[x][y] as usize;
            output[x][y] = state[height];
            for i in 0..=height {
                state[i] = 1;
            }
            for i in (height + 1)..=9 {
                state[i] += 1;
            }
        }
    }
    output
}

fn compute_vision_score_down(arr: &Vec<Vec<i32>>) -> Vec<Vec<i32>> {
    let rows = arr.len();
    let cols = arr[0].len();
    let default = 0;
    let mut output = vec![vec![default; cols]; rows];
    for y in 0..cols {
        let mut state = [0; 10];
        for x in (0..rows).rev() {
            let height = arr[x][y] as usize;
            output[x][y] = state[height];
            for i in 0..=height {
                state[i] = 1;
            }
            for i in (height + 1)..=9 {
                state[i] += 1;
            }
        }
    }
    output
}
