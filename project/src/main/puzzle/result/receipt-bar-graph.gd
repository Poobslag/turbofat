extends Control
## Draws the bar graph for the results hud.
##
## The bar graph includes a stacked set of BarGraphBars for the bars themselves, a set of BarGraphGoals which show
## dashed lines with time goals or score goals, and labels.

## The y coordinate where the stacked BarGraphBars starts
const GRAPH_START_Y := 431

## The width of the bar graph bars
const BAR_WIDTH := 85

## The desired y coordinate for the top of the stacked BarGraphBars
const CAMERA_TARGET_Y := 100

export (NodePath) var receipt_table_path: NodePath

var _tween: SceneTreeTween
var _blueprint: ResultsHudBlueprint

## The unscaled height of the individual BarGraphBars.
var _box_bar_height := 0.0
var _combo_bar_height := 0.0
var _extra_bar_height := 0.0

## The height scale to apply when sizing the BarGraphBars and positioning the BarGraphGoals.
var _height_scale := 1.0

## The table for the results hud. The label for the bar graph synchronizes with the label from the table.
onready var receipt_table: ReceiptTable = get_node(receipt_table_path)

onready var _sfx := $Sfx

## The contents; these shift up and down if the bar graph grows too tall
onready var _contents := $Contents

## Stacked BarGraphBars
onready var _box_bar := $Contents/BoxBar
onready var _combo_bar := $Contents/ComboBar
onready var _extra_bar := $Contents/OtherBar

## Label at the top of the stacked BarGraphBars
onready var _total_label := $Contents/TotalLabel

## BarGraphGoals which show dashed lines with time goals or score goals
onready var _success_goal := $Contents/SuccessGoal
onready var _sss_goal := $Contents/SssGoal
onready var _ss_goal := $Contents/SsGoal
onready var _s_goal := $Contents/SGoal
onready var _a_goal := $Contents/AGoal
onready var _b_goal := $Contents/BGoal

func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	_refresh_bars()
	
	# slide the bar graph down if it grows too tall
	if _contents.rect_position.y + _total_label.rect_position.y < CAMERA_TARGET_Y:
		_contents.rect_position.y = lerp(_contents.rect_position.y, \
				CAMERA_TARGET_Y - _total_label.rect_position.y, _delta * 5)


## Resets the graph to be empty, with a set of BarGraphGoals based on the current level.
func reset(new_blueprint: ResultsHudBlueprint) -> void:
	_blueprint = new_blueprint
	_tween = Utils.kill_tween(_tween)
	_contents.rect_position.y = 0
	_box_bar_height = 0
	_combo_bar_height = 0
	_extra_bar_height = 0
	_sfx.reset()
	
	_refresh_height_scale()
	_refresh_goals()
	_refresh_bars()


## Plays an animation increasing size of each of the BarGraphBars.
func play(new_blueprint: ResultsHudBlueprint) -> void:
	_blueprint = new_blueprint
	reset(new_blueprint)
	_schedule_bar_stack_growth()


## Updates the '_height_scale' field based on how tall the BarGraphBars will grow.
##
## For levels where the player performs well, or is expected to perform well, the height scale is very low. For levels
## with a low scoring requirement, the heigh scale is 1.0.
func _refresh_height_scale() -> void:
	_height_scale = 1.0
	
	# The goal of 'S-' corresponds to "being good at a level". For players who do not achieve this rank, the graph is
	# scaled to put the goal of 'S-' at the top. For players who exceed this rank, the graph is squashed towards the S
	# rank so that it doesn't get too absurdly tall.
	var uncompressed_height := _blueprint.goal_height_s()
	uncompressed_height = max(uncompressed_height,
			lerp(_blueprint.box_height() + _blueprint.combo_height() + _blueprint.extra_height(),
			_blueprint.goal_height_s(),
			0.33))
	
	if uncompressed_height > 420:
		_height_scale = max(0.10, 420.0 / uncompressed_height)


