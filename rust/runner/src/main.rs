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

    match args.year {
        2022 => match args.day {
            1 => year2022::day1::answer(),
            2 => year2022::day2::answer(),
            3 => year2022::day3::answer(),
            4 => year2022::day4::answer(),
            5 => year2022::day5::answer(),
            6 => year2022::day6::answer(),
            7 => year2022::day7::answer(),
            8 => year2022::day8::answer(),
            9 => year2022::day9::answer(),
            10 => year2022::day10::answer(),
            11 => year2022::day11::answer(),
            12 => year2022::day12::answer(),
            13 => year2022::day13::answer(),
            14 => year2022::day14::answer(),
            15 => year2022::day15::answer(),
            16 => year2022::day16::answer(),
            17 => year2022::day17::answer(),
            18 => year2022::day18::answer(),
            19 => year2022::day19::answer(),
            n => todo!("day {} not implemented", n),
        },
        2023 => match args.day {
            1 => year2023::day1::answer(),
            _ => todo!("day {} not implemented", args.day),
        },
        _ => todo!("year {} not implemented", args.year)
    }
}
