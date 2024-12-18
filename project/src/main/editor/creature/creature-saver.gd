class_name CreatureSaver
extends Node
## Saves the creature in the creature editor.
##
## This occurs either in response to the player clicking the "save" button or answering a dialog prompt.

signal save_button_pressed

export (NodePath) var overworld_environment_path: NodePath

## Most recently imported creature definition.
##
## When importing a creature, we don't prompt the player to save if they haven't made changes to the previously
## imported creature. Otherwise, it's tedious to keep being prompted if you import multiple creatures in a row.
var _imported_def: CreatureDef

onready var _overworld_environment: OverworldEnvironment = get_node(overworld_environment_path)

## Saves the creature and launches some visual effects.
func save_creature() -> void:
	if not has_unsaved_changes():
		return
	
	if not _overworld_environment.player:
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
	emit_signal("save_button_pressed")


func has_unsaved_changes() -> bool:
	return not _is_creature_def_equal(PlayerData.creature_library.get_player_def(),
			_overworld_environment.player.get_creature_def())


## Returns 'true' if the currently edited creature def is the same one that was just imported.
func is_freshly_imported_creature_def() -> bool:
	return _imported_def and _is_creature_def_equal(_imported_def, _overworld_environment.player.get_creature_def())


func _is_creature_def_equal(def1: CreatureDef, def2: CreatureDef) -> bool:
	var dict1 := _trim_creature_def(def1.to_json_dict())
	var dict2 := _trim_creature_def(def2.to_json_dict())
	return Utils.is_json_deep_equal(dict1, dict2)


func _trim_creature_def(dict: Dictionary) -> Dictionary:
	# The 'customer_if' flag interferes with comparison, so we remove it temporarily.
	dict.erase("customer_if")
	return dict


## When a creature is imported, we update our cached '_imported_def' to avoid prompting the player unnecessarily.
func _on_Import_file_selected(path: String) -> void:
	_imported_def = CreatureDef.new().from_json_path(path)
	if _imported_def:
		_imported_def.creature_id = CreatureLibrary.PLAYER_ID
