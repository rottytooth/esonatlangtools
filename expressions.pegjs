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

Conditional = "if" _ c:Comparison _ "then" _ e:Expression fe:Else? {
	return {
		type: "Conditional",
		comp: c,
		exp: e,
//		else_cond: el,
		f_else: fe
	};
} / "if" _ c:Comparison _ "then" _ e:Expression el:ElseConditional+ fe:Else? {
	return {
		type: "Conditional",
		comp: c,
		exp: e,
		else_cond: el,
		f_else: fe
}; 
} / Range

ElseConditional = _ "else" _ "if" _ c:Comparison + "then" _ e:Expression {
	return {
		type: "Conditional",
		comp: c,
		exp: e
	};
}

Else = _ "else" _ e:Expression {
	return e;
}

Range  = ((("the"/"a") _)? "range" _)? "from" s:Expression _ "to" _ e:Expression
{
	return {
		type: "Range",
		start: s,
		end: e
	};
} / Comparison

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

UnaryExpression = g:(Literal / VariableName)
{
	return g;
}

VariableName = ("the" _ ("variable"/"var"/"vessel"))? id:Identifier 
{ 
	if (DEBUG) console.log("in VariableName");
	return {
		type: "VariableName",
        name: id 
    };
}

// end of EXPRESSIONS
