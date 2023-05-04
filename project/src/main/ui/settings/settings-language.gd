extends HBoxContainer
## UI control for changing the game's language.

const DEFAULT_LOCALE := "en"

@onready var _option_button: OptionButton = $OptionButton

func _ready() -> void:
	# populate the dropdown with the names of available locales
	_option_button.clear()
	for locale in TranslationServer.get_loaded_locales():
		_option_button.add_item(TranslationServer.get_locale_name(locale))
	
	# update the option button's selection to the current locale
	var current_loaded_locale := _current_loaded_locale()
	if TranslationServer.get_loaded_locales().has(_current_loaded_locale()):
		_option_button.selected = TranslationServer.get_loaded_locales().find(_current_loaded_locale())
	else:
		push_warning("Locale '%s' was not in the list of loaded locales" % [current_loaded_locale])


## Returns the loaded locale closest to the translation server's locale.
##
## Locale can be of the form 'll_CC', i.e. language code and regional code, e.g. 'en_US', 'en_GB', etc. It might also
## be simply 'll', e.g. 'en'. To find the relevant translation, we look for those with locale starting with the
## language code, and then if any is an exact match for the long form. If not found, we fall back to a near match
## (another locale with same language code).
##
## This logic aligns with the logic in Godot's source code (core/translation.cpp). I could not find anywhere this logic
## or its result was exposed to GDScript.
func _current_loaded_locale() -> String:
	var result: String
	var translation_server_locale := TranslationServer.get_locale()
	
	if TranslationServer.get_loaded_locales().has(translation_server_locale):
		# found an exact match
		result = translation_server_locale
	
	if result.is_empty():
		# try to find a near match
		for locale in TranslationServer.get_loaded_locales():
			if locale.substr(0, 2) == translation_server_locale.substr(0, 2):
				result = locale
				break
	
	if result.is_empty():
		# no match; default to English
		result = DEFAULT_LOCALE
	
	return result


func _on_OptionButton_item_selected(_index: int) -> void:
	# update the locale to the selected locale
	SystemData.misc_settings.set_locale(TranslationServer.get_loaded_locales()[_index])
