extends ImageButton
"""
Button which enables/disables cutscenes.
"""

enum CutsceneButtonState {
	IMPLICIT_PLAY, # this cutscene is implicitly played; the player has no preference
	IMPLICIT_SKIP, # this cutscene is implicitly skipped; the player has no preference
	FORCE_PLAY, # the player wants to play cutscenes
	FORCE_SKIP, # the player wants to skip cutscenes
}

const IMPLICIT_PLAY := CutsceneButtonState.IMPLICIT_PLAY
const IMPLICIT_SKIP := CutsceneButtonState.IMPLICIT_SKIP
const FORCE_PLAY := CutsceneButtonState.FORCE_PLAY
const FORCE_SKIP := CutsceneButtonState.FORCE_SKIP

export (NodePath) var level_buttons_path: NodePath

var _no_texture: Texture = preload("res://assets/main/ui/level-select/cutscene-no.png")
var _no_pressed_texture: Texture = preload("res://assets/main/ui/level-select/cutscene-no-pressed.png")
var _yes_texture: Texture = preload("res://assets/main/ui/level-select/cutscene-yes.png")
var _yes_pressed_texture: Texture = preload("res://assets/main/ui/level-select/cutscene-yes-pressed.png")

# tracks whether the player wants to play or skip all cutscenes
var _cutscene_force := IMPLICIT_PLAY setget set_cutscene_force

# tracks whether the current level's cutscenes will be implicitly skipped if the player has no preference
var _cutscene_implicit_force := IMPLICIT_PLAY

onready var _level_buttons: LevelButtons = get_node(level_buttons_path)

func _ready() -> void:
	connect("pressed", self, "_on_pressed")
	_level_buttons.connect("unlocked_level_selected", self, "_on_LevelButtons_unlocked_level_selected")
	match PlayerData.miscellaneous_settings.cutscene_force:
		CurrentLevel.CutsceneForce.NONE: _cutscene_force = IMPLICIT_PLAY
		CurrentLevel.CutsceneForce.PLAY: _cutscene_force = FORCE_PLAY
		CurrentLevel.CutsceneForce.SKIP: _cutscene_force = FORCE_SKIP
	_refresh_cutscene_force()


func set_cutscene_force(new_cutscene_force: int) -> void:
	if _cutscene_force == new_cutscene_force:
		return
	
	_cutscene_force = new_cutscene_force
	_refresh_cutscene_force()


"""
Refresh the button's appearance and update the global 'cutscene_force' setting.
"""
func _refresh_cutscene_force() -> void:
	# update the button's icon
	match _cutscene_force:
		IMPLICIT_PLAY, FORCE_PLAY:
			set_normal_icon(_yes_texture)
			set_pressed_icon(_yes_pressed_texture)
		IMPLICIT_SKIP, FORCE_SKIP:
			set_normal_icon(_no_texture)
			set_pressed_icon(_no_pressed_texture)
	
	# update the button's color
	match _cutscene_force:
		IMPLICIT_PLAY, IMPLICIT_SKIP:
			self_modulate = Color("60ffffff")
		FORCE_PLAY, FORCE_SKIP:
			self_modulate = Color("ffffffff")
	
	# update the global cutscene_force setting
	match _cutscene_force:
		IMPLICIT_PLAY, IMPLICIT_SKIP:
			PlayerData.miscellaneous_settings.cutscene_force = CurrentLevel.CutsceneForce.NONE
		FORCE_PLAY:
			PlayerData.miscellaneous_settings.cutscene_force = CurrentLevel.CutsceneForce.PLAY
		FORCE_SKIP:
			PlayerData.miscellaneous_settings.cutscene_force = CurrentLevel.CutsceneForce.SKIP


"""
Returns 'true' if the specified level's preroll cutscene should be played.
"""
func _will_play_preroll(settings: LevelSettings) -> bool:
	if not ChatLibrary.has_preroll(settings.id):
		return false
	
	return ChatLibrary.should_play_cutscene(ChatLibrary.chat_tree_for_preroll(settings.id))


"""
Returns 'true' if the specified level's postroll cutscene should be played.
"""
func _will_play_postroll(settings: LevelSettings) -> bool:
	if not ChatLibrary.has_postroll(settings.id):
		return false
	
	return ChatLibrary.should_play_cutscene(ChatLibrary.chat_tree_for_postroll(settings.id))


func _on_pressed() -> void:
	match _cutscene_force:
		IMPLICIT_PLAY, IMPLICIT_SKIP: set_cutscene_force(FORCE_SKIP)
		FORCE_PLAY: set_cutscene_force(_cutscene_implicit_force)
		FORCE_SKIP: set_cutscene_force(FORCE_PLAY)


"""
When the player selects a new level, we sometimes update the cutscene button's appearance.
"""
func _on_LevelButtons_unlocked_level_selected(_level_lock: LevelLock, settings: LevelSettings) -> void:
	# update the implicit state based on the selected level
	_cutscene_implicit_force = IMPLICIT_SKIP
	if _will_play_preroll(settings):
		_cutscene_implicit_force = IMPLICIT_PLAY
	if _will_play_postroll(settings):
		_cutscene_implicit_force = IMPLICIT_PLAY
	
	# if the button is in an implicit state, update the button's appearance
	if _cutscene_force in [IMPLICIT_PLAY, IMPLICIT_SKIP]:
		set_cutscene_force(_cutscene_implicit_force)
