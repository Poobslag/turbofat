class_name FatnessChanger
extends Node
## Increases/decreases the player's fatness in the creature editor.

const MIN_FATNESS := 1.0
const MAX_FATNESS := 2.5

export (NodePath) var overworld_environment_path: NodePath

## The currently shown 'fatness_down' button, or 'null' if none is currently shown.
var fatness_down_button: OperationButton

## The currently shown 'fatness_up' button, or 'null' if none is currently shown.
var fatness_up_button: OperationButton

onready var _overworld_environment: OverworldEnvironment = get_node(overworld_environment_path)
onready var _fatness_change_sound := $FatnessChangeSound

func _ready() -> void:
	_player().connect("fatness_changed", self, "_on_Creature_fatness_changed")


func _player() -> Creature:
	return _overworld_environment.player


func _decrease_fatness() -> void:
	if not _player():
		return
	
	if _player().min_fatness <= MIN_FATNESS:
		return
	
	_player().min_fatness = clamp(_player().min_fatness - 0.1, MIN_FATNESS, MAX_FATNESS)
	_player().fatness = _player().min_fatness
	_fatness_change_sound.play()


func _increase_fatness() -> void:
	if not _player():
		return
	
	if _player().min_fatness >= MAX_FATNESS:
		return
	
	_player().min_fatness = clamp(_player().min_fatness + 0.1, MIN_FATNESS, MAX_FATNESS)
	_player().fatness = _player().min_fatness
	_fatness_change_sound.play()


func _find_operation_button(id: String) -> OperationButton:
	var result: OperationButton
	for operation_button in get_tree().get_nodes_in_group("operation_buttons"):
		if operation_button.id == id:
			result = operation_button
			break
	return result


func _on_AlleleButtons_operation_button_pressed(operation_id: String) -> void:
	match operation_id:
		"fatness_down":
			_decrease_fatness()
		"fatness_up":
			_increase_fatness()


func _on_AlleleButtons_allele_buttons_refreshed() -> void:
	fatness_down_button = _find_operation_button("fatness_down")
	fatness_up_button = _find_operation_button("fatness_up")


## When the creature's fatness changes, we enable/disable the fatness_down and fatness_up buttons appropriately.
func _on_Creature_fatness_changed() -> void:
	if fatness_down_button and is_instance_valid(fatness_down_button):
		fatness_down_button.set_disabled(_player().fatness <= MIN_FATNESS)
	if fatness_up_button and is_instance_valid(fatness_up_button):
		fatness_up_button.set_disabled(_player().fatness >= MAX_FATNESS)
