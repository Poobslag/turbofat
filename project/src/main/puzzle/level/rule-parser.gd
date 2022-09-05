class_name RuleParser
## Serializes and deserializes level rules as json.
##
## Level rules are defined in json with lists of strings like 'tile_set veggie' or 'skip_intro'. This parses those into
## values like 'tile_set=TileSetType.VEGGIE' or 'skip_intro=true'.

## Abstract class which provides a framework for parsing and formatting json strings.
##
## Subclasses can override methods to define their own specialized behavior. A single property parser typically
## corresponds to a single property, although some parsers can populate many properties.
class PropertyParser:
	## The rules class which contains one or more properties to parse.
	## This must be a weak reference to avoid 'ObjectDB instances leaked at exit' warnings.
	var _target: WeakRef
	
	## The name of the property and json key to parse. This is useful for the most common scenario where a single json
	## key maps to a single property. Subclasses can ignore this property if they are doing something unusual.
	var name: String
	
	## The json keys which are handled by this property parser. The RuleParser uses this to decide which PropertyParser
	## to activate.
	var keys := []
	
	## Default value if the json property is omitted.
	var default
	
	## Default value if the json property is specified without a value. For example, a json string like 'skip_intro'
	## might imply a value of 'skip_intro=true' for example.
	var implied
	
	## Parameters:
	## 	'init_target': The rules object with properties to parse.
	##
	## 	'init_name': The name of the property and json key to parse.
	func _init(init_target: Object, init_name: String) -> void:
		_target = weakref(init_target)
		name = init_name
		keys = [name]
	
	
	## Returns the rules class which contains one or more properties to parse.
	##
	## Note: This must be a stored as weak reference and exposed with a function to avoid 'ObjectDB instances leaked at
	## exit' warnings.
	func target() -> Object:
		return _target.get_ref()
	
	
	## Returns one or more json strings corresponding to the rule's current values.
	##
	## This will typically return an array with a single value. However some parsers can populate many properties, in
	## which case they would return multiple values.
	##
	## The default implementation returns a string like 'veg_points 15' with a string representation of the rule's
	## current value. This can be overridden for custom behavior, for example an enum serializer might prefer to write
	## 'tile_set veggie' instead of the default 'tile_set 1'.
	##
	## Returns:
	## 	One or more json strings corresponding to the rule's current values.
	func to_json_strings() -> Array:
		var result: String
		if target().get(name) == implied:
			result = name
		else:
			result = "%s %s" % [name, target().get(name)]
		return [result]
	
	
	## Updates the rule's properties based on the specified json string.
	##
	## The default implementation only works for string fields, and must be overridden to avoid type conversion errors.
	##
	## Parameters:
	## 	'json': The full json string being parsed, such as 'tile_set veggie'.
	func from_json_string(json: String) -> void:
		var split := json.split(" ")
		match split.size():
			1:
				target().set(name, implied)
			2:
				target().set(name, json.split(" ")[1])
	
	
	## Returns 'true' if the rule's property is currently set to the default value.
	##
	## Properties currently set to the default value are omitted from our json output.
	func is_default() -> bool:
		return default == target().get(name)


