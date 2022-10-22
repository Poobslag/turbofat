extends Control
## Shows the time in the career mode status bar.
##
## This includes a text label like '8:00 am' and a clock icon which changes.

onready var _label := $Label
onready var _icon_sprite := $Icon/IconSprite

func _ready() -> void:
	PlayerData.career.connect("hours_passed_changed", self, "_on_CareerData_hours_passed_changed")
	_refresh()


## Update the label's text and icon.
func _refresh() -> void:
	# update the label's text
	_label.text = PlayerData.career.time_of_day_by_hours.get(
			PlayerData.career.hours_passed, PlayerData.career.invalid_time_of_day)
	
	if not PlayerData.career.time_of_day_by_hours.has(PlayerData.career.hours_passed):
		push_warning("_time_of_day_by_hours has no entry for %s" % [PlayerData.career.hours_passed])
	
	# update the icon
	_icon_sprite.frame = PlayerData.career.hours_passed


func _on_CareerData_hours_passed_changed() -> void:
	_refresh()
