class_name PlayfieldEditorControl
extends HBoxContainer
## UI control for editing the playfield.
##
## This includes adding/removing blocks to the playfield. It also includes adding, removing and selecting different
## groups of level tiles.

## emitted when a group of level tiles is added, removed, or selected
signal tiles_keys_changed(tiles_keys, tiles_key)
## emitted when the playfield's contents change, such as when blocks are added or removed
signal tile_map_changed
## emitted when the playfield's pickups change
signal pickups_changed

## tiles keys which can be selected. 'start' is always the first item in this array
var tiles_keys := ["start"] setget set_tiles_keys
## currently selected tiles key
var tiles_key := "start" setget set_tiles_key

onready var _playfield_nav := $PlayfieldNav
onready var _rotate_button := $Palette/VBoxContainer/Buttons/RotateButton
onready var _next_button := $Palette/VBoxContainer/Buttons/NextButton
onready var _prev_button := $Palette/VBoxContainer/Buttons/PrevButton

func _ready() -> void:
	_connect_chunk_control_listeners()


## Updates the list of selectable tiles keys.
##
## The incoming tiles keys are sanitized to ensure they are sorted, and that they always include a 'start' key.
func set_tiles_keys(new_tiles_keys: Array) -> void:
	var new_normalized_tile_keys := _normalize_tiles_keys(new_tiles_keys)
	if tiles_keys == new_normalized_tile_keys:
		return
	
	tiles_keys = new_normalized_tile_keys
	emit_signal("tiles_keys_changed", tiles_keys, tiles_key)


func set_tiles_key(new_tiles_key: String) -> void:
	if tiles_key == new_tiles_key:
		return
	
	tiles_key = new_tiles_key
	emit_signal("tiles_keys_changed", tiles_keys, tiles_key)


func get_tile_map() -> TileMap:
	return $CenterPanel/Playfield.get_tile_map()


func get_pickups() -> EditorPickups:
	return $CenterPanel/Playfield.get_pickups()


func _connect_chunk_control_listeners() -> void:
	if not is_inside_tree():
		return
	for chunk_control in get_tree().get_nodes_in_group("chunk_controls"):
		if chunk_control.has_method("_on_RotateButton_pressed"):
			_rotate_button.connect("pressed", chunk_control, "_on_RotateButton_pressed")
		if chunk_control.has_method("_on_NextButton_pressed"):
			_next_button.connect("pressed", chunk_control, "_on_NextButton_pressed")
		if chunk_control.has_method("_on_PrevButton_pressed"):
			_prev_button.connect("pressed", chunk_control, "_on_PrevButton_pressed")


## Ensure the tiles keys are sorted, and that they always include a 'start' key.
func _normalize_tiles_keys(keys: Array) -> Array:
	var new_keys := keys.duplicate()
	new_keys.sort()
	if "start" in keys:
		new_keys.remove(new_keys.find("start"))
	new_keys.insert(0, "start")
	return new_keys


func _on_Playfield_tile_map_changed() -> void:
	emit_signal("tile_map_changed")


func _on_Playfield_pickups_changed() -> void:
	emit_signal("pickups_changed")


## When the player presses the 'add tiles' button, we append and select a new tiles key.
func _on_PlayfieldNav_add_tiles_key_pressed() -> void:
	var new_key: String
	for potential_new_key in ["0", "1"]:
		if not tiles_keys.has(potential_new_key):
			new_key = potential_new_key
			break
	
	if new_key.empty():
		push_error("Couldn't add tiles key: Too many conflicts")
		return
	
	# append the new tiles key
	tiles_key = new_key
	tiles_keys.append(new_key)
	tiles_keys = _normalize_tiles_keys(tiles_keys)
	emit_signal("tiles_keys_changed", tiles_keys, tiles_key)


## When the player presses the 'remove tiles' button, we remove the current tiles key and select the previous one.
func _on_PlayfieldNav_remove_tiles_key_pressed() -> void:
	var old_tiles_key_index := tiles_keys.find(tiles_key)
	
	if old_tiles_key_index == 0:
		# 'start' should always be the first tiles key
		push_error("Tiles key 'start' can not be removed")
		return
	
	if old_tiles_key_index == -1:
		push_error("Can't remove nonexistent tiles key: %s" % [tiles_key])
		return
	
	tiles_key = tiles_keys[old_tiles_key_index - 1]
	tiles_keys.remove(old_tiles_key_index)
	tiles_keys = _normalize_tiles_keys(tiles_keys)
	emit_signal("tiles_keys_changed", tiles_keys, tiles_key)


## When the player presses the 'next tiles' button, we select the next tiles key.
func _on_PlayfieldNav_next_tiles_key_pressed() -> void:
	var new_tiles_key_index := tiles_keys.find(tiles_key) + 1
	
	if new_tiles_key_index > tiles_keys.size() - 1:
		push_error("Can't navigate to next tiles key (%s > %s)" % [new_tiles_key_index, tiles_keys.size() - 1])
		return
	
	set_tiles_key(tiles_keys[new_tiles_key_index])


## When the player presses the 'previous tiles' button, we select the previous tiles key.
func _on_PlayfieldNav_prev_tiles_key_pressed() -> void:
	var old_tiles_key_index := tiles_keys.find(tiles_key)
	var new_tiles_key_index := old_tiles_key_index - 1 if old_tiles_key_index != -1 else tiles_keys.size()
	
	if new_tiles_key_index < 0:
		push_error("Can't navigate to previous tiles key (%s < 0)" % [new_tiles_key_index])
		return
	
	set_tiles_key(tiles_keys[new_tiles_key_index])
