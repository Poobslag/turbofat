extends Control
## Draws the analog clock and digital text which appears above the progress board.
##
## This includes a picture of an analog clock alongside a digital text representation of the time.

## The positions of the analog clock's hour and minute hands when the time of day is an invalid value.
const INVALID_HAND_POSITIONS := [11.0, 0.0]

## The positions of the analog clock's hour and minute hands for different times of day.
##
## key: (int) corresonding to the number of levels the player has played
## value: (Array, float) An array with two entries for the position of the analog clock's hour and minute hands.
const HAND_POSITIONS_BY_HOURS := {
	0: [11.0, 0.0], # 11:00 am
	1: [12.0, 10.0], # 12:10 pm
	2: [13.0, 20.0], # 1:20 pm
	3: [18.0, 30.0], # 6:30 pm
	4: [19.0, 40.0], # 7:40 pm
	5: [20.0, 50.0], # 8:50 pm
	6: [22.0, 00.0], # 10:00 pm
}

## The number of levels played in the current career session.
##
## This is stored independently of the player's career data because this clock might animate to show a time in the past
## or future.
var hours_passed := 0 setget set_hours_passed

## Digital text which shows the time using text like '8:50 pm'
onready var _label := $Label

## Analog clock which shows the time using an and hour and minute hand.
onready var _visuals: ProgressBoardClockVisuals = $VisualsHolder/Visuals

func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return
	
	var hand_positions: Array = HAND_POSITIONS_BY_HOURS.get(PlayerData.career.hours_passed, INVALID_HAND_POSITIONS)
	
	# calculate minute hand position
	_visuals.minutes = hand_positions[1]
	
	# calculate hour hand position, advancing it based on the minute hand position
	var new_hours: float = hand_positions[0]
	new_hours += _visuals.minutes / 60.0
	_visuals.hours = new_hours
	
	# calculate how much of the clock is filled
	var filled_percent: float
	if hours_passed == CareerData.HOURS_PER_CAREER_DAY:
		filled_percent = 1.0
	else:
		filled_percent = _visuals.minutes / 60.0
	_visuals.filled_percent = filled_percent
	
	# update digital display
	_label.text = PlayerData.career.time_of_day_by_hours.get(
			PlayerData.career.hours_passed, PlayerData.career.invalid_time_of_day)


## Advance the clock for a single level.
func advance() -> void:
	set_hours_passed(hours_passed + 1)


func set_hours_passed(new_hours_passed: int = 0) -> void:
	hours_passed = new_hours_passed
	
	_refresh()
