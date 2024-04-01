class_name CreditsEndText
extends Node2D
## The screen after the credits which congratulates the player and shows their grade.

## Duration to fade text from transparent to opaque
const FADE_DURATION := 0.5

## Random grades to cycle between when showing the player's scrambled grade
const GRADES := ["M", "SSS", "SS+", "SS", "S+", "S", "S-", "AA+", "AA", "A+", "A", "A-", "B+", "B", "B-"]

## Completion percent currently shown; updating this value updates the label
var displayed_completion_percent: float setget set_displayed_completion_percent

## Grade currently shown; updating this value updates the label
var displayed_grade: String setget set_displayed_grade

## Stores the previously visible characters to calculate when new characters are revealed
var _old_congratulations_visible_characters: int

## Container holding all visual elements
onready var _vbox_container := $VBoxContainer

## Combo sounds played when revealing the final 'turbofat' letters
onready var _combo_sounds := [
	$ComboSound0,
	$ComboSound1,
	$ComboSound2,
	$ComboSound3,
	$ComboSound4,
	$ComboSound5,
	$ComboSound6,
	$ComboSound7,
]

## 'turbofat' title revealed letter-by-letter
onready var _title := $Title

## Visual elements showing the player's grade; hidden if the player does not reach 100% completion
onready var _grade_container := $VBoxContainer/HBoxContainer/GradeContainer
onready var _grade_label := $VBoxContainer/HBoxContainer/GradeContainer/Label
onready var _grade_value := $VBoxContainer/HBoxContainer/GradeContainer/Value
onready var _grade_particles := $VBoxContainer/HBoxContainer/GradeContainer/Value/Particles

## Visual elements showing the player's completion percent
onready var _completion_label := $VBoxContainer/HBoxContainer/CompletionContainer/Label
onready var _completion_value := $VBoxContainer/HBoxContainer/CompletionContainer/Value
onready var _completion_particles := $VBoxContainer/HBoxContainer/CompletionContainer/Value/Particles

## Label which shows a congratulatory message; revealed letter-by-letter
onready var _congratulations_label := $VBoxContainer/CongratulationsLabel

## plays a typewriter sound as text appears
onready var _bebebe_sound := $BebebeSound

## Timer which rapidly cycles through different grades
onready var _grade_scramble_timer := $GradeScrambleTimer

## Plays a winding sound as the grade/completion are calculated
onready var _clock_advance_sound := $ClockAdvanceSound

## Plays a ringing sound as the grade/completion are shown
onready var _clock_ring_sound := $ClockRingSound

func _ready() -> void:
	_old_congratulations_visible_characters = _congratulations_label.visible_characters
	_vbox_container.modulate = Color.transparent


func _process(_delta: float) -> void:
	if _congratulations_label.visible_characters > _old_congratulations_visible_characters \
			and _congratulations_label.visible_characters != -1 \
			and _old_congratulations_visible_characters != -1:
		
		# the number of visible letters increased. play a sound effect
		_bebebe_sound.volume_db = rand_range(-22.0, -12.0)
		_bebebe_sound.pitch_scale = rand_range(0.95, 1.05)
		_bebebe_sound.play()
	
	_old_congratulations_visible_characters = _congratulations_label.visible_characters


## Animates the credits end text, gradually revealing visual components with sound effects.
##
## Parameters:
## 	'completion_percent': Number in the range [0.0, 1.0] for how close the player is to completing all regions.
##
## 	'grade': Overall letter grade for all regions such as 'SSS' or 'AA+'
func play(completion_percent: float, grade: String) -> void:
	_reset()
	
	create_tween().tween_property(_vbox_container, "modulate", Color.white, FADE_DURATION)
	
	var tween := create_tween()
	
	# play 'completion percent' animation
	tween.tween_callback(self, "_play_completion_animation", [completion_percent])
	
	if completion_percent == 1.0:
		# play 'grade' animation
		_grade_container.visible = true
		tween.tween_callback(self, "_play_grade_animation", [grade]).set_delay(3.0)
	else:
		_grade_container.visible = false
	
	# slowly type out 'congratulations! you are a super player'
	tween.tween_callback(self, "_play_congratulations_animation").set_delay(3.0)
	
	# burst in letters in 'turbo fat'
	tween.tween_callback(self, "_play_title_animation").set_delay(8.0)


