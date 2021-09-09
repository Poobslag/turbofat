class_name CreatureLibrary
"""
Manages data for all creatures in the world, including the player.

This includes their appearance, name and weight.
"""

# unique creature ids
const SENSEI_ID := "#sensei#"
const PLAYER_ID := "#player#"
const NARRATOR_ID := "#narrator#"

# How many randomly generated filler creatures have their fatness tracked
const GENERIC_FATNESS_COUNT := 150

# The maximum fatness we'll save for a randomly generated filler creature. We don't want a random creature the player
# has never seen who weighs 10,000 pounds; it would sort of break immersion as they'd wonder "who fed this person!? it
# wasn't me"
const MAX_FILLER_FATNESS := 2.5

# If set, all creatures will have a specific fatness. Used for testing cutscenes.
var forced_fatness := 0.0

# Virtual properties; values are only exposed through getters/setters
var player_def: CreatureDef setget set_player_def, get_player_def
var sensei_def: CreatureDef setget set_sensei_def, get_sensei_def

# fatnesses by creature id
var _fatnesses: Dictionary

# fatnesses saved to roll the tilemap back to a previous state
var _saved_fatnesses: Dictionary

# In addition to storing known fatness attributes like "Ebe's weight is 2.5", we store fatnesses for randomly
# generated filler creatures. We rotate their IDs to avoid edge cases where two creatures have the same ID.
var _filler_ids: Array

# Cached creature definitions. This includes all primary and creature json definitions loaded from static json files,
# as well as the player and sensei's definitions.
#
# This is a transient field which is populated on startup, but is not saved anywhere. As its contents not written to
# disk, it should not be modified with the intent of permanently changing a creature's appearance.
#
# key: creature_id
# value: CreatureDef instance with the specified id
var _creature_defs_by_id: Dictionary

func _init() -> void:
	_normalize_filler_fatnesses()


func creature_ids() -> Array:
	return _creature_defs_by_id.keys()


"""
Returns a filler ID.

Pushes the filler ID somewhere toward the back of the queue. The position is slightly randomized to prevent cycles
from emerging.
"""
func next_filler_id() -> String:
	var filler_id: String = _filler_ids.pop_front()
	# warning-ignore:integer_division
	_filler_ids.insert(_filler_ids.size() - randi() % (_filler_ids.size() / 2), filler_id)
	return filler_id


func set_player_def(new_player_def: CreatureDef) -> void:
	_creature_defs_by_id[PLAYER_ID] = new_player_def


func get_player_def() -> CreatureDef:
	return _creature_defs_by_id.get(PLAYER_ID)


func set_sensei_def(new_sensei_def: CreatureDef) -> void:
	_creature_defs_by_id[SENSEI_ID] = new_sensei_def


func get_sensei_def() -> CreatureDef:
	return _creature_defs_by_id.get(SENSEI_ID)


func reset() -> void:
	_creature_defs_by_id.clear()
	_fatnesses.clear()
	
	# default player appearance and name
	var new_player_def := CreatureDef.new()
	new_player_def.rename(CreatureDef.DEFAULT_NAME)
	new_player_def.dna = CreatureDef.DEFAULT_DNA.duplicate()
	new_player_def.min_fatness = 1.0
	new_player_def.chat_theme_def = CreatureDef.DEFAULT_CHAT_THEME_DEF.duplicate()
	set_player_def(new_player_def)
	
	var creature_def_paths := []
	# append sensei path
	creature_def_paths.append(Creatures.SENSEI_PATH)
	
	# append primary paths
	creature_def_paths += _file_paths("res://assets/main/creatures/primary", "/creature.json")
	
	# append secondary paths
	creature_def_paths += _file_paths("res://assets/main/creatures/secondary")
	
	# store load and creature_defs in _creature_defs_by_id
	for path in creature_def_paths:
		var creature_def := CreatureDef.new().from_json_path(path)
		_creature_defs_by_id[creature_def.creature_id] = creature_def


"""
Saves the current fatness state so that we can roll back later.
"""
func save_fatness_state() -> void:
	_saved_fatnesses = _fatnesses.duplicate()


"""
Restores the previously saved fatness state.

This prevents a creature from gaining weight when retrying a level over and over.
Thematically, we're turning back time.
"""
func restore_fatness_state() -> void:
	_fatnesses = _saved_fatnesses.duplicate()


func has_fatness(creature_id: String) -> bool:
	if not creature_id:
		return false
	if forced_fatness:
		return true
	
	return _fatnesses.has(creature_id)


func get_fatness(creature_id: String) -> float:
	if not creature_id:
		return 1.0
	if forced_fatness:
		return forced_fatness
	
	return _fatnesses[creature_id]


func set_fatness(creature_id: String, fatness: float) -> void:
	if not creature_id:
		return
	if forced_fatness:
		# don't persist the temporary fatness when 'forced_fatness' is set
		return
	
	if creature_id.begins_with("#filler"):
		fatness = min(fatness, MAX_FILLER_FATNESS)
	_fatnesses[creature_id] = fatness


func to_json_dict() -> Dictionary:
	return {
		PLAYER_ID: get_player_def().to_json_dict(),
		"fatnesses": _fatnesses,
	}


func from_json_dict(json: Dictionary) -> void:
	reset()
	if json.has(PLAYER_ID):
		var new_player_def := CreatureDef.new()
		new_player_def.from_json_dict(json.get(PLAYER_ID, {}))
		set_player_def(new_player_def)
	if json.has("fatnesses"):
		_fatnesses = json.get("fatnesses")
		_normalize_filler_fatnesses()


func get_creature_def(creature_id: String) -> CreatureDef:
	return _creature_defs_by_id.get(creature_id)


func set_creature_def(creature_id: String, creature_def: CreatureDef) -> void:
	_creature_defs_by_id[creature_id] = creature_def


"""
Populates the fatness for randomly generated filler creatures.
"""
func _normalize_filler_fatnesses() -> void:
	for i in range(GENERIC_FATNESS_COUNT):
		var filler_id := "#filler_%03d#" % i
		_filler_ids.append(filler_id)
		if not _fatnesses.has(filler_id):
			# The initial creature generation is biased toward the thin side of things. That way the progression is
			# more noticable as the generic creatures fatten up.
			_fatnesses[filler_id] = min(Utils.rand_value(Global.FATNESSES), Utils.rand_value(Global.FATNESSES))
	
	_filler_ids.shuffle()


"""
Returns a list of file paths in the specified directory.

This only returns the directory's immediate children, and does not perform a tree traversal.

Parameters:
	'dir_path': The path of the directory to scan
	
	'file_suffix': (Optional) A suffix to append to each returned file path.
"""
func _file_paths(dir_path: String, file_suffix: String = "") -> Array:
	var result := []
	var dir := Directory.new()
	dir.open(dir_path)
	dir.list_dir_begin(true, true)
	while true:
		var file := dir.get_next()
		if file:
			result.append(("%s/%s" % [dir.get_current_dir(), file.get_file()]) + file_suffix)
		else:
			break
	dir.list_dir_end()
	return result
