class_name PlayfieldNav
extends VBoxContainer
"""
UI control for adding, removing and selecting different groups of level tiles.
"""

# emitted when the 'prev tiles key' button is pressed
signal prev_tiles_key_pressed

# emitted when the 'next tiles key' button is pressed
signal next_tiles_key_pressed

# emitted when the 'remove tiles key' button is pressed
signal remove_tiles_key_pressed

# emitted when the 'add tiles key' button is pressed
signal add_tiles_key_pressed

onready var next_button := $NextPrev/Next
onready var prev_button := $NextPrev/Prev
onready var add_button := $AddRemove/Add
onready var remove_button := $AddRemove/Remove
onready var tiles_name_label := $TilesName

func _ready() -> void:
	_refresh_buttons(["start"], "start")


"""
Enables/disables the buttons based on the available groups of tiles.
"""
func _refresh_buttons(tiles_keys: Array, current_tiles_key: String) -> void:
	# add button: enabled if there are fewer than 3 tiles keys
	add_button.disabled = tiles_keys.size() >= 3
	
	# remove button: enabled if we've selected a tiles key other than 'start'
	remove_button.disabled = tiles_keys.find(current_tiles_key) <= 0
	
	# next button: enabled if the current tiles key is not the same as the last tiles key
	next_button.disabled = not tiles_keys or current_tiles_key == tiles_keys.back()
	
	# prev button: enabled if the current tiles key is not the same as the first tiles key
	prev_button.disabled = not tiles_keys or current_tiles_key == tiles_keys.front()
	
	tiles_name_label.text = current_tiles_key


func _on_Prev_Button_pressed() -> void:
	emit_signal("prev_tiles_key_pressed")


func _on_Next_Button_pressed() -> void:
	emit_signal("next_tiles_key_pressed")


func _on_Remove_Button_pressed() -> void:
	emit_signal("remove_tiles_key_pressed")


func _on_Add_Button_pressed() -> void:
	emit_signal("add_tiles_key_pressed")


func _on_Playfield_tiles_keys_changed(tiles_keys: Array, tiles_key: String) -> void:
	_refresh_buttons(tiles_keys, tiles_key)
