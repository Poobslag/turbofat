extends HBoxContainer
"""
UI control for changing the game's language.
"""

onready var _option_button: OptionButton = $OptionButton

func _ready() -> void:
	# populate the dropdown with the names of available locales
	for locale in TranslationServer.get_loaded_locales():
		_option_button.add_item(TranslationServer.get_locale_name(locale))
	
	# update the option button's selection to the current locale
	_option_button.selected = TranslationServer.get_loaded_locales().find(TranslationServer.get_locale())


func _on_OptionButton_item_selected(_index: int) -> void:
	# update the locale to the selected locale
	TranslationServer.set_locale(TranslationServer.get_loaded_locales()[_index])
