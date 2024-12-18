extends Control
## Draws the analog clock and digital text which appears above the progress board.
##
## This includes a picture of an analog clock alongside a digital text representation of the time.

## Positions of the analog clock's hour and minute hands when the time of day is an invalid value.
const INVALID_HAND_POSITIONS := [11.0, 0.0]

## Positions of the analog clock's hour and minute hands for different times of day.
##
## key: (int) number of levels the player has played
## value: (Array, float) Array with two entries for the position of the analog clock's hour and minute hands.
const HAND_POSITIONS_BY_HOUR := {
	0: [11.0, 0.0], # 11:00 am
	1: [12.0, 10.0], # 12:10 pm
	2: [13.0, 20.0], # 1:20 pm
	3: [18.0, 30.0], # 6:30 pm
	4: [19.0, 40.0], # 7:40 pm
	5: [20.0, 50.0], # 8:50 pm
	6: [22.0, 00.0], # 10:00 pm
}

## Number of levels played in the current career session.
##
## This is stored independently of the player's career data because this clock might animate to show a time in the past
## or future.
var hours_passed := 0 setget set_hours_passed

var _tween: SceneTreeTween

## Digital text which shows the time using text like '8:50 pm'
onready var _label: Label = $Swoosher/Label

## Analog clock which shows the time using an and hour and minute hand.
onready var _visuals: ProgressBoardClockVisuals = $Swoosher/VisualsHolder/Visuals

## Winding sound that plays as the clock's hands spin.
onready var _clock_advance_sound := $ClockAdvanceSound

## Bell sound that plays when the clock's hands stop spinning.
onready var _clock_ring_sound := $ClockRingSound

func _ready() -> void:
	_refresh()


## Advance the clock for a single level.
func play(new_hours_passed: int, duration: float) -> void:
	_tween = Utils.recreate_tween(self, _tween)
	
	# Assign our underlying hours passed variable, but don't update the UI. the UI will be gradually animated to the
	# new value.
	var old_hours_passed := hours_passed
	hours_passed = new_hours_passed
	
	# During animations, the minute hand is temporarily assigned something nonsensical like 7:80 for the sake of
	# animating the clock forward. We reset the minute hand to avoid bugs where the clock might rewind backward from
	# 7:80 to 7:30
	var old_minute_hand_position := fmod(_visuals.minutes, 60)
	
	# Calculate the new minute hand position. When animating from 2:00 to 6:30, we don't want the minute hand spin 180
	# degrees, we want it to spin  to spin around 1,620 degrees. To accomplish this, we set the minute hand position to
	# something like 270.
	var new_minute_hand_position := _minute_hand_position(new_hours_passed)
	new_minute_hand_position += 60.0 * int(
				_hour_hand_position(new_hours_passed, false) - _hour_hand_position(old_hours_passed, false))
	
	_visuals.minutes = old_minute_hand_position
	_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_parallel()
	_tween.tween_property(_visuals, "minutes", new_minute_hand_position, duration)
	_tween.tween_property(_visuals, "hours", _hour_hand_position(new_hours_passed), duration)
	_tween.tween_property(_visuals, "filled_percent", _filled_percent(new_hours_passed), duration)
	_tween.chain().tween_callback(self, "_on_Tween_completed")
	
	_clock_advance_sound.play()
	


func set_hours_passed(new_hours_passed: int = 0) -> void:
	hours_passed = new_hours_passed
	
	_refresh()


## Calculates the desired minute/hour hand positions.
##
## Parameters:
## 	'new_hours_passed': The number of hours passed in career mode.
##
## Returns:
## 	Array with two float entries for the position of the analog clock's hour and minute hands.
func _hand_positions(new_hours_passed: int) -> Array:
	var hand_positions: Array
	if new_hours_passed > Careers.HOURS_PER_CAREER_DAY:
		hand_positions = HAND_POSITIONS_BY_HOUR.get(Careers.HOURS_PER_CAREER_DAY)
	else:
		hand_positions = HAND_POSITIONS_BY_HOUR.get(new_hours_passed, INVALID_HAND_POSITIONS)
	return hand_positions


## Calculates the desired minute hand position.
##
## Parameters:
## 	'new_hours_passed': The number of hours passed in career mode.
func _minute_hand_position(new_hours_passed: int) -> float:
	return _hand_positions(new_hours_passed)[1]


## Calculates the desired hour hand position, advancing it based on the minute hand position.
##
## Parameters:
## 	'new_hours_passed': The number of hours passed in career mode.
##
## 	'advance_for_minutes': If true, the hour hand will be advanced based on the minute hand position, pointing between
## 		two numbers on an analog clock. If false, the hour hand will ignore the minute hand, pointing directly to one
## 		of the twelve numbers on an analog clock.
func _hour_hand_position(new_hours_passed: int, advance_for_minutes: bool = true) -> float:
	var new_hours: float = _hand_positions(new_hours_passed)[0]
	if advance_for_minutes:
		new_hours += _minute_hand_position(new_hours_passed) / 60.0
	return new_hours


## Calculates how much of the clock should be filled.
##
## Parameters:
## 	'new_hours_passed': The number of hours passed in career mode.
##
## Returns:
## 	A number in the range [0.0, 1.0] for how much of the clock should be filled.
func _filled_percent(new_hours_passed: int) -> float:
	var filled_percent: float
	if new_hours_passed == Careers.HOURS_PER_CAREER_DAY:
		filled_percent = 1.0
	else:
		filled_percent = _minute_hand_position(new_hours_passed) / 60.0
	return filled_percent


## Calculates the text of the digital clock, like '12:30 pm'
func _clock_text(new_hours_passed: int) -> String:
	var text: String
	if new_hours_passed > Careers.HOURS_PER_CAREER_DAY:
		text = PlayerData.career.times_of_day_by_hour.get(Careers.HOURS_PER_CAREER_DAY)
	else:
		text = PlayerData.career.times_of_day_by_hour.get(new_hours_passed, PlayerData.career.invalid_time_of_day)
	return text


## Updates the clock visuals based on the number of hours passed.
func _refresh() -> void:
	if not is_inside_tree():
		return
	
	_visuals.minutes = _minute_hand_position(hours_passed)
	_visuals.hours = _hour_hand_position(hours_passed)
	_visuals.filled_percent = _filled_percent(hours_passed)
	
	# update digital display
	_label.text = _clock_text(hours_passed)


## When the clock stops spinning forward we update all UI elements one last time.
##
## This is especially important for the digital display which does not animate.
func _on_Tween_completed() -> void:
	_clock_advance_sound.stop()
	var old_label_text := _label.text
	_refresh()
	
	if old_label_text != _label.text:
		_clock_ring_sound.play()
		_label.flash()
