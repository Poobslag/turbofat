class_name ReceiptTable
extends TextureRect
## Draws the table for the results hud.
##
## The table shows statistics about how much money the player earned from boxes, combos, and extra stuff.

## Numeric values currently shown in the table. These rapidly change while the table animates.
var _boxes_label_value := 0
var _combos_label_value := 0
var _extra_label_value := 0

var _tween: SceneTreeTween

var _blueprint: ResultsHudBlueprint

onready var _boxes_label := $BoxesLabel
onready var _combos_label := $CombosLabel
onready var _extra_label := $ExtraLabel

onready var _label_refresh_timer := $LabelRefreshTimer

## Plays an animation building up the values in the table.
func play(new_blueprint: ResultsHudBlueprint) -> void:
	_blueprint = new_blueprint
	reset(new_blueprint)
	_schedule_table_growth()


## Resets the table to be empty (all zeroes).
func reset(new_blueprint: ResultsHudBlueprint) -> void:
	_blueprint = new_blueprint
	_tween = Utils.kill_tween(_tween)
	_label_refresh_timer.stop()
	_boxes_label_value = 0
	_combos_label_value = 0
	_extra_label_value = 0
	
	_refresh_labels()


## Returns the sum of values currently shown in the table.
##
## This value rapidly changes while the table animates.
func get_shown_total() -> int:
	return _boxes_label_value + _combos_label_value + _extra_label_value


## Schedules events to increase the value of each table entry.
func _schedule_table_growth() -> void:
	_label_refresh_timer.start()
	
	if not _blueprint.box_duration():
		_boxes_label_value = _blueprint.box_score()
	
	if not _blueprint.combo_duration():
		_combos_label_value = _blueprint.combo_score()
	
	if not _blueprint.extra_duration():
		_extra_label_value = _blueprint.extra_score()
	
	if _blueprint.box_duration() or _blueprint.combo_duration() or _blueprint.extra_duration():
		_tween = Utils.recreate_tween(self, _tween)
		if _blueprint.box_duration():
			_tween.tween_property(self, "_boxes_label_value", _blueprint.box_score(), _blueprint.box_duration())
			_tween.tween_interval(ResultsHudBlueprint.PAUSE_DURATION)
		
		if _blueprint.combo_duration():
			_tween.tween_property(self, "_combos_label_value", _blueprint.combo_score(), _blueprint.combo_duration())
			_tween.tween_interval(ResultsHudBlueprint.PAUSE_DURATION)
		
		if _blueprint.extra_duration():
			_tween.tween_property(self, "_extra_label_value", _blueprint.extra_score(), _blueprint.extra_duration())
			_tween.tween_interval(ResultsHudBlueprint.PAUSE_DURATION)
		
		_tween.tween_callback(_label_refresh_timer, "stop")


## Updates the contents of the table labels.
func _refresh_labels() -> void:
	_boxes_label.text = tr("Boxes\n¥%s") % [StringUtils.comma_sep(_boxes_label_value)]
	_combos_label.text = tr("Combos\n¥%s") % [StringUtils.comma_sep(_combos_label_value)]
	_extra_label.text = tr("Extra\n¥%s") % [StringUtils.comma_sep(_extra_label_value)]


func _on_LabelRefreshTimer_timeout() -> void:
	_refresh_labels()
