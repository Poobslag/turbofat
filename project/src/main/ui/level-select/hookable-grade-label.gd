class_name HookableGradeLabel
extends Node2D
## Shows a grade label for a specific level.
##
## This can be something like 'S' or 'B+' if a level has been cleared, or something like a lock/key icon for levels
## which haven't yet been cleared.

## the level button this grade label applies to
var button: LevelSelectButton setget set_button

var _cleared_texture: Texture = preload("res://assets/main/ui/level-select/cleared.png")
var _crown_texture: Texture = preload("res://assets/main/ui/level-select/crown.png")
var _key_texture: Texture = preload("res://assets/main/ui/level-select/key.png")
var _locked_texture: Texture = preload("res://assets/main/ui/level-select/locked.png")

onready var _grade_label := $GradeLabel
onready var _status_icon := $StatusIcon

## Preemptively initialize onready variables to avoid null references.
func _enter_tree() -> void:
	_grade_label = $GradeLabel
	_status_icon = $StatusIcon


## Assigns this label's button, and updates the label's appearance.
func set_button(new_button: LevelSelectButton) -> void:
	if button == new_button:
		# skip the unnecessary overhead in hooking/unhooking signals and refreshing our appearance
		return
	
	if button:
		button.get_node("GradeHook").remote_path = null
		button.disconnect("lowlight_changed", self, "_on_LevelSelectButton_lowlight_changed")
		button.disconnect("tree_exited", self, "_on_LevelSelectButton_tree_exited")
	
	button = new_button
	
	button.get_node("GradeHook").remote_path = button.get_node("GradeHook").get_path_to(self)
	button.connect("lowlight_changed", self, "_on_LevelSelectButton_lowlight_changed")
	button.connect("tree_exited", self, "_on_LevelSelectButton_tree_exited")
	
	_refresh_appearance()


## Updates the text/icon based on the level's status.
##
## If the level has been cleared, we display text corresponding to the player's grade. If the level hasn't been
## cleared, we show a lock/key/crown icon corresponding to the level's lock status.
func _refresh_appearance() -> void:
	if button.is_class("WorldSelectButton"):
		var world_button: WorldSelectButton = button
		var worst_rank := 0.0
		for rank in world_button.ranks:
			worst_rank = max(worst_rank, rank)
		if world_button.world_id == LevelLibrary.TUTORIAL_WORLD_ID:
			# tutorial world does not show a grade; only a check mark
			_refresh_status_icon(world_button.lock_status)
		else:
			# worlds show a grade
			_refresh_grade_text(worst_rank)
	else:
		var result := PlayerData.level_history.best_result(button.level_id)
		if not result:
			# uncleared levels do not show a grade
			_refresh_status_icon(button.lock_status)
		elif button.lock_status == LevelLock.STATUS_CLEARED:
			# tutorial levels do not show a grade; only a check mark
			_refresh_status_icon(button.lock_status)
		else:
			# cleared levels show a grade
			_refresh_grade_text(result.seconds_rank if result.compare == "-seconds" else result.score_rank)
	
	visible = false if button.lowlight else true


## Updates the icon based on the level's status.
##
## We show a lock/key/crown icon corresponding to the level's lock status.
func _refresh_status_icon(lock_status: int) -> void:
	_grade_label.visible = false
	_status_icon.visible = true
	
	var outline_color: Color = Color("b39a8f")
	match lock_status:
		LevelLock.STATUS_NONE:
			_status_icon.texture = null
			_status_icon.modulate = Color.white
		LevelLock.STATUS_CLEARED:
			_status_icon.texture = _cleared_texture
			_status_icon.modulate = Color("36d936")
		LevelLock.STATUS_CROWN:
			_status_icon.texture = _crown_texture
			_status_icon.modulate = Color("36d936")
		LevelLock.STATUS_KEY:
			_status_icon.texture = _key_texture
			_status_icon.modulate = Color("36d936")
		LevelLock.STATUS_SOFT_LOCK:
			_status_icon.texture = _locked_texture
			_status_icon.modulate = Color("666666")
			outline_color = Color("808080")
		_:
			push_warning("Unexpected lock status: %s" % [lock_status])
	_status_icon.material.set("shader_param/black", outline_color)


## Updates the text based on the player's grade on a level.
func _refresh_grade_text(rank: float) -> void:
	_grade_label.visible = true
	_status_icon.visible = false
	
	_grade_label.text = RankCalculator.grade(rank)
	var font: DynamicFont = _grade_label.get("custom_fonts/font")
	var font_color := Color("4eff49")
	var outline_darkness := 0.2
	match _grade_label.text:
		"M":
			font_color.h = 0.1250 # near-white
			font_color.s = 0.0600
			outline_darkness = 0.1
		"SSS":
			font_color.h = 0.1250 # bright yellow
			font_color.s = 0.4444
			outline_darkness = 0.15
		"SS+", "SS": font_color.h = 0.1250 # yellow
		"S+", "S", "S-": font_color.h = 0.2861 # green
		"AA+", "AA": font_color.h = 0.4667 # cyan
		"A+", "A", "A-": font_color.h = 0.5889 # blue
		"B+", "B", "B-": font_color.h = 0.7472 # purple
		"-": _grade_label.visible = false
	_grade_label.set("custom_colors/font_color", font_color)
	font.outline_color = font_color
	font.outline_color.s += outline_darkness
	font.outline_color.v -= outline_darkness * 2


func _on_LevelSelectButton_lowlight_changed() -> void:
	visible = false if button.lowlight else true


func _on_LevelSelectButton_tree_exited() -> void:
	queue_free()
