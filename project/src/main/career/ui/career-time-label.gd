extends Control
## Shows the time in the career mode status bar.
##
## This includes a text label like '8:00 am' and a clock icon which changes.

## time to show when the number of levels the player has played is an unexpected value
var _invalid_time_of_day := tr("?:?? zm")

## key: (int) corresonding to the number of levels the player has played
## value: (String) human-readable time of day
var _time_of_day_by_hours := {
	0: tr("8:00 am"),
	1: tr("9:10 am"),
	2: tr("10:15 am"),
	3: tr("11:20 am"),
	4: tr("12:30 pm"),
	5: tr("1:40 pm"),
	6: tr("2:45 pm"),
	7: tr("3:50 pm"),
	8: tr("5:00 pm"),
}

onready var _label := $Label
onready var _icon_sprite := $Icon/IconSprite

func _ready() -> void:
	PlayerData.career.connect("hours_passed_changed", self, "_on_CareerData_hours_passed_changed")
	_refresh()


## Update the label's text and icon.
func _refresh() -> void:
	# update the label's text
	_label.text = _time_of_day_by_hours.get(PlayerData.career.hours_passed, _invalid_time_of_day)
	if not _time_of_day_by_hours.has(PlayerData.career.hours_passed):
		push_warning("_time_of_day_by_hours has no entry for %s" % [PlayerData.career.hours_passed])
	
	# update the icon
	_icon_sprite.frame = PlayerData.career.hours_passed


func _on_CareerData_hours_passed_changed() -> void:
	_refresh()
