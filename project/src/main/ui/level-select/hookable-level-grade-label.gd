class_name HookableLevelGradeLabel
extends Node2D
## Shows a grade label for a specific level.
##
## This can be something like 'S' or 'B+' if a level has been cleared, or something like a lock/key icon for levels
## which haven't yet been cleared.

const CLEARED_TEXTURE: Texture = preload("res://assets/main/ui/level-select/cleared.png")
const CROWN_TEXTURE: Texture = preload("res://assets/main/ui/level-select/crown.png")
const KEY_TEXTURE: Texture = preload("res://assets/main/ui/level-select/key.png")
const LOCKED_TEXTURE: Texture = preload("res://assets/main/ui/level-select/locked.png")

## LevelSelectButton this grade label applies to
var button: Control setget set_button

onready var _grade_label: GradeLabel = $GradeLabel
onready var _status_icon := $StatusIcon

## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_grade_label = $GradeLabel
	_status_icon = $StatusIcon


func _process(_delta: float) -> void:
	modulate.a = button.modulate.a
	visible = button.visible


## Assigns this label's button, and updates the label's appearance.
func set_button(new_button: LevelSelectButton) -> void:
	if button == new_button:
		# skip the unnecessary overhead in hooking/unhooking signals and refreshing our appearance
		return
	
	if button:
		button.get_node("GradeHook").remote_path = null
		button.disconnect("tree_exited", self, "_on_LevelSelectButton_tree_exited")
	
	button = new_button
	
	button.get_node("GradeHook").remote_path = button.get_node("GradeHook").get_path_to(self)
	button.connect("tree_exited", self, "_on_LevelSelectButton_tree_exited")
	
	_refresh_appearance()


## Updates the text/icon based on the level's status.
##
## If the level has been cleared, we display text corresponding to the player's grade. If the level hasn't been
## cleared, we show a lock/key/crown icon corresponding to the level's lock status.
func _refresh_appearance() -> void:
	if not PlayerData.level_history.is_level_finished(button.level_id):
		# uncleared levels do not show a grade
		_refresh_status_icon(button.lock_status)
	elif button.lock_status in [LevelSelectButton.STATUS_CLEARED, LevelSelectButton.STATUS_CROWN]:
		# some levels do not show a grade; only a check mark/crown for completion
		_refresh_status_icon(button.lock_status)
	else:
		# cleared levels show a grade
		_refresh_grade_text(PlayerData.level_history.best_overall_rank(button.level_id))


## Updates the icon based on the level's status.
##
## We show a lock/key/crown icon corresponding to the level's lock status.
func _refresh_status_icon(lock_status: int) -> void:
	_grade_label.visible = false
	_status_icon.visible = true
	
	var icon_color := GradeLabel.GRADE_COLOR_GREEN
	var outline_color := Color("b39a8f") # light brown tint. the outline is also colored by the modulate property
	match lock_status:
		LevelSelectButton.STATUS_NONE:
			_status_icon.texture = null
			icon_color = Color.white
		LevelSelectButton.STATUS_CLEARED:
			_status_icon.texture = CLEARED_TEXTURE
			icon_color = GradeLabel.GRADE_COLOR_GREEN
		LevelSelectButton.STATUS_CROWN:
			_status_icon.texture = CROWN_TEXTURE
			icon_color = GradeLabel.GRADE_COLOR_YELLOW
		LevelSelectButton.STATUS_KEY:
			_status_icon.texture = KEY_TEXTURE
			icon_color = GradeLabel.GRADE_COLOR_GREEN
		LevelSelectButton.STATUS_LOCKED:
			_status_icon.texture = LOCKED_TEXTURE
			icon_color = GradeLabel.GRADE_COLOR_GREY
		_:
			push_warning("Unexpected lock status: %s" % [lock_status])
	
	_status_icon.modulate = icon_color
	_status_icon.material.set("shader_param/black", outline_color)


## Updates the text based on the player's grade on a level.
func _refresh_grade_text(rank: float) -> void:
	_status_icon.visible = false
	
	_grade_label.text = RankCalculator.grade(rank)
	_grade_label.visible = false if _grade_label.text == "-" else true
	_grade_label.refresh_color_from_text()


func _on_LevelSelectButton_tree_exited() -> void:
	queue_free()
