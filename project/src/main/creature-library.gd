class_name CreatureLibrary
"""
Manages data for all creatures in the world, including the player.

This includes their appearance, name and weight.
"""

# How many randomly generated filler creatures have their fatness tracked
const GENERIC_FATNESS_COUNT := 150

# The maximum fatness we'll save for a randomly generated filler creature. We don't want a random creature the player
# has never seen who weighs 10,000 pounds; it would sort of break immersion as they'd wonder "who fed this person!? it
# wasn't me"
const MAX_FILLER_FATNESS := 2.5

# If set, all creatures will have a specific fatness. Used for testing cutscenes.
var forced_fatness := 0.0

var player_def: CreatureDef
var sensei_def: CreatureDef

# fatnesses by creature id
var _fatnesses: Dictionary

# fatnesses saved to roll the tile map back to a previous state
var _saved_fatnesses: Dictionary

# In addition to storing known fatness attributes like "Ebe's weight is 2.5", we store fatnesses for randomly
# generated filler creatures. We rotate their IDs to avoid edge cases where two creatures have the same ID.
var _filler_ids: Array

func _init() -> void:
	_normalize_filler_fatnesses()


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


func reset() -> void:
	# default player appearance and name
	player_def = CreatureDef.new()
	player_def.creature_name = CreatureDef.DEFAULT_NAME
	player_def.creature_short_name = NameUtils.sanitize_short_name(player_def.creature_name)
	player_def.dna = CreatureDef.DEFAULT_DNA.duplicate()
	player_def.min_fatness = 1.0
	player_def.chat_theme_def = CreatureDef.DEFAULT_CHAT_THEME_DEF.duplicate()
	
	if not sensei_def:
		sensei_def = CreatureLoader.load_creature_def_by_id(Global.SENSEI_ID)


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
		Global.PLAYER_ID: player_def.to_json_dict(),
		"fatnesses": _fatnesses,
	}


func from_json_dict(json: Dictionary) -> void:
	reset()
	if json.has(Global.PLAYER_ID):
		player_def.from_json_dict(json.get(Global.PLAYER_ID, {}))
	if json.has("fatnesses"):
		_fatnesses = json.get("fatnesses")
		_normalize_filler_fatnesses()


"""
Populates the fatness for randomly generated filler creatures.
"""
func _normalize_filler_fatnesses() -> void:
	for i in range(GENERIC_FATNESS_COUNT):
		var filler_id := "#filler-%03d#" % i
		_filler_ids.append(filler_id)
		if not _fatnesses.has(filler_id):
			# The initial creature generation is biased toward the thin side of things. That way the progression is
			# more noticable as the generic creatures fatten up.
			_fatnesses[filler_id] = min(Utils.rand_value(Global.FATNESSES), Utils.rand_value(Global.FATNESSES))
	
	_filler_ids.shuffle()