## Parses a json string like 'skip_intro' into a bool.
class BoolPropertyParser extends PropertyParser:
	## A json string corresponding to a value of 'false', such as 'no_clear_on_finish'
	var _false_string: String
	
	## Parameters:
	## 	'init_target': The rules object with properties to parse.
	##
	## 	'init_name': The name of the property and json key to parse. This json key should correspond to a value of
	## 		'true'.
	##
	## 	'init_false_string': (Optional) A json string corresponding to a value of 'false', such as
	## 		'no_clear_on_finish'
	func _init(init_target: Object, init_name: String, init_false_string: String = "").(init_target, init_name) -> void:
		default = false
		implied = true
		_false_string = init_false_string
		if _false_string: keys = [name, _false_string]
	
	
	## Parses a json string into a boolean value.
	##
	## This covers many use cases:
	## 	'clear': Assigns a value 'clear' to true
	## 	'clear true': Assigns a value 'clear' to true
	## 	'clear false': Assigns a value 'clear' to false
	## 	'no_clear': assigns a value 'clear' to false
	## 	'no_clear true': assigns a value 'clear' to false
	## 	'no_clear false': assigns a value 'clear' to true
	##
	## The values "True", "TRUE", "true" or "1" are treated as true. The values "False", "FALSE", "false" or "0" are
	## treated as false.
	##
	## Parameters:
	## 	'json': The full json string being parsed, such as 'clear' or 'no_clear true'.
	func from_json_string(json: String) -> void:
		var split := json.split(" ")
		match split.size():
			1:
				match split[0]:
					name:
						# parse positive string like 'clear_on_finish'
						target().set(name, true)
					_false_string:
						# parse negative string like 'no_clear_on_finish'
						target().set(name, false)
					_:
						push_warning("Unrecognized: %s" % [split[0]])
			2:
				match split[0]:
					name:
						# parse compound string like 'clear_on_finish true'
						target().set(name, true if Utils.to_bool(split[1]) else false)
					_false_string:
						# parse negative compound string like 'no_clear_on_finish false' (why...)
						target().set(name, false if Utils.to_bool(split[1]) else true)
					_:
						push_warning("Unrecognized: %s" % [split[0]])
	
	
	## Returns an array with a json string like 'clear' corresponding to the rule's current value.
	##
	## This returns a short value like 'clear' or 'no_clear' if possible, or a verbose value like 'clear false' if no
	## false string is defined.
	##
	## Returns:
	## 	An array with a json string like 'clear' corresponding to the rule's current value.
	func to_json_strings() -> Array:
		var result: String
		if target().get(name) == true:
			# return positive string like 'clear_on_finish'
			result = name
		elif _false_string:
			# return negative string like 'no_clear_on_finish'
			result = _false_string
		else:
			# return compound string like 'clear_on_finish false'
			result = "%s %s" % [name, target().get(name)]
		return [result]


## Parses a json string like 'box_factor 0.5' into a float.
class FloatPropertyParser extends PropertyParser:
	func _init(init_target: Object, init_name: String).(init_target, init_name) -> void:
		default = 0.0
	
	
	func from_json_string(json: String) -> void:
		var split := json.split(" ")
		match split.size():
			1:
				target().set(name, implied)
			2:
				target().set(name, float(json.split(" ")[1]))
	
	
	func is_default() -> bool:
		return is_equal_approx(default, target().get(name))


## Parses a json string like 'veg_points 10' into an int.
class IntPropertyParser extends PropertyParser:
	func _init(init_target: Object, init_name: String).(init_target, init_name) -> void:
		default = 0
	
	
	func from_json_string(json: String) -> void:
		var split := json.split(" ")
		match split.size():
			1:
				target().set(name, implied)
			2:
				target().set(name, int(json.split(" ")[1]))


## Parses a json string like 'start_level level_10' into a string like "level_10".
class StringPropertyParser extends PropertyParser:
	func _init(init_target: Object, init_name: String).(init_target, init_name) -> void:
		default = ""


## Parses a json string like 'tile_set veggie' into an enum like 'TileSetType.VEGGIE'
##
## This parser assumes all json strings are lower case snake case strings like 'time_over', and all enum values are
## upper case snake case strings like 'TIME_OVER'.
class EnumPropertyParser extends PropertyParser:
	## key: (String) upper case snake case enum key
	## value: (int) an enum index
	var _enum_dict: Dictionary
	
	## Parameters:
	## 	'init_target': The rules object with properties to parse.
	##
	## 	'init_name': The name of the property and json key to parse.
	##
	## 	'init_enum_dict': The property's enum type, such as 'PuzzleTileMap.TileSetType'
	func _init(init_target: Object, init_name: String, init_enum_dict).(init_target, init_name) -> void:
		_enum_dict = init_enum_dict
		default = 0
		implied = 0
	
	
	func from_json_string(json: String) -> void:
		var split := json.split(" ")
		match split.size():
			1:
				target().set(name, implied)
			2:
				var snake_case_enum: String = json.split(" ")[1]
				if not _enum_dict.has(snake_case_enum.to_upper()):
					push_warning("Unrecognized %s: %s" % [json.split(" ")[0], json.split(" ")[1]])
				else:
					target().set(name, Utils.enum_from_snake_case(_enum_dict, snake_case_enum))
	
	
	func to_json_strings() -> Array:
		var result: String
		if target().get(name) == implied:
			result = name
		else:
			result = "%s %s" % [name, Utils.enum_to_snake_case(_enum_dict, target().get(name))]
		return [result]


