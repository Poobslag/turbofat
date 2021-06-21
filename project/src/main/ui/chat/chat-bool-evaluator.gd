class_name ChatBoolEvaluator
"""
Evaluates boolean expressions.

This includes expressions like 'not (level_finished level_001 or level_finished level_002)'.
"""

"""
Evaluates the specified boolean expression based on the current game state.

Parameters:
	'string': The boolean expression to evaluate.
	
	'subject': The subject the specified boolean expression should be applied to.

Returns:
	'true' if the specified boolean expression is met by the current game state.
"""
static func evaluate(string: String, subject = null) -> bool:
	var parser: ChatBoolParser = ChatBoolParser.new(string, subject)
	var expression: ChatBoolParser.BoolExpression = parser.parse()
	return expression.evaluate()
