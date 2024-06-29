class_name CreatureSaver
extends Node
## Saves the creature in the creature editor.
##
## This occurs either in response to the player clicking the "save" button or answering a dialog prompt.

signal creature_saved

export (NodePath) var overworld_environment_path: NodePath

onready var _overworld_environment: OverworldEnvironment = get_node(overworld_environment_path)

## Saves the creature and launches some visual effects.
func save_creature() -> void:
	if not has_unsaved_changes():
		return
	
	PlayerData.creature_library.player_def = _overworld_environment.player.get_creature_def()
	PlayerSave.save_player_data()
	_overworld_environment.player.play_mood(Utils.rand_value([
			Creatures.Mood.SMILE0,
			Creatures.Mood.SMILE1,
			Creatures.Mood.WAVE0,
			Creatures.Mood.WAVE1,
			Creatures.Mood.LAUGH0,
			Creatures.Mood.LAUGH1,
			Creatures.Mood.YES0,
			Creatures.Mood.YES1,
	]))
	emit_signal("creature_saved")


func has_unsaved_changes() -> bool:
	return not _is_creature_def_equal(PlayerData.creature_library.get_player_def(),
			_overworld_environment.player.get_creature_def())


func _is_creature_def_equal(def1: CreatureDef, def2: CreatureDef) -> bool:
	var dict1 := _trim_creature_def(def1.to_json_dict())
	var dict2 := _trim_creature_def(def2.to_json_dict())
	return Utils.is_json_deep_equal(dict1, dict2)


func _trim_creature_def(dict: Dictionary) -> Dictionary:
	# The 'customer_if' flag interferes with comparison, so we remove it temporarily.
	dict.erase("customer_if")
	return dict
