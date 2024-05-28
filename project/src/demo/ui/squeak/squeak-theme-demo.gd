extends Node
## Demonstrates the 'squeak theme', a simpler compact UI used in the settings menu.

onready var _panel := $Panel

func _ready() -> void:
	_initialize_option_button()
	_initialize_tab_container()


func _initialize_option_button() -> void:
	var _option_button: OptionButton = $Panel/OptionButton
	_option_button.add_item("OptionButton")
	_option_button.add_item("PoptionButton")
	_option_button.add_item("QuoptionButton")
	_option_button.add_separator()
	_option_button.add_item("RoptionButton")
	_option_button.add_item("SoptionButton")
	_option_button.add_separator()
	_option_button.add_item("ToptionButton")


func _initialize_tab_container() -> void:
	var _tab_container: TabContainer = $Panel/TabContainer
	_tab_container.set_tab_disabled(2, true)
