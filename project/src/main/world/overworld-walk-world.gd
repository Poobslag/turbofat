extends Node
"""
Prepares the the overworld walking scene.
"""

onready var _overworld_ui: OverworldUi = Global.get_overworld_ui()

func _ready() -> void:
	if not MusicPlayer.is_playing_tutorial_bgm() and not MusicTransition.is_fading_in_bgm():
		MusicPlayer.play_tutorial_bgm()
	
	$Camera.position = ChattableManager.player.position
	ChattableManager.refresh_creatures()
	
	if CutsceneManager.is_front_chat_tree():
		_launch_cutscene()


func _launch_cutscene() -> void:
	_overworld_ui.cutscene = true
	
	# get the location, spawn location data
	var chat_tree := CutsceneManager.pop_chat_tree()
	yield(get_tree(), "idle_frame")
	_overworld_ui.start_chat(chat_tree, null)
