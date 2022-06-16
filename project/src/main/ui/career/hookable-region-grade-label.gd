class_name HookableRegionGradeLabel
extends Node2D
## Shows a grade label for a specific region.
##
## If a region has been cleared, we show something like 'S' or 'B+'. If it hasn't been cleared we show nothing.

## the region button this grade label applies to
var button: RegionSelectButton setget set_button

onready var _grade_label := $GradeLabel

## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_grade_label = $GradeLabel


## Assigns this label's button, and updates the label's appearance.
func set_button(new_button: RegionSelectButton) -> void:
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


## Updates the text/icon based on the region's status.
##
## If the region has been completed we show something like 'S' or 'B+'. If it hasn't been cleared we show nothing.
func _refresh_appearance() -> void:
	if button.completion_percent == 1.0:
		# region has been cleared; show text
		_grade_label.visible = true
		var worst_rank := 0.0
		for rank in button.ranks:
			worst_rank = max(worst_rank, rank)
		_refresh_grade_text(worst_rank)
	else:
		# region has not been cleared; show nothing
		_grade_label.visible = false


## Updates the text based on the player's grade on a level.
func _refresh_grade_text(rank: float) -> void:
	_grade_label.visible = true
	
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


func _on_LevelSelectButton_tree_exited() -> void:
	queue_free()
