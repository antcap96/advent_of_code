pub fn answer() {
    let data = include_str!("input.txt");

    let tree_heights = parse_data(data);

    let count = answer1(&tree_heights);
    println!("Answer 1: {}", count);

    let max_score = answer2(&tree_heights);
    println!("Answer 2: {:?}", max_score);
}

fn parse_data(data: &str) -> ndarray::Array2<i32> {
    let heights: ndarray::Array<_, _> = data
        .lines()
        .map(|line| {
            line.chars()
                .map(|c| c.to_string().parse::<i32>().expect("unknown char"))
                .collect::<Vec<_>>()
        })
        .collect();

    let rows = heights.len();
    let cols = heights[0].len();

    let output: ndarray::ArrayBase<_, _> =
        ndarray::Array::from_shape_fn((rows, cols), |(row, col)| heights[row][col]);

    output
}

fn answer1(tree_heights: &ndarray::Array2<i32>) -> i32 {
    let mut from_left = ndarray::Array::from_elem(tree_heights.raw_dim(), false);
    let mut from_right = ndarray::Array::from_elem(tree_heights.raw_dim(), false);
    let mut from_top = ndarray::Array::from_elem(tree_heights.raw_dim(), false);
    let mut from_bottom = ndarray::Array::from_elem(tree_heights.raw_dim(), false);

    let mut from_left_ = from_left.view_mut();
    let trees_view = &tree_heights.view();
    row_wise_is_max_seen_so_far(trees_view, &mut from_left_);

    let mut from_right_ =
        from_right.slice_axis_mut(ndarray::Axis(1), ndarray::Slice::new(0, None, -1));
    let trees_view = &tree_heights.slice_axis(ndarray::Axis(1), ndarray::Slice::new(0, None, -1));
    row_wise_is_max_seen_so_far(trees_view, &mut from_right_);

    let mut from_top_ = from_top.view_mut().reversed_axes();
    let trees_view = &tree_heights.view().reversed_axes();
    row_wise_is_max_seen_so_far(trees_view, &mut from_top_);

    let mut from_bottom_ = from_bottom
        .slice_axis_mut(ndarray::Axis(0), ndarray::Slice::new(0, None, -1))
        .reversed_axes();
    let trees_view = &tree_heights
        .slice_axis(ndarray::Axis(0), ndarray::Slice::new(0, None, -1))
        .reversed_axes();
    row_wise_is_max_seen_so_far(trees_view, &mut from_bottom_);

    let visible = ndarray::Zip::from(&from_left)
        .and(&from_right)
        .and(&from_top)
        .and(&from_bottom)
        .map_collect(|a1, a2, a3, a4| a1 | a2 | a3 | a4);

    visible.iter().map(|el| *el as i32).sum::<i32>()
}

fn row_wise_is_max_seen_so_far(
    tree_heights: &ndarray::ArrayView2<i32>,
    output: &mut ndarray::ArrayViewMut2<bool>,
) {
    for (mut out_row, tree_row) in output
        .rows_mut()
        .into_iter()
        .zip(tree_heights.rows().into_iter())
    {
        let mut max_so_far = -1;
        for (out, input) in out_row.iter_mut().zip(tree_row.iter()) {
            *out = *input > max_so_far;
            max_so_far = std::cmp::max(*input, max_so_far)
        }
    }
}

fn answer2(trees: &ndarray::Array2<i32>) -> i32 {
    let mut vision_score_left = ndarray::Array2::zeros(trees.raw_dim());
    let mut vision_score_right = ndarray::Array2::zeros(trees.raw_dim());
    let mut vision_score_up = ndarray::Array2::zeros(trees.raw_dim());
    let mut vision_score_down = ndarray::Array2::zeros(trees.raw_dim());

    let mut vision_score_left_ = vision_score_left.view_mut();
    let trees_view = &trees.view();
    compute_vision_score_from_left(trees_view, &mut vision_score_left_);

    let mut vision_score_right_ =
        vision_score_right.slice_axis_mut(ndarray::Axis(1), ndarray::Slice::new(0, None, -1));
    let trees_view = &trees.slice_axis(ndarray::Axis(1), ndarray::Slice::new(0, None, -1));
    compute_vision_score_from_left(trees_view, &mut vision_score_right_);

    let mut vision_score_up_ = vision_score_up.view_mut().reversed_axes();
    let trees_view = &trees.view().reversed_axes();
    compute_vision_score_from_left(trees_view, &mut vision_score_up_);

    let mut vision_score_down_ = vision_score_down
        .slice_axis_mut(ndarray::Axis(0), ndarray::Slice::new(0, None, -1))
        .reversed_axes();
    let trees_view = &trees
        .slice_axis(ndarray::Axis(0), ndarray::Slice::new(0, None, -1))
        .reversed_axes();
    compute_vision_score_from_left(trees_view, &mut vision_score_down_);

    let vision_scores = ndarray::Zip::from(&vision_score_left)
        .and(&vision_score_right)
        .and(&vision_score_up)
        .and(&vision_score_down)
        .map_collect(|a1, a2, a3, a4| a1 * a2 * a3 * a4);

    let max_score = vision_scores.iter().max().unwrap();
    *max_score
}

fn compute_vision_score_from_left(
    arr: &ndarray::ArrayView2<i32>,
    output: &mut ndarray::ArrayViewMut2<i32>,
) {
    let rows = arr.dim().0;
    let cols = arr.dim().1;

    for x in 0..rows {
        let mut state = [0; 10];
        for y in 0..cols {
            let height = arr[[x, y]] as usize;
            output[[x, y]] = state[height];
            #[allow(clippy::needless_range_loop)]
            for i in 0..=height {
                state[i] = 1;
            }
            #[allow(clippy::needless_range_loop)]
            for i in (height + 1)..=9 {
                state[i] += 1;
            }
        }
    }
}
