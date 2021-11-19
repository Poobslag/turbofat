extends Node

## The number of levels the player can choose between
const SELECTION_COUNT := 3

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
	var distance_just_travelled := PlayerData.career.distance_earned
	PlayerData.career.distance_travelled = min(
		PlayerData.career.distance_travelled + PlayerData.career.distance_earned,
		CareerData.MAX_DISTANCE_TRAVELLED)
	PlayerData.career.distance_earned = 0
	
	# prepare the label text
	_label.text = ""
	if distance_just_travelled:
		_label.text += "Distance: %s (+%s)\n\n" % [PlayerData.career.distance_travelled, distance_just_travelled]
	else:
		_label.text += "Distance: %s\n\n" % [PlayerData.career.distance_travelled]
	_label.text += "Earnings: %s\n\n" % [StringUtils.format_money(PlayerData.career.daily_earnings)]
	_label.text += "Current Time: %s" % [TEXT_BY_HOURS.get(PlayerData.career.hours_passed, "?:?? zm")]
	if not TEXT_BY_HOURS.has(PlayerData.career.hours_passed):
		push_warning("TEXT_BY_HOURS has no entry for %s" % [PlayerData.career.hours_passed])
	
	# prepare the history text
	_history.bbcode_text = "[center]"
	for i in range(PlayerData.career.prev_distance_travelled.size()):
		var daily_earnings: int = PlayerData.career.prev_daily_earnings[i]
		var distance_travelled: int = PlayerData.career.prev_distance_travelled[i]
		if _history.bbcode_text:
			_history.bbcode_text += "\n"
		_history.bbcode_text += "%s (%s)" % \
				[StringUtils.comma_sep(distance_travelled), StringUtils.format_money(daily_earnings)]
	_history.bbcode_text += "[/center]"
	
	_button.grab_focus()


## Return a set of random level ids.
##
## We only select levels appropriate for the current distance, and we exclude levels which have been played today.
func _random_level_ids() -> Array:
	var levels := CareerLevelLibrary.career_levels_for_distance(PlayerData.career.distance_travelled)
	levels.shuffle()
	var random_levels := levels.slice(0, min(SELECTION_COUNT - 1, levels.size() - 1))
	var random_level_index := 0
	for level in levels:
		random_levels[random_level_index] = level
		if PlayerData.career.daily_level_ids.has(level):
			# this level has been played today; try the next one
			pass
		else:
			# this level hasn't been played; add it to the list
			random_level_index += 1
		
		if random_level_index >= random_levels.size():
			# we've found enough levels
			break
	
	return random_levels


func _on_Button_pressed() -> void:
	var random_levels := _random_level_ids()
	
	# launch the selected level
	CurrentLevel.set_launched_level(random_levels[0].level_id)
	CurrentLevel.piece_speed = CareerLevelLibrary.piece_speed_for_distance(PlayerData.career.distance_travelled)
	PlayerData.career.push_career_trail()
