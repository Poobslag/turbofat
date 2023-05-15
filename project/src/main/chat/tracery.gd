class_name Tracery
extends RefCounted
## Implementation of Kate Compton's Tracery.
##
## Tracery is a JavaScript library by GalaxyKate that uses grammars to generate text. This specific implementation is
## adapted from Althar93's GDTracery, a GDscript port of Tracery for Godot Engine 3.1.
## https://github.com/Althar93/GDTracery/blob/f6191894781625b8a8c45923b11f0f79394a896d/scripts/tracery.gd


## Collection of Tracery modifiers.
##
## A Tracery modifier is a function that takes a string (and optionally parameters) and returns a string. A set of
## these is included in mods-eng-basic.js. Modifiers are applied, in order, after a tag is fully expanded.
class Modifiers extends RefCounted:
	
	## Returns a collection of Tracery modifiers for the current locale.
	static func get_modifiers() -> Dictionary:
		var result := {
			"capitalize": [Modifiers, "_capitalize"]
		}
		match TranslationServer.get_locale():
			"es":
				# spanish lacks a possessive suffix
				result = {
					"capitalize": [Modifiers, "_capitalize"]
				}
			_, "en":
				result = {
					"capitalize": [Modifiers, "_capitalize"],
					"possessive": [Modifiers, "_en_possessive"],
				}
		return result


	## Applies an English possessive suffix to a word.
	##
	## _en_possessive("Erik")    = "Erik's"
	## _en_possessive("Doris")   = "Doris'"
	static func _en_possessive(s: String) -> String:
		if s and s[s.length() - 1] == "s":
			return s + "'"
		else:
			return s + "'s"


	static func _capitalize(s: String) -> String:
		return s.capitalize()


## Implementation of a Tracery grammar.
##
## A Grammar is:
## 	* a dictionary of symbols: a key-value object matching keys (the names of symbols) to expansion rules
## 	* optional metadata such as a title, edit data, and author
## 	* optional connectivity graphs describing how symbols call each other
##
## clearState: symbols and rulesets have state (the stack, and possible ruleset state recording recently called
## rules). This function clears any state, returning the dictionary to its original state;
##
## Grammars are usually created by feeding in a raw JSON grammar, which is then parsed into symbols and rules. You can
## also build your own Grammar objects from scratch, without using this utility function, and can always edit the
## grammar after creating it.
class Grammar extends RefCounted:
	var rng: RandomNumberGenerator
	
	## Lookup table for Tracery modifiers such as 's' or 'possessive'.
	##
	## key: (String) Tracery modifier key such as 's' or 'possessive'.
	## value: (Array) Array of two elements defining the modifier function.
	## 	value[0]: (Object) Script containing the modifier function.
	## 	value[1]: (String) Modifier method name.
	var _modifier_lookup: Dictionary = {}
	
	## key: (String) Match name
	## value: (Array/String) Either a single string rule, or an array of possible rules.
	var _rules: Dictionary = {}
	
	## key: (String) Match name
	## value: (Array/String) Either a single string rule, or an array of possible rules.
	var _save_data: Dictionary = {}
	var _expansion_regex: RegEx
	var _save_symbol_regex: RegEx
	
	## List of tracery symbols which should not be processed by the translation server. This includes symbols like
	## '#player#' for the player's name. We do not want to translate the player's name even if it corresponds to an
	## English phrase.
	##
	## key: (String) Tracery symbol like '#player#' which should not be processed
	## value: (bool) true
	var _translation_exempt_symbols: Dictionary = {}


	func _init(rules: Dictionary) -> void:
		# This expansion regex is modified from GDTracery to avoid matching spaces. This prevents us from matching
		# number signs in sentences.
		_expansion_regex = RegEx.new()
		_expansion_regex.compile("(?<!\\[|:)(?!\\])#[^ ]+?(?<!\\[|:)#(?!\\])")
		
		_save_symbol_regex = RegEx.new()
		_save_symbol_regex.compile("\\[.+?\\]")
		
		rng = RandomNumberGenerator.new()
		rng.randomize()
		
		_rules = rules.duplicate(true)


	## Disable translation of the specified symbol.
	##
	## This is used for keywords which should not be processed by the translation server. This includes symbols like
	## '#player#' for the player's name. We do not want to translate the player's name even if it corresponds to an
	## English phrase.
	func add_translation_exempt_symbol(key: String) -> void:
		_translation_exempt_symbols[key] = true


	func add_modifier(key: String, object: Object, function: String) -> void:
		_modifier_lookup[key] = [object, function]


	func add_modifiers(modifiers: Dictionary) -> void:
		for k in modifiers:
			_modifier_lookup[k] = modifiers[k]


	## Replaces all tracery symbols with their appropriate values.
	##
	## Translates the symbol values through Godot's translation engine as well, unless they are in the list of
	## translation-exempt symbols.
	##
	## Parameters:
	## 	'rule': The rule to be flattened, such as 'Hello #player#'.
	func flatten(rule: String) -> String:
		rule = tr(rule)
		
		var expansion_matches := _expansion_regex.search_all(rule)
		if expansion_matches.is_empty():
			_resolve_save_symbols(rule)
		
		for match_result in expansion_matches:
			var match_value: String = match_result.strings[0]
			_resolve_save_symbols(match_value)
			
			# Remove the # surrounding the symbol name
			var match_name := match_value.replace("#", "")
			match_name = tr(match_name)
			
			# Remove the save symbols
			match_name = _save_symbol_regex.sub(match_name, "", true)
			
			# Take match name until the first '.' if it exists
			var dot_index := match_name.find(".")
			if dot_index >= 0:
				match_name = match_name.substr(0, dot_index)
			
			var modifiers := _get_modifiers(match_value)
			
			# Look for the selected rule in either the rules, saved data or as a standalone rule
			var selected_rule = match_name
			if _rules.has(match_name):
				selected_rule = _rules[match_name]
			elif _save_data.has(match_name):
				selected_rule = _save_data[match_name]
			
			# For array rules, select a random item in the array
			if typeof(selected_rule) == TYPE_ARRAY:
				var rand_index: int = rng.randi() % selected_rule.size()
				selected_rule = selected_rule[rand_index] as String
			
			# Run the rule through the translation engine, unless it is exempt from translation
			var resolved: String
			if match_value in _translation_exempt_symbols:
				resolved = selected_rule
			else:
				resolved = flatten(selected_rule)
			
			resolved = _apply_modifiers(resolved, modifiers)
			rule = rule.replace(match_value, resolved)
		
		return rule


	func _resolve_save_symbols(rule: String) -> void:
		var save_matches := _save_symbol_regex.search_all(rule)
		for match_result in save_matches:
			var match_value: String = match_result.strings[0]
			var save := match_value.replace("[", "").replace("]", "")
			var save_split := save.split(":")
			
			if save_split.size() == 2:
				var name := save_split[0]
				var data := flatten(save_split[1])
				_save_data[name] = data
			else:
				var name := save
				var data := flatten("#" + save + "#")
				_save_data[name] = data


	func _get_modifiers(symbol: String) -> PackedStringArray:
		var modifiers := symbol.replace("#", "").split(".")
		modifiers.remove(0)
		return modifiers


	func _apply_modifiers(resolved: String, modifiers: PackedStringArray) -> String:
		for m in modifiers:
			if _modifier_lookup.has(m):
				var object: Object = _modifier_lookup[m][0]
				var function: String = _modifier_lookup[m][1]
				resolved = object.call(function, resolved)
		return resolved
