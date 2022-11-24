extends "res://addons/gut/test.gd"

var rules := {}

func before_each() -> void:
	rules.clear()


# GDTracery's original set_rng() implementation had a bug
# https://github.com/Althar93/GDTracery/issues/2
func test_set_rng() -> void:
	var grammar := Tracery.Grammar.new(rules)
	var new_rng := RandomNumberGenerator.new()
	grammar.rng = new_rng
	assert_eq(grammar.rng, new_rng)


func test_replace() -> void:
	rules["favorite_color"] = ["blue"]
	
	assert_flatten("My favorite color is #favorite_color#.", "My favorite color is blue.")


func test_rule_undefined() -> void:
	assert_flatten("My favorite color is #favorite_color#.", "My favorite color is favorite_color.")


func test_pound_signs() -> void:
	assert_flatten("I'm your #1 fan. #1!", "I'm your #1 fan. #1!")


## English has a possessive modifier. Nouns are suffixed with "'s".
func test_modifier_possessive_en() -> void:
	var original_locale := TranslationServer.get_locale()
	TranslationServer.set_locale("en")
	
	rules["person"] = ["Erik"]
	assert_flatten("What's #person.possessive# problem?", "What's Erik's problem?")
	
	rules["person"] = ["Doris"]
	assert_flatten("What's #person.possessive# problem?", "What's Doris' problem?")
	
	rules["person"] = [""]
	assert_flatten("What's #person.possessive# problem?", "What's 's problem?")
	
	TranslationServer.set_locale(original_locale)


## Spanish has no possessive modifier. Returning the unmodified input is grammatically correct.
func test_modifier_possessive_es() -> void:
	var original_locale := TranslationServer.get_locale()
	TranslationServer.set_locale("es")
	rules["person"] = ["Erik"]
	assert_flatten("¿Dónde está el lápiz de #person.possessive#?", "¿Dónde está el lápiz de Erik?")
	
	rules["person"] = ["Doris"]
	assert_flatten("¿Dónde está el lápiz de #person.possessive#?", "¿Dónde está el lápiz de Doris?")
	
	rules["person"] = [""]
	assert_flatten("¿Dónde está el lápiz de #person.possessive#?", "¿Dónde está el lápiz de ?")
	
	TranslationServer.set_locale(original_locale)


func assert_flatten(rule: String, expected: String) -> void:
	var grammar := Tracery.Grammar.new(rules)
	grammar.add_modifiers(Tracery.Modifiers.get_modifiers())
	assert_eq(grammar.flatten(rule), expected)
