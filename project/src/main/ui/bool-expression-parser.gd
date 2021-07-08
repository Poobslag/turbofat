class_name BoolExpressionParser
"""
Parses a string boolean expression into a tree of BoolExpressions.

This is a recursive descent parser.
"""

"""
A lexical token which occurs in a boolean expression.

This token represents a single word, and includes data about the occurrence of the word in the original statement.
"""
class BoolToken:
	var position: int
	var string: String
	
	func _init(init_position: int, init_string: String) -> void:
		position = init_position
		string = init_string
	
	func string_value() -> String:
		return string


"""
An node in a tree of boolean expressions.

This node includes information about how to evaluate the expression and its children.
"""
class BoolExpression:
	var token: BoolToken
	var args: Array
	
	func evaluate() -> bool:
		return false
	
	
	func string_value() -> String:
		return "%s [%s]" % [token, args]


class OrExpression extends BoolExpression:
	func _init(new_token: BoolToken, left: BoolExpression, right: BoolExpression) -> void:
		token = new_token
		args = [left, right]
	
	
	func evaluate() -> bool:
		return args[0].evaluate() or args[1].evaluate()


class AndExpression extends BoolExpression:
	func _init(new_token: BoolToken, left: BoolExpression, right: BoolExpression) -> void:
		token = new_token
		args = [left, right]
	
	
	func evaluate() -> bool:
		return args[0].evaluate() and args[1].evaluate()


class NotExpression extends BoolExpression:
	func _init(new_token: BoolToken, child: BoolExpression) -> void:
		token = new_token
		args = [child]
	
	
	func evaluate() -> bool:
		return not args[0].evaluate()


class ChatFinishedExpression extends BoolExpression:
	func _init(new_token: BoolToken, arg: BoolToken) -> void:
		token = new_token
		args = [arg]
	
	
	func evaluate() -> bool:
		return PlayerData.chat_history.is_chat_finished(args[0].string)


class LevelFinishedExpression extends BoolExpression:
	func _init(new_token: BoolToken, arg: BoolToken) -> void:
		token = new_token
		args = [arg]
	
	
	func evaluate() -> bool:
		return PlayerData.level_history.is_level_finished(args[0].string)


class NotableExpression extends BoolExpression:
	var _creature_id: String
	
	func _init(new_token: BoolToken, creature_id: String) -> void:
		token = new_token
		_creature_id = creature_id
	
	
	func evaluate() -> bool:
		return PlayerData.chat_history.get_filler_count(_creature_id) > 0

# error encountered when parsing the boolean string
var _parse_error: String

# list of parsed BoolToken instances
var _tokens := []

# the index of the next BoolToken to process in the token array
var _token_index := 0

# the boolean string to parse
var _string: String

# The target for which the boolean string is being evaluated, if evaluated for a specific creature or level.
var _subject

"""
Initializes the parser, parsing the specified string into a list of BoolTokens.

Parameters:
	'string': The boolean expression to parse.
	
	'subject': The subject the specified boolean expression should be applied to, such as a level or creature
"""
func _init(string: String, subject = null) -> void:
	_string = string
	_subject = subject
	var regex := RegEx.new()
	regex.compile("[^() ]+|[()]")
	for result in regex.search_all(string):
		var chat_token := BoolToken.new(result.get_start(), result.get_string())
		_tokens.append(chat_token)


"""
Parses a list of BoolTokens into a tree of BoolExpressions which can be evaluated.

Returns:
	The root of a BoolExpression tree representing the parsed boolean string.
"""
func parse() -> BoolExpression:
	var expression := _parse_or()
	if _token_index < _tokens.size():
		_report_error(_tokens[_token_index].position, "Unexpected token '%s'" % [_tokens[_token_index].string])
	return expression


"""
Parses an 'or' chat token, as well as any tokens of higher precedence (and, not, functions, parentheses).
"""
func _parse_or() -> BoolExpression:
	if _parse_error:
		return null
	
	var expression := _parse_and()
	if _peek_next_token_string() == "or":
		expression = OrExpression.new(_get_next_token(), expression, _parse_and())
	return expression


"""
Parses an 'and' chat token, as well as any tokens of higher precedence (not, functions, parentheses).
"""
func _parse_and() -> BoolExpression:
	if _parse_error:
		return null
	
	var expression := _parse_not()
	if _peek_next_token_string() == "and":
		expression = AndExpression.new(_get_next_token(), expression, _parse_not())
	return expression


"""
Parses a 'not' chat token, as well as any tokens of higher precedence (functions, parentheses).
"""
func _parse_not() -> BoolExpression:
	if _parse_error:
		return null
	
	var expression: BoolExpression
	if _peek_next_token_string() == "not":
		expression = NotExpression.new(_get_next_token(), _parse_function())
	else:
		expression = _parse_function()
	return expression


"""
Parses a 'function' chat token, specifying a function to be evaluated.

Also evaluates any tokens of higher precedence (parentheses).
"""
func _parse_function() -> BoolExpression:
	if _parse_error:
		return null
	
	var expression: BoolExpression
	match _peek_next_token_string():
		"chat_finished":
			expression = ChatFinishedExpression.new(_get_next_token(), _get_next_token())
		"level_finished":
			expression = LevelFinishedExpression.new(_get_next_token(), _get_next_token())
		"notable":
			if _subject is String:
				expression = NotableExpression.new(_get_next_token(), _subject)
			else:
				_report_error(_get_next_token().position, "Keyword %s cannot be applied to type '%s'" \
						% [_subject, null if _subject == null else _subject.get_class()])
		_:
			expression = _parse_atom()
	return expression


"""
Parses an 'atom' chat token; a series of tokens within parentheses.

Reports errors if the next chat token is not an open parenthesis.
"""
func _parse_atom() -> BoolExpression:
	if _parse_error:
		return null
	
	var expression: BoolExpression
	var token := _get_next_token()
	if token.string == "(":
		expression = _parse_or()
		_expect_token(")")
	else:
		_report_error(token.position, "Unexpected token '%s'" % [token.string])
	
	return expression


"""
Advances to the next token, throwing an error if it does not match the specified token string.
"""
func _expect_token(token_string: String) -> void:
	var next_token := _peek_next_token()
	if not next_token:
		_report_error(_string.length(), "Expected '%s'" % [token_string])
		return
	elif next_token.string != token_string:
		_report_error(next_token.position, "Expected '%s' but found '%s'" % [token_string, next_token.string])
		return
	
	_get_next_token()


"""
Returns the next token without advancing the token index.
"""
func _peek_next_token() -> BoolToken:
	var next_token: BoolToken = null
	if _token_index < _tokens.size():
		next_token = _tokens[_token_index]
	return next_token


"""
Returns the next token string without advancing the token index.
"""
func _peek_next_token_string() -> String:
	var next_token := _peek_next_token()
	return next_token.string if next_token else ""


"""
Returns the next token and advances the token index.
"""
func _get_next_token() -> BoolToken:
	var next_token: BoolToken = null
	if _token_index < _tokens.size():
		next_token = _tokens[_token_index]
		_token_index += 1
	return next_token


"""
Records and reports a parse error.

This error is recorded to ensure the parser doesn't continue parsing and encountering further errors. It is also
recorded for unit tests.
"""
func _report_error(position: int, error_description: String) -> void:
	if _parse_error:
		# don't report a second error. it's redundant and overwrites the first
		return
	
	_parse_error = "Error parsing \"%s\"(%s): %s" % [_string, position, error_description]
	push_error(_parse_error)
