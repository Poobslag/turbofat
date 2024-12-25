class_name CreditsDirector
extends Node
## Schedules all of the events for the credits.
##
## The credits involve a few different phases which synchronize with the music:
## 	PART_1: Initial credits scroll
## 	PART_2: A few walls of text which summarize the player's journey
## 	PART_3: Additional credits scroll

## Threshold where the credits adjust their visuals to sync back up with the music.
const DESYNC_THRESHOLD_MSEC := 40

## Duration in seconds for the first part of the credits, the initial credits scroll.
const PART_1_DURATION := 40.0

## Number of empty lines which should scroll by before the wall of texts show up.
const BUFFER_LINE_COUNT := 17

## Duration in seconds for the second part of the credits, the walls of text which summarize the player's journey.
const PART_2_DURATION := 20.0

## Duration in seconds for the third part of the credits, the additional credits scroll.
const PART_3_DURATION := 37.0

export (NodePath) var PinupScrollersPath: NodePath

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
	" " + tr("\"Cooking Game\" by Epic Stock Media at Soniss"),
	" " + tr("\"Doorbell Pull Store Bell\" by Maisonsonique at FreeSound.org"),
	" " + tr("\"FilmCow Royalty Free Sound Effects Library\" by FilmCow"),
	" " + tr("\"Fredoka One\" by Milena Brandao"),
	" " + tr("\"GodotSteam\" by GP Garcia"),
	" " + tr("\"Gut\" by Tom \"Butch\" Wesley"),
	" " + tr("\"Hanna Barbera SoundFX Library\" by Hanna Barbera"),
	" " + tr("\"Modak\" by Ek Type"),
	" " + tr("\"Nikumaru\" by Kato Masashi"),
	" " + tr("\"Schoolbell\" by Font Diner"),
	" " + tr("\"TS-808 emulator\" by Jonathan Murphy/Tactile Sounds"),
	" " + tr("\"Tracery\" by Kate Compton"),
	"",
	"#made_with_godot#",
]

## True if this script is currently altering Engine.time_scale to sync up the music.
var adjusting_time_scale := false

## Schedules event synchronized with the music.
onready var _music_sync_player: AnimationPlayer = $MusicSyncPlayer

## Periodically triggers a check that the music is synchronized.
onready var _timer: Timer = $Timer

onready var _pinup_scrollers := get_node(PinupScrollersPath)

onready var _credits_scroll: CreditsScroll = get_parent()

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	if PlayerData.career.is_region_finished(CareerLevelLibrary.region_for_id("lava")):
		play_cool_credits()
	else:
		play_boring_credits()


## Schedules all of the credits events for the "cool credits" after the player beats the game.
func play_cool_credits() -> void:
	if not is_inside_tree():
		return
	
	MusicPlayer.play_credits_track()
	_music_sync_player.play("play")
	
	# initialize total_time to a particular value, so the letters which hit the header are 'T', 'u', 'r'...
	_credits_scroll.orb.initialize_time(2.92682)
	
	var credits_tween := get_tree().create_tween()
	_schedule_part_1(credits_tween)
	_schedule_part_2(credits_tween)
	_schedule_part_3(credits_tween)
	_schedule_part_4(credits_tween)
	
	# wait for CreditsScroll to initialize
	if is_inside_tree():
		yield(get_tree(), "idle_frame")
	
	# assign the letters which poof into the title; these correspond to kick drums in the music
	_credits_scroll.set_target_header_letter_for_piece(348, 0)
	_credits_scroll.set_target_header_letter_for_piece(349, 1)
	_credits_scroll.set_target_header_letter_for_piece(350, 2)
	_credits_scroll.set_target_header_letter_for_piece(351, 3)
	_credits_scroll.set_target_header_letter_for_piece(352, 4)
	_credits_scroll.set_target_header_letter_for_piece(353, 6)
	
	_credits_scroll.set_right_transformation_target_for_piece(76)
	_credits_scroll.set_left_transformation_target_for_piece(92)
	_credits_scroll.set_right_transformation_target_for_piece(108)
	_credits_scroll.set_left_transformation_target_for_piece(252)
	_credits_scroll.set_right_transformation_target_for_piece(268)
	_credits_scroll.set_left_transformation_target_for_piece(284)
	_credits_scroll.set_right_transformation_target_for_piece(300)
	_credits_scroll.set_left_transformation_target_for_piece(316)
	_credits_scroll.set_right_transformation_target_for_piece(332)
	_credits_scroll.set_right_transformation_target_for_piece(364)


## Schedules all of the credits events for the "boring credits" before the player beats the game.
func play_boring_credits() -> void:
	if not is_inside_tree():
		return
	
	MusicPlayer.play_menu_track()
	var credits_tween := get_tree().create_tween()
	
	var boring_credits := []
	boring_credits.append_array(part_1)
	boring_credits.append_array([""])
	boring_credits.append_array(part_3)
	for _i in range(BUFFER_LINE_COUNT):
		boring_credits.append_array([""])
	
	_set_credits_scroll_velocity(30)
	
	# Add all of the credit lines.
	for credit in boring_credits:
		credits_tween.tween_callback(self, "_add_credit_line", [credit])
		credits_tween.tween_interval(_line_height(credit) / abs(_credits_scroll.velocity.y))
	credits_tween.set_loops()


