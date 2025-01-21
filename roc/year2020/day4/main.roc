app [main!] {
    # pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    pf: platform "/home/antonio-pc/Antonio/roc/basic-cli/platform/main.roc",
}

import pf.Stdout
import pf.Path

MaybeField : [With Str, Missing]

Passport : {
    byr : MaybeField,
    iyr : MaybeField,
    eyr : MaybeField,
    hgt : MaybeField,
    hcl : MaybeField,
    ecl : MaybeField,
    pid : MaybeField,
    cid : MaybeField,
}

maybe_field_from_result = |res|
    when res is
        Ok(ok) -> With(ok)
        Err(_) -> Missing

passport_from_dict : Dict Str Str -> Result Passport Str
passport_from_dict = |dct|
    # TODO: Handle extra fields as error?
    Ok(
        {
            byr: maybe_field_from_result(Dict.get(dct, "byr")),
            iyr: maybe_field_from_result(Dict.get(dct, "iyr")),
            eyr: maybe_field_from_result(Dict.get(dct, "eyr")),
            hgt: maybe_field_from_result(Dict.get(dct, "hgt")),
            hcl: maybe_field_from_result(Dict.get(dct, "hcl")),
            ecl: maybe_field_from_result(Dict.get(dct, "ecl")),
            pid: maybe_field_from_result(Dict.get(dct, "pid")),
            cid: maybe_field_from_result(Dict.get(dct, "cid")),
        },
    )

parse_passport : Str -> Result Passport Str
parse_passport = |str|
    str
    |> Str.replace_each("\n", " ")
    |> Str.split_on (" ")
    |> List.map_try?(
        |field|
            when Str.split_first(field, ":") is
                Ok({ before, after }) -> Ok((before, after))
                Err(NotFound) -> Err("field '${field}' is missing ':'"),
    )
    |> Dict.from_list
    |> passport_from_dict

parse_input : Str -> Result (List Passport) Str
parse_input = |str|
    str |> Str.trim_end |> Str.split_on("\n\n") |> List.map_try(parse_passport)

calc_answer1 : List Passport -> U64
calc_answer1 = |lst|
    lst
    |> List.count_if(
        |passport|
            when passport is
                { byr: With(_), iyr: With(_), eyr: With(_), hgt: With(_), hcl: With(_), ecl: With(_), pid: With(_), cid: _ } -> Bool.true
                _ -> Bool.false,
    )

num_between = |str, low, high|
    when Str.to_u16(str) is
        Ok(num) -> num >= low and num <= high
        _ -> Bool.false

height_check = |str|
    if Str.ends_with(str, "cm") then
        num_between(Str.drop_suffix(str, "cm"), 150, 193)
    else if Str.ends_with(str, "in") then
        num_between(Str.drop_suffix(str, "in"), 59, 76)
    else
        Bool.false

hex_color_check = |str|
    Str.starts_with(str, "#")
    and (List.len(Str.to_utf8(str)) == 7)
    and Str.to_utf8(Str.drop_prefix(str, "#"))
    |> List.all(|elem| (elem >= '0' and elem <= '9') or (elem >= 'a' and elem <= 'f'))

eye_color_check = |str|
    when str is
        "amb" | "blu" | "brn" | "gry" | "grn" | "hzl" | "oth" -> Bool.true
        _ -> Bool.false

id_check = |str|
    (List.len(Str.to_utf8(str)) == 9)
    and Str.to_utf8(str)
    |> List.all(|elem| (elem >= '0' and elem <= '9'))

is_valid2_elements : Passport -> List Bool
is_valid2_elements = |passport|
    when passport is
        { byr: With(byr), iyr: With(iyr), eyr: With(eyr), hgt: With(hgt), hcl: With(hcl), ecl: With(ecl), pid: With(pid), cid: _ } ->
            [
                num_between(byr, 1920, 2002),
                num_between(iyr, 2010, 2020),
                num_between(eyr, 2020, 2030),
                height_check(hgt),
                hex_color_check(hcl),
                eye_color_check(ecl),
                id_check(pid),
            ]

        _ -> [Bool.false]

is_valid2 : Passport -> Bool
is_valid2 = |passport|
    List.all(is_valid2_elements(passport), |x| x)

calc_answer2 : List Passport -> U64
calc_answer2 = |lst|
    lst
    |> List.count_if(is_valid2)

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2020/day4.txt"))?

    parsed = parse_input(input)

    answer1 = Result.map_ok(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.map_ok(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

test_input =
    """
    ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
    byr:1937 iyr:2017 cid:147 hgt:183cm

    iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
    hcl:#cfa07d byr:1929

    hcl:#ae17e1 iyr:2013
    eyr:2024
    ecl:brn pid:760753108 byr:1931
    hgt:179cm

    hcl:#cfa07d eyr:2025 pid:166559648
    iyr:2011 ecl:brn hgt:59in
    """

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer1)
    value == Ok(2)

expect
    value =
        """
        eyr:1972 cid:100
        hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

        iyr:2019
        hcl:#602927 eyr:1967 hgt:170cm
        ecl:grn pid:012533040 byr:1946

        hcl:dab227 iyr:2012
        ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

        hgt:59cm ecl:zzz
        eyr:2038 hcl:74454a iyr:2023
        pid:3556412378 byr:2007
        """
        |> parse_input
        |> Result.map_ok(|lst| List.map(lst, is_valid2))
    value == Ok(List.repeat(Bool.false, 4))

expect
    value =
        """
        pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
        hcl:#623a2f

        eyr:2029 ecl:blu cid:129 byr:1989
        iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

        hcl:#888785
        hgt:164cm byr:2001 iyr:2015 cid:88
        pid:545766238 ecl:hzl
        eyr:2022

        iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
        """
        |> parse_input
        |> Result.map_ok(|lst| List.map(lst, is_valid2_elements))
    value == Ok(List.repeat(List.repeat(Bool.true, 7), 4))