## Updates the goal positions and labels.
func _refresh_goals() -> void:
	var bar_top_y := GRAPH_START_Y - _blueprint.total_height() * _height_scale
	var lowest_unreached_goal: BarGraphGoal
	
	# hide all goals
	for goal_node in [_success_goal, _sss_goal, _ss_goal, _s_goal, _a_goal, _b_goal]:
		goal_node.visible = false
	
	# calculate the list of goals to show
	var goal_metadatas := []
	if _blueprint.show_success_goal:
		goal_metadatas.append([_success_goal, _blueprint.goal_height_success(), _blueprint.goal_success, tr("GOAL")])
	if _blueprint.show_rank_goals:
		goal_metadatas.append([_sss_goal, _blueprint.goal_height_sss(), _blueprint.goal_sss, "SSS"])
		goal_metadatas.append([_ss_goal, _blueprint.goal_height_ss(), _blueprint.goal_ss, "SS"])
		goal_metadatas.append([_s_goal, _blueprint.goal_height_s(), _blueprint.goal_s, "S"])
		goal_metadatas.append([_a_goal, _blueprint.goal_height_a(), _blueprint.goal_a, "A"])
		goal_metadatas.append([_b_goal, _blueprint.goal_height_b(), _blueprint.goal_b, "B"])
	
	# show and update some goalsj
	for goal_metadata in goal_metadatas:
		var goal_node: Node = goal_metadata[0]
		var goal_height: float = goal_metadata[1]
		var goal_value: int = goal_metadata[2]
		var goal_grade: String = goal_metadata[3]
		
		goal_node.visible = true
		
		# update the goal label
		var goal_value_string := ""
		if _blueprint.rank_result.compare == "-seconds":
			goal_value_string = StringUtils.format_duration(goal_value)
		else:
			goal_value_string = StringUtils.format_money(goal_value)
		
		# update the goal position
		var goal_node_y := GRAPH_START_Y - goal_height * _height_scale
		goal_node.rect_position = Vector2(0, goal_node_y - 10)
		goal_node.text = "%s  %s" % [goal_value_string, goal_grade]
		
		# calculate the 'lowest_unreached_goal' field
		if goal_node_y < bar_top_y:
			lowest_unreached_goal = goal_node
	
	# If there is a goal the player hasn't reached, we reposition it. This avoids a scenario where the player gets
	# an S rank, but can't see the requirement for an SS.
	if lowest_unreached_goal \
			and lowest_unreached_goal.rect_position.y + 10 < 0 \
			and lowest_unreached_goal.rect_position.y + 10 < bar_top_y - CAMERA_TARGET_Y:
		lowest_unreached_goal.rect_position.y = bar_top_y - CAMERA_TARGET_Y - 20
	
	# If the goals are too close to each other, we turn them invisible. This avoids a case where the "A" and "B"
	# goals are squashed so close at the bottom that you can't read either one.
	for front_goal_index in range(goal_metadatas.size()):
		for back_goal_index in range(front_goal_index + 1, goal_metadatas.size()):
			var back_goal: BarGraphGoal = goal_metadatas[back_goal_index][0]
			var front_goal: BarGraphGoal = goal_metadatas[front_goal_index][0]
			hide_behind(back_goal, front_goal)


func hide_behind(back_goal: BarGraphGoal, front_goal: BarGraphGoal) -> void:
	if back_goal.visible and front_goal.visible \
			and abs(back_goal.rect_position.y - front_goal.rect_position.y) <= 12:
		back_goal.visible = false