## Allows for extended configuration of properties.
class OngoingPropertyDefinition:
	var _property_parser: PropertyParser
	
	func _init(init_property_parser: PropertyParser) -> void:
		_property_parser = init_property_parser
	
	
	## Sets the default value to use when the json property is omitted.
	##
	## Parameters:
	## 	'new_default': A default value, such as 'true', '0.0', or TileSetType.DEFAULT
	func default(new_default) -> void:
		_property_parser.default = new_default
	
	
	## Sets the implied value to use when the json property is specified without a value.
	##
	## Parameters:
	## 	'new_default': An implied value, such as 'true', '0.0', or TileSetType.DEFAULT
	func implied(new_implied) -> void:
		_property_parser.implied = new_implied

## The rules class which contains one or more properties to parse.
## This must be a weak reference to avoid 'ObjectDB instances leaked at exit' warnings.
var _target: WeakRef

## List of PropertyParser instances for serializing and deserializing json. This array's order dictates the order the
## properties will be written to the json file.
var _property_parsers := []

## key: (String) json key such as 'clear_on_finish' or 'piece_j'
## value: (PropertyParser) PropertyParser instance which is activated for the specified key
var _property_parsers_by_key := {}

func _init(init_target: Object) -> void:
	_target = weakref(init_target)


## Adds a boolean property parser.
##
## Parameters:
## 	'name': The name of the property and json key to parse. This json key should correspond to a value of 'true'.
##
## 	'false_string': (Optional) A json string corresponding to a value of 'false', such as 'no_clear_on_finish'
func add_bool(name: String, false_string: String = "") -> OngoingPropertyDefinition:
	return add(BoolPropertyParser.new(_target.get_ref(), name, false_string))


## Adds an enum property parser.
##
## Parameters:
## 	'name': The name of the property and json key to parse.
##
## 	'enum_dict': The property's enum type, such as 'PuzzleTileMap.TileSetType'
func add_enum(name: String, enum_dict: Dictionary) -> OngoingPropertyDefinition:
	return add(EnumPropertyParser.new(_target.get_ref(), name, enum_dict))


## Adds a float property parser.
##
## Parameters:
## 	'name': The name of the property and json key to parse.
func add_float(name: String) -> OngoingPropertyDefinition:
	return add(FloatPropertyParser.new(_target.get_ref(), name))


## Adds an int property parser.
##
## Parameters:
## 	'name': The name of the property and json key to parse.
func add_int(name: String) -> OngoingPropertyDefinition:
	return add(IntPropertyParser.new(_target.get_ref(), name))


## Adds a string property parser.
##
## Parameters:
## 	'name': The name of the property and json key to parse.
func add_string(name: String) -> OngoingPropertyDefinition:
	return add(StringPropertyParser.new(_target.get_ref(), name))


## Adds a custom property parser.
##
## Parameters:
## 	'property_parser': Defines behavior for parsing and formatting json strings.
func add(property_parser: PropertyParser) -> OngoingPropertyDefinition:
	_property_parsers.append(property_parser)
	for rule_key in property_parser.keys:
		_property_parsers_by_key[rule_key] = property_parser
	var ongoing_rule_definition := OngoingPropertyDefinition.new(property_parser)
	return ongoing_rule_definition


## Updates the rule's properties based on the specified json strings.
##
## Parameters:
## 	'json': An array of json strings to parse, such as 'tile_set veggie'.
func from_json_array(json: Array) -> void:
	for json_string in json:
		var split: Array = json_string.split(" ")
		if not _property_parsers_by_key.has(split[0]):
			push_warning("Unrecognized: %s" % [split[0]])
			continue
		var property_parser: PropertyParser = _property_parsers_by_key[split[0]]
		property_parser.from_json_string(json_string)


## Returns a minimal list of json strings corresponding to the rule's current values.
##
## Properties which are set to their default value are omitted from the resulting list. If all properties are assigned
## to their default value, the list will be empty.
func to_json_array() -> Array:
	var result := []
	for property_parser in _property_parsers:
		if not property_parser.is_default():
			result.append_array(property_parser.to_json_strings())
	return result


## Returns 'true' if all of the rule's properties are currently set to their default values.
##
## Rules whose properties are set to their default values are omitted from our json output.
func is_default() -> bool:
	var result := true
	for property_parser in _property_parsers:
		if not property_parser.is_default():
			result = false
			break
	return result
