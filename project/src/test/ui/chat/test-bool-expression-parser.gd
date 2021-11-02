extends "res://addons/gut/test.gd"

var parser: BoolExpressionParser

func assert_token(token: BoolExpressionParser.BoolToken, string: String, position: int = -1) -> void:
	assert_not_null(token)
	assert_eq(token.string, string)
	if position != -1:
		assert_eq(token.position, position)


func assert_expression(expression: BoolExpressionParser.BoolExpression, token: String, args: Array) -> void:
	assert_token(expression.token, token)
	assert_eq(expression.args.size(), args.size())
	for i in range(args.size()):
		assert_eq(expression.args[i].string, args[i])


func parse_tokens(string: String) -> Array:
	parser = BoolExpressionParser.new(string)
	return parser._tokens


func parse_expression(string: String) -> BoolExpressionParser.BoolExpression:
	parser = BoolExpressionParser.new(string)
	return parser.parse()


func test_parse_tokens_empty() -> void:
	var tokens := parse_tokens("")
	
	assert_eq(tokens.size(), 0)


func test_parse_tokens_many() -> void:
	var tokens := parse_tokens("chat_finished abc")
	
	assert_eq(tokens.size(), 2)
	assert_token(tokens[0], "chat_finished", 0)
	assert_token(tokens[1], "abc", 14)


func test_parse_tokens_parens() -> void:
	var tokens := parse_tokens("(not (chat_finished abc))")
	
	assert_eq(tokens.size(), 7)
	assert_token(tokens[0], "(", 0)
	assert_token(tokens[1], "not", 1)
	assert_token(tokens[2], "(", 5)
	assert_token(tokens[3], "chat_finished", 6)
	assert_token(tokens[4], "abc", 20)
	assert_token(tokens[5], ")", 23)
	assert_token(tokens[6], ")", 24)


func test_parse_expression() -> void:
	var expression := parse_expression("chat_finished abc")
	assert_expression(expression, "chat_finished", ["abc"])


func test_parse_expression_and() -> void:
	var expression := parse_expression("chat_finished abc and chat_finished def")
	
	# assert: chat_finished abc [AND] chat_finished def
	assert_token(expression.token, "and")
	assert_eq(expression.args.size(), 2)
	
	# assert: [CHAT_FINISHED ABC] and chat_finished def
	assert_expression(expression.args[0], "chat_finished", ["abc"])
	
	# assert: chat_finished abc and [CHAT_FINISHED DEF]
	assert_expression(expression.args[1], "chat_finished", ["def"])


func test_parse_expression_not() -> void:
	var expression := parse_expression("not chat_finished abc")
	
	assert_token(expression.token, "not")
	assert_eq(expression.args.size(), 1)
	assert_expression(expression.args[0], "chat_finished", ["abc"])


func test_parse_expression_or() -> void:
	var expression := parse_expression("chat_finished abc or chat_finished def")
	
	# assert: chat_finished abc [OR] chat_finished def
	assert_token(expression.token, "or")
	assert_eq(expression.args.size(), 2)
	
	# assert: [CHAT_FINISHED ABC] or chat_finished def
	assert_expression(expression.args[0], "chat_finished", ["abc"])
	
	# assert: chat_finished abc or [CHAT_FINISHED DEF]
	assert_expression(expression.args[1], "chat_finished", ["def"])


func test_parse_expression_parentheses_0() -> void:
	var expression := parse_expression("(chat_finished abc)")
	
	assert_expression(expression, "chat_finished", ["abc"])


func test_parse_expression_parentheses_1() -> void:
	var expression := parse_expression("not (chat_finished abc or chat_finished def)")
	
	# assert: [NOT] (chat_finished abc or chat_finished def)
	assert_token(expression.token, "not")
	assert_eq(expression.args.size(), 1)
	
	# assert: not (chat_finished abc [OR] chat_finished def)
	assert_token(expression.args[0].token, "or")
	assert_eq(expression.args[0].args.size(), 2)
	
	# assert: not ([CHAT_FINISHED ABC] or chat_finished def)
	assert_expression(expression.args[0].args[0], "chat_finished", ["abc"])
	
	# assert: not (chat_finished abc or [CHAT_FINISHED DEF])
	assert_expression(expression.args[0].args[1], "chat_finished", ["def"])


func test_parse_expression_order_of_operations() -> void:
	var expression := parse_expression("not chat_finished def and chat_finished ghi or chat_finished abc")
	
	# assert: 'not chat_finished def and chat_finished ghi [OR] chat_finished abc'
	assert_token(expression.token, "or")
	assert_eq(expression.args.size(), 2)
	
	# assert: 'not chat_finished def [AND] chat_finished ghi or chat_finished abc'
	assert_token(expression.args[0].token, "and")
	assert_eq(expression.args.size(), 2)
	
	# assert: '[NOT CHAT_FINISHED DEF] and chat_finished ghi or chat_finished abc'
	assert_token(expression.args[0].args[0].token, "not")
	assert_eq(expression.args[0].args[0].args.size(), 1)
	assert_expression(expression.args[0].args[0].args[0], "chat_finished", ["def"])
	
	# assert: 'not chat_finished def and [CHAT_FINISHED GHI] or chat_finished abc'
	assert_expression(expression.args[0].args[1], "chat_finished", ["ghi"])
	
	# assert: 'not chat_finished def and chat_finished ghi or [CHAT_FINISHED ABC]
	assert_expression(expression.args[1], "chat_finished", ["abc"])


func test_syntax_error_misspelling() -> void:
	parse_expression("chab_finished abc")
	
	assert_eq(parser._parse_error, "Error parsing \"chab_finished abc\"(0): Unexpected token 'chab_finished'")


func test_syntax_error_missing_paren() -> void:
	parse_expression("(chat_finished abc or chat_finished def")
	
	assert_eq(parser._parse_error, "Error parsing \"(chat_finished abc or chat_finished def\"(39): Expected ')'")


func test_syntax_error_duplicate_keyword() -> void:
	parse_expression("chat_finished abc and and chat_finished def")
	
	assert_eq(parser._parse_error,
			"Error parsing \"chat_finished abc and and chat_finished def\"(22): Unexpected token 'and'")


func test_syntax_error_misplaced_keyword() -> void:
	parse_expression("or chat_finished abc")
	
	assert_eq(parser._parse_error, "Error parsing \"or chat_finished abc\"(0): Unexpected token 'or'")
