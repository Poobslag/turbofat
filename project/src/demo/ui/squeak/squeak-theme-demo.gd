extends Node
## Demonstrates the 'squeak theme', a simpler compact UI used in the settings menu.

onready var _panel := $Panel

func _ready() -> void:
	_initialize_tab_container()


func _initialize_tab_container() -> void:
	var _tab_container: TabContainer = $Panel/TabContainer
	_tab_container.set_tab_disabled(2, true)