## Returns the number of seconds the music is ahead of the animation.
##
## If the game logic lags, the music will end up ahead and this will be a positive number. If the AudioStreamPlayer
## lags, the game will end up ahead and this will be a negative number.
func get_desync_amount() -> float:
	var result := 0.0
	if _music_sync_player.current_animation == "play" and _music_sync_player.is_playing() \
			and MusicPlayer.current_track:
		result = MusicPlayer.current_track.get_playback_position() - _music_sync_player.current_animation_position
	return result


## Schedules events for the first part of the credits, the initial credits scroll.
func _schedule_part_1(credits_tween: SceneTreeTween) -> void:
	# Update the scroll velocity based on how far the credits need to scroll.
	var part_1_height := _total_credits_height(part_1)
	credits_tween.tween_callback(self, "_set_credits_scroll_velocity", [part_1_height / PART_1_DURATION])
	
	# Add all of the credit lines.
	for credit_line in part_1:
		credits_tween.tween_callback(self, "_add_credit_line", [credit_line])
		credits_tween.tween_interval(PART_1_DURATION / (part_1.size() + BUFFER_LINE_COUNT))
	
	# Don't start part 2 until a certain number of empty lines scroll by.
	credits_tween.tween_interval(BUFFER_LINE_COUNT * PART_1_DURATION / (part_1.size() + BUFFER_LINE_COUNT))


## Schedules events for the second part of the credits, the walls of text which summarize the player's journey.
func _schedule_part_2(credits_tween: SceneTreeTween) -> void:
	for credit_line in part_2:
		credits_tween.tween_callback(self, "_add_credit_line", [credit_line])
		credits_tween.tween_interval(PART_2_DURATION / part_2.size())


## Schedules events for the third part of the credits, the additional credits scroll.
func _schedule_part_3(credits_tween: SceneTreeTween) -> void:
	# Update the scroll velocity based on how far the credits need to scroll.
	var part_3_height := _total_credits_height(part_3)
	credits_tween.tween_callback(self, "_set_credits_scroll_velocity", [part_3_height / PART_3_DURATION])
	
	# Add all of the credit lines.
	for credit_line in part_3:
		credits_tween.tween_callback(self, "_add_credit_line", [credit_line])
		credits_tween.tween_interval(PART_3_DURATION / (part_3.size() + BUFFER_LINE_COUNT))
	
	# Don't start part 4 until a certain number of empty lines scroll by.
	credits_tween.tween_interval(BUFFER_LINE_COUNT * PART_3_DURATION / (part_3.size() + BUFFER_LINE_COUNT))


## Schedules events for the fourth part of the credits, the end screen.
func _schedule_part_4(credits_tween: SceneTreeTween) -> void:
	credits_tween.tween_callback(self, "_add_credit_line", ["#end_text#"])


## Calculates the height in units of all combined credits lines.
##
## This determines how fast the credits need to scroll.
func _total_credits_height(lines: Array) -> float:
	var total := 0.0
	for line in lines:
		total += _line_height(line)
	total += 30 * BUFFER_LINE_COUNT
	return total


## Calculates the height in units of a credits line.
##
## This determines how fast the credits need to scroll.
func _line_height(line: String) -> float:
	return 144.0 if line == "#made_with_godot#" else 30.0


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
	elif line == "#end_text#":
		_credits_scroll.show_end_text()
	elif line.begins_with(" "):
		_credits_scroll.add_indent_line(line.trim_prefix(" "))
	elif line == "":
		## don't need to add blank lines
		pass
	else:
		_credits_scroll.add_line(line)


func _set_credits_scroll_velocity(new_velocity_y: float) -> void:
	_credits_scroll.velocity = Vector2(0, -new_velocity_y)


## Every once in awhile, we check to make sure the music is in sync with our credits.
##
## These can fall out of sync if the game runs too slow for some reason. I can force it to happen by dragging the
## window around. If the music falls out of sync, we modify Engine.time_scale to make the game run faster or slower.
## This doesn't affect audio playback rate.
func _on_Timer_timeout() -> void:
	if not adjusting_time_scale and Engine.time_scale != 1.0:
		# Something else is adjusting the time scale, so we shouldn't interfere with it.
		return
	
	if adjusting_time_scale:
		Engine.time_scale = 1.0
		adjusting_time_scale = false
	
	var desync_amount := get_desync_amount()
	if abs(desync_amount * 1000) > DESYNC_THRESHOLD_MSEC:
		# To calculate the ideal time scale to get us back in sync, we take the amount of time we need to simulate and
		# divide it by the amount of time until the next desync check. (This may be negative.)
		var new_time_scale := (_timer.wait_time + desync_amount) / _timer.wait_time
		
		# We clamp the timescale to avoid negative numbers, and to smooth any jerky speed ups or slowdowns.
		new_time_scale = clamp(new_time_scale, 0.33333, 3.0)
		
		Engine.time_scale = new_time_scale
		adjusting_time_scale = true
