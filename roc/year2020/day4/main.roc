app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br" }

import pf.Stdout
import pf.Path exposing [Path]

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

maybeFieldFromResult = \res ->
    when res is
        Ok ok -> With ok
        Err _ -> Missing

passportFromDict : Dict Str Str -> Result Passport Str
passportFromDict = \dct ->
    # TODO: Handle extra fields as error?
    Ok {
        byr: maybeFieldFromResult (Dict.get dct "byr"),
        iyr: maybeFieldFromResult (Dict.get dct "iyr"),
        eyr: maybeFieldFromResult (Dict.get dct "eyr"),
        hgt: maybeFieldFromResult (Dict.get dct "hgt"),
        hcl: maybeFieldFromResult (Dict.get dct "hcl"),
        ecl: maybeFieldFromResult (Dict.get dct "ecl"),
        pid: maybeFieldFromResult (Dict.get dct "pid"),
        cid: maybeFieldFromResult (Dict.get dct "cid"),
    }

parsePassport : Str -> Result Passport Str
parsePassport = \str ->
    str
        |> Str.replaceEach "\n" " "
        |> Str.split " "
        |> List.mapTry? \field ->
            when Str.splitFirst field ":" is
                Ok { before, after } -> Ok (before, after)
                Err NotFound -> Err "field '$(field)' is missing ':'"
        |> Dict.fromList
        |> passportFromDict

parseInput : Str -> Result (List Passport) Str
parseInput = \str ->
    str |> Str.trimEnd |> Str.split "\n\n" |> List.mapTry parsePassport

calcAnswer1 : List Passport -> U64
calcAnswer1 = \lst ->
    lst
    |> List.countIf \passport ->
        when passport is
            { byr: With _, iyr: With _, eyr: With _, hgt: With _, hcl: With _, ecl: With _, pid: With _, cid: _ } -> Bool.true
            _ -> Bool.false

numBetween = \str, low, high ->
    when Str.toU16 str is
        Ok num -> num >= low && num <= high
        _ -> Bool.false

heightCheck = \str ->
    if Str.endsWith str "cm" then
        numBetween (Str.dropSuffix str "cm") 150 193
    else if Str.endsWith str "in" then
        numBetween (Str.dropSuffix str "in") 59 76
    else
        Bool.false

hexColorCheck = \str ->
    Str.startsWith str "#"
    &&
    List.len (Str.toUtf8 str)
    == 7
    &&
    Str.toUtf8 (Str.dropPrefix str "#")
    |> List.all \elem -> (elem >= '0' && elem <= '9') || (elem >= 'a' && elem <= 'f')

eyeColorCheck = \str ->
    when str is
        "amb" | "blu" | "brn" | "gry" | "grn" | "hzl" | "oth" -> Bool.true
        _ -> Bool.false

idCheck = \str ->
    List.len (Str.toUtf8 str)
    == 9
    &&
    Str.toUtf8 str
    |> List.all \elem -> (elem >= '0' && elem <= '9')

isValid2Elements : Passport -> List Bool
isValid2Elements = \passport ->
    when passport is
        { byr: With byr, iyr: With iyr, eyr: With eyr, hgt: With hgt, hcl: With hcl, ecl: With ecl, pid: With pid, cid: _ } ->
            [
                numBetween byr 1920 2002,
                numBetween iyr 2010 2020,
                numBetween eyr 2020 2030,
                heightCheck hgt,
                hexColorCheck hcl,
                eyeColorCheck ecl,
                idCheck pid,
            ]

        _ -> [Bool.false]

isValid2 : Passport -> Bool
isValid2 = \passport ->
    List.all (isValid2Elements passport) \x -> x

calcAnswer2 : List Passport -> U64
calcAnswer2 = \lst ->
    lst
    |> List.countIf isValid2

main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2020/day4.txt")

    parsed = parseInput input

    answer1 = Result.map parsed calcAnswer1
    answer2 = Result.map parsed calcAnswer2

    Stdout.line! "Answer1: $(Inspect.toStr answer1)"
    Stdout.line! "Answer2: $(Inspect.toStr answer2)"

readFileToStr : Path -> Task Str [ReadFileErr Str]
readFileToStr = \path ->
    path
    |> Path.readUtf8
    |> Task.mapErr # Make a nice error message
        \fileReadErr ->
            pathStr = Path.display path

            when fileReadErr is
                FileReadErr _ readErr ->
                    readErrStr = Inspect.toStr readErr
                    ReadFileErr "Failed to read file:\n\t$(pathStr)\nWith error:\n\t$(readErrStr)"

                FileReadUtf8Err _ _ ->
                    ReadFileErr "I could not read the file:\n\t$(pathStr)\nIt contains characters that are not valid UTF-8."

testInput =
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
        testInput
        |> parseInput
        |> Result.map calcAnswer1
    value == Ok 2

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
        |> parseInput
        |> Result.map (\lst -> List.map lst isValid2)
    value == Ok (List.repeat Bool.false 4)

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
        |> parseInput
        |> Result.map (\lst -> List.map lst isValid2Elements)
    value == Ok (List.repeat (List.repeat Bool.true 7) 4)
