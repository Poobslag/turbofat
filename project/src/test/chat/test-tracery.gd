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


## Messages and symbols should be translated into other languages.
func test_replace_es() -> void:
	var original_locale := TranslationServer.get_locale()
	TranslationServer.set_locale("es")
	var translation: Translation = Translation.new()
	translation.add_message("My favorite color is #favorite_color#.", "Mi color favorito es el #favorite_color#.")
	translation.add_message("blue", "azul")
	translation.locale = "es"
	TranslationServer.add_translation(translation)
	
	rules["favorite_color"] = ["blue"]
	assert_flatten("My favorite color is #favorite_color#.", "Mi color favorito es el azul.")
	
	TranslationServer.set_locale(original_locale)


## Player name should be exempt from translation.
##
## We cannot prevent all translation of the player name until we fix #1791.
func test_dont_translate_player_name() -> void:
	var original_locale := TranslationServer.get_locale()
	TranslationServer.set_locale("es")
	var translation: Translation = Translation.new()
	translation.add_message("Sue", "Demandar")
	translation.locale = "es"
	TranslationServer.add_translation(translation)
	
	rules["bad_restaurant_name"] = ["Sue"]
	assert_flatten("Bottle support #bad_restaurant_name#", "Bottle support Demandar")
	
	rules["player"] = ["Sue"]
	assert_flatten("Bottle support #player#", "Bottle support Sue")
	
	rules["player"] = ["Sue"]
	assert_flatten("#player#", "Sue")
	
	TranslationServer.set_locale(original_locale)


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
	grammar.add_translation_exempt_symbol("#player#")
	grammar.add_modifiers(Tracery.Modifiers.get_modifiers())
	assert_eq(grammar.flatten(rule), expected)
