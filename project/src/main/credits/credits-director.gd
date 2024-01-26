extends Node
## Schedules all of the events for the credits.
##
## The credits involve a few different phases which synchronize with the music:
## 	PART_1: Initial credits scroll
## 	PART_2: A few walls of text which summarize the player's journey
## 	PART_3: Additional credits scroll

## Duration in seconds for the first part of the credits, the initial credits scroll.
const PART_1_DURATION := 40.0

## Number of empty lines which should scroll by before the wall of texts show up.
const BUFFER_LINE_COUNT := 17

## Duration in seconds for the second part of the credits, the walls of text which summarize the player's journey.
const PART_2_DURATION := 20.0

## Duration in seconds for the third part of the credits, the additional credits scroll.
const PART_3_DURATION := 60.0

## Contents of the first part of the credits, the initial credits scroll.
var part_1 := [
	"#turbo_fat#",
	"",
	tr("Created by:"),
	" " + tr("Aaron \"Poobslag\" Pieper"),
	"",
	tr("Game design, programming, graphics and sound:"),
	" " + tr("Aaron \"Poobslag\" Pieper"),
	"",
	tr("Music:"),
	" " + tr("Pete Ellison"),
	"",
	tr("Spanish Localization:"),
	" " + tr("Hish"),
	"",
	tr("Testing:"),
	" " + tr("Blazingpelt"),
	" " + tr("Hish"),
	" " + tr("TJ2024 \"Buggo\""),
	"",
	tr("Special thanks:"),
	" " + tr("Cheeseness"),
	]

## Contents of the second part of the credits, the walls of text which summarize the player's journey.
var part_2 := [
	tr("#wall_of_text# #player# and #sensei# started this journey with just one moderately successful restaurant and"
			+ " a dream. But after a long tireless journey, they had several more moderately successful restaurants."
			+ " ...And a plaque."),
	tr("#wall_of_text# As #player# looked out across the sea of loving friends and loyal customers, they reflected on"
			+ " those special individuals. ...Without whom, they may have never thought to purchase a plaque!"),
]

## Contents of the third part of the credits, the additional credits scroll.
var part_3 := [
	tr("Third party assets:"),
	" " + tr("\"2000 Game SFX Collection\" by GameBurp at Soniss"),
	" " + tr("\"Blogger Sans\" by Sergiy Tkachenko"),
	" " + tr("\"Bosca Ceoil\" by Terry Cavanagh"),
	" " + tr("\"Cartoon Voices\" by Dawid Moroz, Soundholder Studio"),
	" " + tr("\"Clog Boxes\" by Alan Vista"),
	" " + tr("\"Cooking Game\" by Epic Stock Media at Soniss"),
	" " + tr("\"FilmCow Royalty Free Sound Effects Library\" by FilmCow"),
	" " + tr("\"Fredoka One\" by Milena Brandao"),
	" " + tr("\"Hanna Barbera SoundFX Library\" by Hanna Barbera"),
	" " + tr("\"Modak\" by Ek Type"),
	" " + tr("\"Nikumaru\" by Kato Masashi"),
	" " + tr("\"Schoolbell\" by Font Diner"),
	" " + tr("\"TS-808 emulator\" by Jonathan Murphy/Tactile Sounds"),
	" " + tr("\"Tracery\" by Kate Compton"),
	"",
	"#made_with_godot#",
]

onready var _credits_scroll: CreditsScroll = get_parent()

## Loading this scene immediately schedules all of the credits events.
func _ready() -> void:
	var credits_tween := get_tree().create_tween()
	_schedule_part_1(credits_tween)
	_schedule_part_2(credits_tween)
	_schedule_part_3(credits_tween)


## Schedules events for the first part of the credits, the initial credits scroll.
func _schedule_part_1(credits_tween: SceneTreeTween) -> void:
	# Update the scroll velocity based on how far the credits need to scroll.
	var part_1_height := _total_credits_height(part_1)
	credits_tween.tween_callback(self, "_set_credits_scroll_velocity", [part_1_height / PART_1_DURATION])
	
	# Add all of the credit lines.
	for i in range(part_1.size()):
		credits_tween.tween_callback(self, "_add_credit_line", [part_1[i]])
		credits_tween.tween_interval(PART_1_DURATION / (part_1.size() + BUFFER_LINE_COUNT))
	
	# Don't start part 2 until a certain number of empty lines scroll by.
	credits_tween.tween_interval(BUFFER_LINE_COUNT * PART_1_DURATION / (part_1.size() + BUFFER_LINE_COUNT))


## Schedules events for the second part of the credits, the walls of text which summarize the player's journey.
func _schedule_part_2(credits_tween: SceneTreeTween) -> void:
	for i in range(part_2.size()):
		credits_tween.tween_callback(self, "_add_credit_line", [part_2[i]])
		credits_tween.tween_interval(PART_2_DURATION / part_2.size())


## Schedules events for the third part of the credits, the additional credits scroll.
func _schedule_part_3(credits_tween: SceneTreeTween) -> void:
	# Update the scroll velocity based on how far the credits need to scroll.
	var part_3_height := _total_credits_height(part_3)
	credits_tween.tween_callback(self, "_set_credits_scroll_velocity", [part_3_height / PART_3_DURATION])
	
	# Add all of the credit lines.
	for i in range(part_3.size()):
		credits_tween.tween_callback(self, "_add_credit_line", [part_3[i]])
		credits_tween.tween_interval(PART_3_DURATION / (part_3.size() + BUFFER_LINE_COUNT))


## Calculates the height in units of all combined credits lines.
##
## This determines how fast the credits need to scroll.
func _total_credits_height(lines: Array) -> float:
	var total := 0.0
	for line in lines:
		if line == "#made_with_godot#":
			total += 144.0
		else:
			total += 30
	total += 30 * BUFFER_LINE_COUNT
	return total


## Adds a line to the CreditsScroll based on the specified script event.
##
## These script events are can be human-readable text like "Created by:" or commands like "#made_with_godot#" which
## trigger a special event.
##
## Parameters:
## 	'line': The script event which adds a line to the credits scroll.
func _add_credit_line(line: String) -> void:
	if line == "#made_with_godot#":
		_credits_scroll.add_godot_line()
	elif line == "#turbo_fat#":
		_credits_scroll.add_turbo_fat_line()
	elif line.begins_with("#wall_of_text# "):
		_credits_scroll.show_wall_of_text(line.trim_prefix("#wall_of_text# "), 10.0)
	elif line.begins_with(" "):
		_credits_scroll.add_indent_line(line.trim_prefix(" "))
	elif line == "":
		## don't need to add blank lines
		pass
	else:
		_credits_scroll.add_line(line)


func _set_credits_scroll_velocity(new_velocity_y: float) -> void:
	_credits_scroll.velocity = Vector2(0, -new_velocity_y)
