use std::collections::HashMap;

#[derive(Debug)]
struct Passport<'a> {
    byr: &'a str,
    iyr: &'a str,
    eyr: &'a str,
    hgt: &'a str,
    hcl: &'a str,
    ecl: &'a str,
    pid: &'a str,
}

impl<'a> Passport<'a> {
    fn validate_byr(&self) -> bool {
        self.byr
            .parse::<usize>()
            .map(|num| (1920..=2002).contains(&num))
            .unwrap_or(false)
    }
    fn validate_iyr(&self) -> bool {
        self.iyr
            .parse::<usize>()
            .map(|num| (2010..=2020).contains(&num))
            .unwrap_or(false)
    }
    fn validate_eyr(&self) -> bool {
        self.eyr
            .parse::<usize>()
            .map(|num| (2020..=2030).contains(&num))
            .unwrap_or(false)
    }

    fn validate_hgt(&self) -> bool {
        if let Some(rest) = self.hgt.strip_suffix("cm") {
            rest.parse::<usize>()
                .map(|num| (150..=193).contains(&num))
                .unwrap_or(false)
        } else if let Some(rest) = self.hgt.strip_suffix("in") {
            rest.parse::<usize>()
                .map(|num| (59..=76).contains(&num))
                .unwrap_or(false)
        } else {
            false
        }
    }

    fn validate_hcl(&self) -> bool {
        self.hcl
            .strip_prefix("#")
            .map(|digits| {
                digits.chars().all(|c| matches!(c, 'a'..='f' | '0'..='9'))
                    && digits.len() == 6
            })
            .unwrap_or(false)
    }

    fn validate_ecl(&self) -> bool {
        matches!(
            self.ecl,
            "amb" | "blu" | "brn" | "gry" | "grn" | "hzl" | "oth"
        )
    }

    fn validate_pid(&self) -> bool {
        self.pid.chars().all(|c| c.is_ascii_digit()) && self.pid.len() == 9
    }

    fn is_valid(&self) -> bool {
        self.validate_byr()
            && self.validate_iyr()
            && self.validate_eyr()
            && self.validate_hgt()
            && self.validate_hcl()
            && self.validate_ecl()
            && self.validate_pid()
    }
}

fn answer1(passports: &[Passport]) -> usize {
    passports.len()
}

fn answer2(passports: &[Passport]) -> usize {
    passports.iter().filter(|p| p.is_valid()).count()
}

pub fn answer(path: &str) {
    let input = std::fs::read_to_string(path).unwrap();

    let passports = parse_input(&input);
    let passports = valid_passports(passports);

    let ans = answer1(&passports);
    println!("Answer 1: {:?}", ans);

    let ans = answer2(&passports);
    println!("Answer 2: {:?}", ans);
}

fn parse_input(data: &str) -> Vec<HashMap<&str, &str>> {
    data.split("\n\n")
        .map(|x| {
            x.split_whitespace()
                .map(|item| item.split_once(':').unwrap()) // TODO: unwrap?
                .collect::<HashMap<&str, &str>>()
        })
        .collect()
}

fn validate_passport<'a>(map: HashMap<&'a str, &'a str>) -> Option<Passport<'a>> {
    let byr = map.get("byr")?;
    let iyr = map.get("iyr")?;
    let eyr = map.get("eyr")?;
    let hgt = map.get("hgt")?;
    let hcl = map.get("hcl")?;
    let ecl = map.get("ecl")?;
    let pid = map.get("pid")?;

    Some(Passport {
        byr,
        iyr,
        eyr,
        hgt,
        hcl,
        ecl,
        pid,
    })
}

fn valid_passports<'a>(passports: Vec<HashMap<&'a str, &'a str>>) -> Box<[Passport<'a>]> {
    passports
        .into_iter()
        .filter_map(validate_passport)
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test1() {
        let input = include_str!("test1.txt");

        assert_eq!(answer1(&valid_passports(parse_input(input))), 2);
    }

    #[test]
    fn test2() {
        let input = include_str!("test2.txt");

        assert_eq!(answer2(&valid_passports(parse_input(input))), 4);
    }
}
