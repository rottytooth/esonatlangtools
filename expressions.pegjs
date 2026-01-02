// EXPRESSIONS

/*
	NOTE: Expressions are lists, the assumption is everything with more than one element is a list. This can cause some verbal ambiguity in cases like "the quotient of 4 and the sum of 5 and 6 and 7", which translates to [4 / (5 + 6), 7], not 4 / (5 + 6 + 7)
*/ 

Expression = main:ListOrExpression filter:(_ FilterKeyword _ ListOrExpression)? {
	let result;
	if (Array.isArray(main)) {
		result = { type: "List", exp: main };
	} else {
		result = main;
	}
	if (filter) {
		return {
			type: "FilteredExpression",
			exp: result,
			filter: filter[3]
		};
	}
	return result;
}

FilterKeyword = "where" / "when"

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

Conditional = Range / "if" _ c:Comparison _ "then" _ e:Expression _? ";"? _? fe:Else? {
	if (DEBUG) console.log("in If");
	return {
		type: "Conditional",
		comp: c,
		exp: e,
		f_else: fe
	};
} / ForLoop

Else = ("else" / "otherwise") _ e:Expression {
	if (DEBUG) console.log("in Else");
	return e;
}

ForLoop = "for" _ id:Identifier _ "in" _ s:NumberLiteral _ "to" _ end:NumberLiteral _ "step" _ step:UnaryExpression (","/":")? _ e:Expression {
	if (DEBUG) console.log("in For with number..to..number..step");
	// Evaluate step if it's an additive expression like "zero minus two"
	let stepValue = step;
	if (step.type === "Additive" && step.operator === "-") {
		if (step.left.type === "IntLiteral" && step.right.type === "IntLiteral") {
			stepValue = {type: "IntLiteral", value: step.left.value - step.right.value};
		}
	}
	// Validate step direction
	if (stepValue.type === "IntLiteral") {
		if (s.value < end.value && stepValue.value < 0) {
			throw new MemoSyntaxError("Step must be positive when counting upward", "invalid_step", {start: s.value, end: end.value, step: stepValue.value});
		}
		if (s.value > end.value && stepValue.value > 0) {
			throw new MemoSyntaxError("Step must be negative when counting downward", "invalid_step", {start: s.value, end: end.value, step: stepValue.value});
		}
	}
	return {
		type: "ForLoop",
		varname: id.varname,
		exp: e,
		range: {
			type: "Range",
			start: s,
			end: end,
			step: stepValue
		}
	};
} / "for" _ id:Identifier _ "in" _ s:NumberLiteral _ "to" _ end:NumberLiteral (","/":")? _ e:Expression {
	if (DEBUG) console.log("in For with number..to..number");
	return {
		type: "ForLoop",
		varname: id.varname,
		exp: e,
		range: {
			type: "Range",
			start: s,
			end: end,
			step: (s.value > end.value) ? {type: "IntLiteral", value: -1} : {type: "IntLiteral", value: 1}
		}
	};
} / "for" _ id:Identifier _ "in" _ r:Range _ "step" _ step:UnaryExpression (","/":")? _ e:Expression {
	if (DEBUG) console.log("in For with Range and step");
	// Evaluate step if it's an additive expression like "zero minus two"
	let stepValue = step;
	if (step.type === "Additive" && step.operator === "-") {
		if (step.left.type === "IntLiteral" && step.right.type === "IntLiteral") {
			stepValue = {type: "IntLiteral", value: step.left.value - step.right.value};
		}
	}
	// Validate at parse time if all values are literals
	if (r.start.type === "IntLiteral" && r.end.type === "IntLiteral" && stepValue.type === "IntLiteral") {
		if (r.start.value < r.end.value && stepValue.value < 0) {
			throw new MemoSyntaxError("Step must be positive when counting upward", "invalid_step", {start: r.start.value, end: r.end.value, step: stepValue.value});
		}
		if (r.start.value > r.end.value && stepValue.value > 0) {
			throw new MemoSyntaxError("Step must be negative when counting downward", "invalid_step", {start: r.start.value, end: r.end.value, step: stepValue.value});
		}
	}
	r.step = stepValue;
	return {
		type: "ForLoop",
		varname: id.varname,
		exp: e,
		range: r
	};
} / "for" _ id:Identifier _ "in" _ r:Range (","/":")? _ e:Expression {
	if (DEBUG) console.log("in For with Range");
	return {
		type: "ForLoop",
		varname: id.varname,
		exp: e,
		range: r
	};
} / "for" _ id:Identifier _ "in" _ rangeVar:VarWithParam _ "step" _ step:UnaryExpression (","/":")? _ e:Expression {
	if (DEBUG) console.log("in For with VarWithParam and step");
	// Evaluate step if it's an additive expression like "zero minus two"
	let stepValue = step;
	if (step.type === "Additive" && step.operator === "-") {
		if (step.left.type === "IntLiteral" && step.right.type === "IntLiteral") {
			stepValue = {type: "IntLiteral", value: step.left.value - step.right.value};
		}
	}
	return {
		type: "ForLoop",
		varname: id.varname,
		exp: e,
		range: rangeVar,
		rangeStep: stepValue
	};
} / "for" _ id:Identifier _ "in" _ rangeVar:VarWithParam (","/":")? _ e:Expression {
	if (DEBUG) console.log("in For with VarWithParam");
	return {
		type: "ForLoop",
		varname: id.varname,
		exp: e,
		range: rangeVar
	};
} / "for" _ id:Identifier _ "in" _ rangeVar:VariableName _ "step" _ step:UnaryExpression (","/":")? _ e:Expression {
	if (DEBUG) console.log("in For with VariableName and step");
	// Evaluate step if it's an additive expression like "zero minus two"
	let stepValue = step;
	if (step.type === "Additive" && step.operator === "-") {
		if (step.left.type === "IntLiteral" && step.right.type === "IntLiteral") {
			stepValue = {type: "IntLiteral", value: step.left.value - step.right.value};
		}
	}
	// For VariableName, the interpreter will need to resolve this at runtime
	return {
		type: "ForLoop",
		varname: id.varname,
		exp: e,
		range: rangeVar,
		rangeStep: stepValue // Store step separately when range is a variable
	};
} / "for" _ id:Identifier _ "in" _ rangeVar:VariableName (","/":")? _ e:Expression {
	if (DEBUG) console.log("in For with VariableName");
	return {
		type: "ForLoop",
		varname: id.varname,
		exp: e,
		range: rangeVar
	};
} / Range / Comparison