func set_displayed_grade(new_displayed_grade: String) -> void:
	displayed_grade = new_displayed_grade
	
	_grade_value.text = new_displayed_grade


func set_displayed_completion_percent(new_displayed_completion_percent: float) -> void:
	displayed_completion_percent = new_displayed_completion_percent
	
	_completion_value.text = tr("%.1f%%") % [100.0 * displayed_completion_percent]


## Resets the end text screen to its initial state, with all components invisible.
func _reset() -> void:
	_completion_label.modulate = Color.transparent
	_completion_value.modulate = Color.transparent
	
	_grade_label.modulate = Color.transparent
	_grade_value.modulate = Color.transparent
	
	_congratulations_label.visible_characters = 0
	
	_title.reset()


## Plays the 'completion' label animation.
##
## The label appears, and then the label value gradually increases from 0% to the player's completion percent.
##
## Parameters:
## 	'completion_percent': Number in the range [0.0, 1.0] for how close the player is to completing all regions.
func _play_completion_animation(completion_percent: float) -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_completion_label, "modulate", Color.white, FADE_DURATION)
	
	displayed_completion_percent = 0.0
	_completion_value.modulate = Color.white
	_completion_value.text = ""
	
	tween.tween_callback(_clock_advance_sound, "play").set_delay(0.7)
	tween.tween_property(self, "displayed_completion_percent", completion_percent, 1.5) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.7)
	tween.tween_callback(_completion_particles, "emit").set_delay(2.2)
	tween.tween_callback(_clock_advance_sound, "stop").set_delay(2.2)
	tween.tween_callback(_clock_ring_sound, "play").set_delay(2.2)


## Plays the 'grade' label animation.
##
## The label appears, and then the label value cycles erratically between all possible grades before settling on the
## final grade.
##
## Parameters:
## 	'grade': Overall letter grade for all regions such as 'SSS' or 'AA+'
func _play_grade_animation(grade: String) -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_grade_label, "modulate", Color.white, FADE_DURATION)
	
	_grade_value.modulate = Color.white
	_grade_value.text = ""
	
	tween.tween_callback(_clock_advance_sound, "play").set_delay(0.7)
	tween.tween_callback(_grade_scramble_timer, "start").set_delay(0.7)
	tween.tween_callback(_grade_scramble_timer, "stop").set_delay(2.2)
	tween.tween_callback(self, "set_displayed_grade", [grade]).set_delay(2.2)
	tween.tween_callback(_grade_particles, "emit").set_delay(2.2)
	tween.tween_callback(_clock_advance_sound, "stop").set_delay(2.2)
	tween.tween_callback(_clock_ring_sound, "play").set_delay(2.2)


## Plays the 'congratulations' label animation.
##
## The message is gradually typed out letter-by-letter accompanied with typewriter sound effects.
func _play_congratulations_animation() -> void:
	var tween := create_tween()
	tween.tween_property(_congratulations_label, "visible_characters", \
			_congratulations_label.get_total_character_count(), 7.0)


## Plays the 'turbofat title' animation.
##
## Big blocky colorful letters poof in one-by-one accompanied by sound effects.
func _play_title_animation() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	for i in range(8):
		tween.tween_callback(_title, "add_next_letter").set_delay(i * 0.2)
		tween.tween_callback(_combo_sounds[i], "play").set_delay(i * 0.2)


## When the GradeScrambleTimer times out, we show a new random grade such as 'SSS' or 'AA+'.
func _on_GradeScrambleTimer_timeout() -> void:
	var new_grade: String = Utils.rand_value(Utils.subtract(GRADES, [displayed_grade]))
	set_displayed_grade(new_grade)
