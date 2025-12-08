use clap::Parser;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// day to execute
    #[arg(short, long, value_parser = clap::value_parser!(u8).range(1..=25))]
    day: u8,
    #[arg(short, long)]
    year: u16,
}

fn main() {
    let args = Args::parse();
    let path = format!("../inputs/{}/day{}.txt", args.year, args.day);

    match args.year {
        2020 => match args.day {
            1 => year2020::day1::answer(&path),
            2 => year2020::day2::answer(&path),
            3 => year2020::day3::answer(&path),
            4 => year2020::day4::answer(&path),
            _ => todo!("day {} not implemented", args.day),
        },
        2022 => match args.day {
            1 => year2022::day1::answer(&path),
            2 => year2022::day2::answer(&path),
            3 => year2022::day3::answer(&path),
            4 => year2022::day4::answer(&path),
            5 => year2022::day5::answer(&path),
            6 => year2022::day6::answer(&path),
            7 => year2022::day7::answer(&path),
            8 => year2022::day8::answer(&path),
            9 => year2022::day9::answer(&path),
            10 => year2022::day10::answer(&path),
            11 => year2022::day11::answer(&path),
            12 => year2022::day12::answer(&path),
            13 => year2022::day13::answer(&path),
            14 => year2022::day14::answer(&path),
            15 => year2022::day15::answer(&path),
            16 => year2022::day16::answer(&path),
            17 => year2022::day17::answer(&path),
            18 => year2022::day18::answer(&path),
            19 => year2022::day19::answer(&path),
            n => todo!("day {} not implemented", n),
        },
        2023 => match args.day {
            1 => year2023::day1::answer(&path),
            2 => year2023::day2::answer(&path),
            5 => year2023::day5::answer(&path),
            11 => year2023::day11::answer(&path),
            _ => todo!("day {} not implemented", args.day),
        },
        2024 => match args.day {
            6 => year2024::day6::answer(&path),
            _ => todo!("day {} not implemented", args.day),
        },
        2025 => match args.day {
            1 => year2025::day1::answer(&path),
            2 => year2025::day2::answer(&path),
            3 => year2025::day3::answer(&path),
            4 => year2025::day4::answer(&path),
            5 => year2025::day5::answer(&path),
            6 => year2025::day6::answer(&path),
            7 => year2025::day7::answer(&path),
            8 => year2025::day8::answer(&path),
            _ => todo!("day {} not implemented", args.day),
        },
        _ => todo!("year {} not implemented", args.year),
    }
}
