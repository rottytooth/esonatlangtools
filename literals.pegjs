// LITERALS

Literal = StringLiteral / CharLiteral / NumberLiteral

// This is awkward, but may be the best we can do in pure regex.
// Each makes one part non-optional, where what we need is "at least one but it could be any"
NumberLiteral =
    ("negative" _)? mil:MillionsDigit DigitSeparator? thou:ThousandsDigit? DigitSeparator? hun:HundredsDigit? DigitSeparator? end:EndDigit?
{
	if (DEBUG) console.log("in NumberLiteral Millions");
	let retval = mil;
    if (thou) retval += thou;
    if (hun) retval += hun;
    if (end) retval += end;
	return { type: "IntLiteral", value: retval };
} / ("negative" _)? thou:ThousandsDigit DigitSeparator? hun:HundredsDigit? DigitSeparator? end:EndDigit?
{
	if (DEBUG) console.log("in NumberLiteral Thousands");
	let retval = thou;
    if (hun) retval += hun;
    if (end) retval += end;
	return { type: "IntLiteral", value: retval };
} / ("negative" _)? hun:HundredsDigit DigitSeparator? end:EndDigit?
{
	if (DEBUG) console.log("in NumberLiteral Hundreds");
	let retval = hun;
    if (end) retval += end;
	return { type: "IntLiteral", value: retval };
} / neg:("negative" _)? end:EndDigit
{
	if (DEBUG) console.log("in NumberLiteral EndDigit");
	return { type: "IntLiteral", value: neg ? -end : end };
}

MillionsDigit =
	("a" (_ / "-") ("M"/"m") "illion" ![a-zA-Z0-9_] !(_ ("the" _ ("range"/"count"))) { return 1000000; }) /
	end:(HundredsDigit/EndDigit) (_ / "-")? ("M"/"m") "illion" ![a-zA-Z0-9_] !(_ ("the" _ ("range"/"count")))
{
	if (DEBUG) console.log("in MillionsDigit");
	return end * 1000000;
}

ThousandsDigit =
	hun:HundredsDigit (_ "and" _ / _ / "-")? end:EndDigit? _ ("T"/"t") "housand" ![a-zA-Z0-9_]
{
	if (DEBUG) console.log("in ThousandsDigit");
	let retval = 0;
    if (end) retval += end;
    if (hun) retval += hun;
	return retval * 1000;
} / end:EndDigit _ ("T"/"t") "housand" ![a-zA-Z0-9_]
{
	if (DEBUG) console.log("in EndDigit");
	return end * 1000;
} / "a" !(_ ("M"/"m") "illion") _ "thousand" ![a-zA-Z0-9_]
{
	return 1000;
}

HundredsDigit =
	end:EndDigit (_ / "-")? ("H"/"h") "undred" ![a-zA-Z0-9_]
{
	return end * 100;
} / "a" !(_ ("M"/"m") "illion") !(_ ("T"/"t") "housand") _ "hundred" ![a-zA-Z0-9_]
{
	return 100;
}

EndDigit = TeensDigit / tens:TensDigit (_ "and" _ / "," _ / "-")? ones:OnesDigit?
{
	let retval = 0;
	if (tens) retval += tens;
	if (ones) retval += ones;
	return retval;
} / ones:OnesDigit

TensDigit = 
	"ten" ![a-zA-Z0-9_] { return 10; } /
	"twenty" ![a-zA-Z0-9_] { return 20; } /
    "thirty" ![a-zA-Z0-9_] { return 30; } /
    "forty" ![a-zA-Z0-9_] { return 40; } /
    "fifty" ![a-zA-Z0-9_] { return 50; } /
    "sixty" ![a-zA-Z0-9_] { return 60; } /
	"seventy" ![a-zA-Z0-9_] { return 70; } /
    "eighty" ![a-zA-Z0-9_] { return 80; } /
    "ninety" ![a-zA-Z0-9_] { return 90; }

OnesDigit = 
	"zero" ![a-zA-Z0-9_] { return 0; } /
	"one" ![a-zA-Z0-9_] { return 1; } /
    "two" ![a-zA-Z0-9_] { return 2; } /
    "three" ![a-zA-Z0-9_] { return 3; } /
    "four" ![a-zA-Z0-9_] { return 4; } /
    "five" ![a-zA-Z0-9_] { return 5; } / 
    "six" ![a-zA-Z0-9_] { return 6; } /
    "seven" ![a-zA-Z0-9_] { return 7; } /
    "eight" ![a-zA-Z0-9_] { return 8; } /
    "nine" ![a-zA-Z0-9_] { return 9; } /
    "zero" ![a-zA-Z0-9_] { return 0; } 

TeensDigit =
    "eleven" ![a-zA-Z0-9_] { return 11; } /
    "twelve" ![a-zA-Z0-9_] { return 12; } /
	"a" !(_ ("M"/"m") "illion") !(_ ("T"/"t") "housand") !(_ ("H"/"h") "undred") _ "dozen" ![a-zA-Z0-9_] { return 12; } /
    "thirteen" ![a-zA-Z0-9_] { return 13; } /
    "fourteen" ![a-zA-Z0-9_] { return 14; } /
    "fifteen" ![a-zA-Z0-9_] { return 15; } /
    "sixteen" ![a-zA-Z0-9_] { return 16; } /
    "seventeen" ![a-zA-Z0-9_] { return 17; } /
    "eighteen" ![a-zA-Z0-9_] { return 18; } /
    "nineteen" ![a-zA-Z0-9_] { return 19; }

DigitSeparator = (", and" _ / " and" _ / "," _ / !(_ ("to"/"step") ![a-zA-Z0-9_]) _)

StringLiteral = _? ('"'/'“') val:[^"]* ('"'/'”') _?
{ 
	return {
		type: 'StringLiteral',
		value: val.join("") 
    };
}

CharLiteral = _? "'" val:[^'] "'" _?
{ 
	return {
		type: 'CharLiteral',
		value: val 
	};
}

// end of LITERALS