Range  = (("the"/"a") _)? ("range"/"count") _ "from" _ s:NumberLiteral _ "to" _ e:NumberLiteral
{
	if (DEBUG) console.log("in Range");
	// Calculate step based on whether we're counting up or down
	let stepValue = (s.value > e.value) ? -1 : 1;
	return {
		type: "Range",
		start: s,
		end: e,
		step: {type: "IntLiteral", value: stepValue}
	};
} / "from" _ s:NumberLiteral _ "to" _ e:NumberLiteral
{
	if (DEBUG) console.log("in Range (short form)");
	// Calculate step based on whether we're counting up or down
	let stepValue = (s.value > e.value) ? -1 : 1;
	return {
		type: "Range",
		start: s,
		end: e,
		step: {type: "IntLiteral", value: stepValue}
	};
}

Comparison = left:(AdditiveExpression) _ op:(NotEqualTo/GreaterThan/LessThan/LessThanEqualTo/GreaterThanEqualTo/EqualTo) _ right:(Expression)
{
	if (DEBUG) console.log("in Comparison");
	return {
		type: "Comparison",
		operator: op,
		left: left,
		right: right
	};
} / AdditiveExpression

EqualTo = ("is equal to"/"is the same as"/"equals"/"is") { return "=="; }
NotEqualTo = ("is not equal to"/"is different from"/"is not") { return "!="; }
GreaterThan = ("is greater than"/"is more than") { return ">"; }
LessThan = ("is less than"/"is fewer than") { return "<"; }
LessThanEqualTo = ("is less" _ ("than" _)? "or equal to"/"is less" _ ("than" _)? "or the same as") { return "<="; }
GreaterThanEqualTo = ("is greater" _ ("than" _)? "or equal to"/"is more" _ ("than" _)? "or the same as") { return ">="; }


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

UnaryExpression = g:(Range / Literal / VarWithParam / VariableName) c:TypeConvert?
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

VarWithParam = p:(Literal / Identifier) "'s" _ id:Identifier {
	if (DEBUG) console.log("in VarWithParam");
	return {
    	type: "VariableWithParam",
        name: id,
        param: p
    };
} / id:Identifier _ "with" _ p:(Range / Literal / Identifier) {
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