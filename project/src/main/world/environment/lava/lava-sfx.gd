extends Node
## Plays sound effects for Chocolava Canyon's cutscenes.

onready var _cheer_1 := $Cheer1
onready var _cheer_2 := $Cheer2

func _ready() -> void:
	if Global.get_overworld_ui():
		Global.get_overworld_ui().connect("chat_event_meta_played", self, "_on_OverworldUi_chat_event_meta_played")


## Listen for 'play_sfx' chat events and play sound effects
func _on_OverworldUi_chat_event_meta_played(meta_item: String) -> void:
	match meta_item:
		"play_sfx lava_cheer_1":
			_cheer_1.play()
		"play_sfx lava_cheer_2":
			_cheer_2.play()