## Schedules events to increase the size of each BarGraphBar.
func _schedule_bar_stack_growth() -> void:
	# if the 'duration' fields are zero because a level did not have a category or the player scored no points, we
	# skip the corresponding animation and assign the height field directly.
	if not _blueprint.box_duration():
		_box_bar_height = _blueprint.box_height()
	if not _blueprint.combo_duration():
		_combo_bar_height = _blueprint.combo_height()
	if not _blueprint.extra_duration():
		_extra_bar_height = _blueprint.extra_height()
	
	# if any 'duration' fields are non-zero, we schedule the animation
	if _blueprint.box_duration() or _blueprint.combo_duration() or _blueprint.extra_duration():
		# start processing, so that the bar heights will adjust and the 'camera' will move
		set_process(true)
		_tween = Utils.recreate_tween(self, _tween)
		
		# schedule growth of the the 'box' bar
		if _blueprint.box_duration():
			_tween.tween_property(self, "_box_bar_height", _blueprint.box_height(), _blueprint.box_duration())
			_schedule_bar_sound(_blueprint.box_duration(), \
					0.0, _blueprint.box_height())
			_tween.tween_interval(ResultsHudBlueprint.PAUSE_DURATION)
		
		# schedule growth of the the 'combo' bar
		if _blueprint.combo_duration():
			_tween.tween_property( \
					self, "_combo_bar_height", _blueprint.combo_height(), _blueprint.combo_duration())
			_schedule_bar_sound(_blueprint.combo_duration(), \
					_blueprint.box_height(), _blueprint.box_height() + _blueprint.combo_height())
			_tween.tween_interval(ResultsHudBlueprint.PAUSE_DURATION)
		
		# schedule growth of the the 'extra' bar
		if _blueprint.extra_duration():
			_tween.tween_property(self, "_extra_bar_height", _blueprint.extra_height(), _blueprint.extra_duration())
			_schedule_bar_sound(_blueprint.extra_duration(), \
					_blueprint.box_height() + _blueprint.combo_height(), _blueprint.total_height())
			_tween.tween_interval(ResultsHudBlueprint.PAUSE_DURATION)
		
		# stop processing, so that the 'camera' will stop moving
		_tween.tween_callback(self, "set_process", [false]).set_delay(2.0)


## Schedules the sound effect for the stacked bar growing from one height to another height.
##
## Parameters:
## 	'duration': The duration of the bar sound effect.
##
## 	'start_height': The height of the stacked bar at the start of the sound effect.
##
## 	'end_height': The height of the stacked bar at the end of the sound effect.
func _schedule_bar_sound(duration: float, start_height: float, end_height: float) -> void:
	var start_pitch: float = _bar_pitch(start_height)
	var end_pitch: float = _bar_pitch(end_height)
	_tween.parallel().tween_callback(_sfx, "play_bar_sound", [duration, start_pitch, end_pitch])


## Calculates the sound effect pitch to play when the bar reaches the specified height
##
## Paremeters:
## 	'bar_y': The height of the stacked bar at the time the sound effect plays.
func _bar_pitch(bar_y: float) -> float:
	var pitch_min := 0.8
	var pitch_max := 0.8 + _blueprint.total_height() * _height_scale / 400
	return lerp(pitch_min, pitch_max, bar_y / max(1.0, _blueprint.total_height()))


## Recalculate and reposition the BarGraphBars and bar graph label.
func _refresh_bars() -> void:
	# set box bar height and size
	_box_bar.rect_size = Vector2(BAR_WIDTH, _box_bar_height * _height_scale)
	_box_bar.rect_position = Vector2(0, GRAPH_START_Y - _box_bar.rect_size.y)
	
	# set combo bar height and size
	_combo_bar.rect_size = Vector2(BAR_WIDTH, _combo_bar_height * _height_scale)
	_combo_bar.rect_position = _box_bar.rect_position - Vector2(0, _combo_bar.rect_size.y)
	
	# set other bar height and size
	_extra_bar.rect_size = Vector2(BAR_WIDTH, _extra_bar_height * _height_scale)
	_extra_bar.rect_position = _combo_bar.rect_position - Vector2(0, _extra_bar.rect_size.y)
	
	# position total label, set text
	_total_label.rect_position = _extra_bar.rect_position - Vector2(0, _total_label.rect_size.y)
	
	if _blueprint and _blueprint.rank_result.compare == "-seconds":
		_total_label.text = StringUtils.format_duration(_blueprint.rank_result.seconds)
	else:
		_total_label.text = StringUtils.format_money(receipt_table.get_shown_total())
