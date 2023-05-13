use std::str::FromStr;

#[derive(Debug, Clone)]
struct File {
    _name: String,
    size: u64,
}

#[derive(Debug)]
struct Directory {
    _name: String,
    files: Vec<File>,
    directories: Vec<Directory>,
}

impl Directory {
    fn size(&self) -> u64 {
        self.files.iter().map(|file| file.size).sum::<u64>()
            + self.directories.iter().map(|dir| dir.size()).sum::<u64>()
    }
}

#[derive(Debug)]
enum Command {
    Ls(Vec<LsOutput>),
    Cd(String),
}

#[derive(Debug)]
enum LsOutput {
    File(File),
    Directory(String),
}

impl FromStr for LsOutput {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut iter = s.split_whitespace();
        let first_word = iter.next().ok_or(())?;

        if first_word == "dir" {
            Ok(LsOutput::Directory(
                iter.next().ok_or(())?.to_owned(),
            ))
        } else {
            let size = first_word.parse().map_err(|_| ())?;
            let _name = iter.next().ok_or(())?.to_owned();
            Ok(LsOutput::File(File { size, _name }))
        }
    }
}

const TOTAL_SIZE: u64 = 70000000;
const REQUIRED_SIZE: u64 = 30000000;

fn answer1(dir: &Directory) -> u64 {
    let temp = dir.directories.iter().map(answer1).sum::<u64>();
    let size = dir.size();
    if size < 100000 {
        temp + size
    } else {
        temp
    }
}

fn answer2(dir: &Directory) -> u64 {
    let size = dir.size();
    let necessary_space = REQUIRED_SIZE - (TOTAL_SIZE - size);

    recursion(dir, necessary_space, size)
}

fn recursion(dir: &Directory, necessary_space: u64, mut best_so_far: u64) -> u64 {
    let size = dir.size();
    if size < necessary_space {
        return best_so_far;
    }

    if size < best_so_far {
        best_so_far = size;
    }

    for directory in &dir.directories {
        best_so_far = recursion(directory, necessary_space, best_so_far);
    }

    best_so_far
}

pub fn answer() {
    let data = std::fs::read_to_string("year2022/src/day7/input.txt").expect("Unable to read file");

    let command_list = parse_input(&data);

    let root = build_directory("/".to_owned(), &mut command_list.into_iter().skip(1));

    println!("Answer 1: {}", answer1(&root));
    println!("Answer 2: {}", answer2(&root));
}

fn parse_input(data: &str) -> Vec<Command> {
    let mut commands = Vec::new();
    let mut iter = data.lines().peekable();
    while let Some(line) = iter.next() {
        if line.starts_with("$ cd") {
            commands.push(Command::Cd(
                line.split_whitespace().nth(2).unwrap().to_owned(),
            ));
        }
        else if line.starts_with("$ ls") {
            let mut ls_output = Vec::new();
            while let Some(next_line) = iter.peek() {
                if next_line.starts_with('$') {
                    break;
                }
                ls_output.push(iter.next().unwrap().parse().unwrap());
            }
            commands.push(Command::Ls(ls_output));
        }
        else {
            panic!("Unknown command: {}", line);
        }
    }

    commands
}

// This assumes a depth first approach in the command list
fn build_directory<'a>(
    name: String,
    command_list: &mut impl Iterator<Item = Command>,
) -> Directory where {
    let mut files = Vec::new();
    let mut directories = Vec::new();
    while let Some(command) = command_list.next() {
        match command {
            Command::Ls(ls_output) => {
                for output in ls_output {
                    match output {
                        LsOutput::File(file) => files.push(file),
                        LsOutput::Directory(_dir_name) => {}
                    }
                }
            }
            Command::Cd(dir_name) if dir_name == ".." => {
                // Finished this directory
                break;
            }
            Command::Cd(dir_name) => {
                directories.push(build_directory(dir_name.to_owned(), command_list));
            }
        }
    }

    Directory {
        _name: name,
        files,
        directories,
    }
}
