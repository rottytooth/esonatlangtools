// EXPRESSIONS

/*
	NOTE: Expressions are lists, the assumption is everything with more than one element is a list. This can cause some verbal ambiguity in cases like "the quotient of 4 and the sum of 5 and 6 and 7", which translates to [4 / (5 + 6), 7], not 4 / (5 + 6 + 7)
*/ 
Expression = exp:ListOrExpression
{
	if (Array.isArray(exp)) {
    	return {
        	type: "List",
            exp: exp
        };
    }
    return exp;
}

ListOrExpression = _? exp:(Conditional) explist:( _? (", and"/"and"/",") _+ ListOrExpression)?
{
	if (DEBUG) console.log("in Expression");
	if (explist != null) {
		explist = explist[3];
        if (DEBUG) console.log([exp].concat(explist));
		exp = [exp].concat(explist);
    }
    console.log(exp);

    return exp;
}

Conditional = "if" _ c:Comparison _ "then" _ e:Expression _? fe:Else? {
	if (DEBUG) console.log("in If");
	return {
		type: "Conditional",
		comp: c,
		exp: e,
		f_else: fe
	};
} / ForLoop

Else = "else" e:Expression {
	if (DEBUG) console.log("in Else");
    return e;
}

ForLoop = "for" _ id:Identifier _ "in" _ r:Range ":" _ e:Expression {
	if (DEBUG) console.log("in For");
	return {
		cmd: "for",
		varname: id.varname,
		exp: e,
		range: r
	};
} / "for" _ id:Identifier _ "in" _ i:Identifier ":" _ e:Expression {
	if (DEBUG) console.log("in For");
	return {
		cmd: "for",
		varname: id.varname,
		exp: e,
		varname: i
	};
} / Range / Comparison

Range  = ((("the"/"a") _)? ("range"/"count") _)? "from" s:Expression _ "to" _ e:Expression
{
	if (DEBUG) console.log("in Range");
	return {
		type: "Range",
		start: s,
		end: e
	};
}

Comparison = left:(AdditiveExpression) _? op:(NotEqualTo/GreaterThan/LessThan/LessThanEqualTo/GreaterThanEqualTo/EqualTo) _? right:(Expression)
{
	if (DEBUG) console.log("in Comparison");
	return {
		type: "Comparison",
		operator: op,
		left: left,
		right: right
	};
} / AdditiveExpression

EqualTo = ("is equal to"/"equals"/"is the same as"/"is") { return "=="; }
NotEqualTo = ("is not equal to"/"is different from"/"is not") { return "!="; }
GreaterThan = ("is greater than"/"is more than") { return ">"; }
LessThan = ("is less than"/"is fewer than") { return "<"; }
LessThanEqualTo = ("is less" _ ("than" _)? "or equal to"/"is less" _ ("than" _)? "or the same as") { return "<="; }
GreaterThanEqualTo = ("is greater _" ("than" _)? "or equal to"/"is more"_ ("than" _)? "or the same as") { return ">="; }


AdditiveExpression
  = left:(MultiplicativeExpression) _? op:(AdditionOp/SubtractionOp) _? right:(AdditiveExpression) 
{
	if (DEBUG) console.log("in AdditiveExpression");
	return {
		type: "Additive", 
		operator: op,
		left: left,
		right: right
    };
} /
  ("T"/"t") "he" _? op:(AdditionOpDirectObject/SubtractionOpDirectObject) _? "of" _+ left:(MultiplicativeExpression) _? "and" _? right:(AdditiveExpression)
{
	if (DEBUG) console.log("in AdditiveExpression DirectObject");
	return {
		type: "Additive", 
		operator: op,
		left: left,
		right: right
    };
} / MultiplicativeExpression
  
MultiplicativeExpression
    = left:(UnaryExpression) _? op:(MultiplicationOp/DivisionOp/ModuloOp) _? right:(AdditiveExpression) 
{ 
	if (DEBUG) console.log("in MultiplicativeExpression");
	return {
    	type: "Multiplicative", 
    	operator: op,
    	left: left,
    	right: right
    };
} /
  ("T"/"t") "he" _? op:(MultiplicationOpDirectObject/DivisionOpDirectObject/ModuloOpDirectObject) _? "of" _+ left:(MultiplicativeExpression) _? "and" _? right:(AdditiveExpression)    
{ 
	if (DEBUG) console.log("in MultiplicativeExpression DirectObject");
	return {
    	type: "Multiplicative", 
    	operator: op,
    	left: left,
    	right: right
    };
} / UnaryExpression

AdditionOp = "plus" { return "+"; }    
AdditionOpDirectObject = "sum" { return "+"; }
SubtractionOp = "minus" { return "-"; }
SubtractionOpDirectObject = "difference" { return "-"; }
MultiplicationOp = "times" { return "*"; }
MultiplicationOpDirectObject = "product" { return "*"; }
DivisionOp = "divided by" { return "/"; }
DivisionOpDirectObject = "quotient" { return "/"; }
ModuloOp = "modulo" { return "%"; }
ModuloOpDirectObject = "modulus" { return "%"; }

UnaryExpression = g:(Literal / VarWithParam / VariableName) c:TypeConvert?
{
	if (!!c) {
		g.type_coerce = c;
	}
	return g;
}

TypeConvert = _? "as" _ type:("string"/"float"/"int"/"integer"/"number"/"boolean"/"bool") 
{
	return type;
}

// TODO: comma still doesn't work for else or else if

VarWithParam = p:Identifier "'s" _ id:Identifier {
	if (DEBUG) console.log("in VarWithParam");
	return {
    	type: "VariableWithParam",
        name: id,
        param: p
    };
} / id:Identifier _ "with" _ p:Identifier {
	if (DEBUG) console.log("in VarWithParam");
	return {
    	type: "VariableWithParam",
        name: id,
        param: p
    };
}

// TODO: comma still doesn't work for else or else if

VariableName = ("the" _ ("variable"/"var"/"vessel"))? id:Identifier 
{ 
	if (DEBUG) console.log("in VariableName");
	return {
		type: "VariableName",
        name: id 
    };
}

// end of EXPRESSIONS