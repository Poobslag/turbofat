extends Node
## Shows the player's current progress through career mode.
##
## This includes how many levels they've played, how much money they've earned, and how far they've travelled.

## key: (int) corresonding to the number of levels the player has played
## value: (String) human-readable time of day
var TEXT_BY_HOURS := {
	0: "8:00 am",
	1: "9:10 am",
	2: "10:15 am",
	3: "11:20 am",
	4: "12:30 pm",
	5: "1:40 pm",
	6: "2:45 pm",
	7: "3:50 pm",
	8: "5:00 pm",
}

onready var _button := $Button
onready var _label := $Label
onready var _history := $History

func _ready() -> void:
	# prepare the label text
	_label.text = ""
	_label.text += "Distance: %s\n\n" % [PlayerData.career.distance_travelled]
	_label.text += "Earnings: %s\n\n" % [StringUtils.format_money(PlayerData.career.daily_earnings)]
	_label.text += "Current Time: %s" % [TEXT_BY_HOURS.get(PlayerData.career.hours_passed, "?:?? zm")]
	if not TEXT_BY_HOURS.has(PlayerData.career.hours_passed):
		push_warning("TEXT_BY_HOURS has no entry for %s" % [PlayerData.career.hours_passed])
	
	# prepare the history text
	_history.bbcode_text = "[center]"
	for daily_earnings in PlayerData.career.prev_daily_earnings:
		if _history.bbcode_text:
			_history.bbcode_text += "\n"
		_history.bbcode_text += StringUtils.format_money(daily_earnings)
	_history.bbcode_text += "[/center]"
	
	_button.grab_focus()


func _on_Button_pressed() -> void:
	# select a level id to play
	var level_ids := []
	var all_level_ids := LevelLibrary.all_level_ids()
	for level_id_obj in all_level_ids:
		var level_id: String = level_id_obj
		if level_id.begins_with("tutorial/"):
			continue
		level_ids.append(level_id)
	
	# launch the selected level
	CurrentLevel.set_launched_level(Utils.rand_value(level_ids))
	PlayerData.career.push_career_trail()
