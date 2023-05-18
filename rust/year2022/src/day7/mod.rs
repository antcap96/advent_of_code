use std::str::FromStr;

#[derive(Debug)]
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
    fn empty(name: String) -> Directory {
        Directory {
            _name: name,
            files: vec![],
            directories: vec![],
        }
    }

    fn size(&self) -> u64 {
        self.files.iter().map(|file| file.size).sum::<u64>()
            + self.directories.iter().map(|dir| dir.size()).sum::<u64>()
    }

    fn contains_dir(&self, dir: &str) -> bool {
        self.directories.iter().any(|d| d._name == dir)
    }

    fn contains_file(&self, file: &str) -> bool {
        self.directories.iter().any(|f| f._name == file)
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
            Ok(LsOutput::Directory(iter.next().ok_or(())?.to_owned()))
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

    // let root = build_directory("/".to_owned(), &mut command_list.into_iter().skip(1));
    let root = build_directories(&mut command_list.into_iter().skip(1));

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
        } else if line.starts_with("$ ls") {
            let mut ls_output = Vec::new();
            while iter.peek().map_or(false, |line| !line.starts_with('$')) {
                let line = iter.next().unwrap();
                ls_output.push(line.parse().unwrap());
            }
            commands.push(Command::Ls(ls_output));
        } else {
            panic!("Unknown command: {}", line);
        }
    }

    commands
}

// This assumes a depth first approach in the command list
#[allow(dead_code)]
fn build_directory(name: String, command_list: &mut impl Iterator<Item = Command>) -> Directory {
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

fn build_directories(command_list: &mut impl Iterator<Item = Command>) -> Directory {
    let mut current_path: Vec<String> = vec![];
    let mut root = Directory::empty("/".to_owned());

    for command in command_list {
        match command {
            Command::Cd(name) if name == ".." => {
                current_path.pop();
            }
            Command::Cd(name) => {
                current_path.push(name);
            }
            Command::Ls(ls_output) => {
                let mut working_dir = &mut root;
                for name in current_path.iter() {
                    working_dir = working_dir
                        .directories
                        .iter_mut()
                        .find(|dir| dir._name == *name)
                        .unwrap();
                }
                append_to_dir(working_dir, ls_output);
            }
        }
    }

    root
}

fn append_to_dir(working_dir: &mut Directory, ls_output: Vec<LsOutput>) {
    for output in ls_output {
        match output {
            LsOutput::Directory(name) => {
                if !working_dir.contains_dir(&name) {
                    working_dir.directories.push(Directory::empty(name))
                }
            }
            LsOutput::File(file) => {
                if !working_dir.contains_file(&file._name) {
                    working_dir.files.push(file)
                }
            }
        }
    }
}
