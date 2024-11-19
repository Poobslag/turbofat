class_name DifficultyData
## Manages settings which control the difficulty, or helpers which make the game easier.

signal hold_piece_changed(value)
signal line_piece_changed(value)
signal speed_changed(value)

enum Speed {
	DEFAULT,
	SLOW,
	SLOWER,
	SLOWEST,
	SLOWESTEST,
	FAST,
	FASTER,
	FASTEST,
	FASTESTEST,
}

## 'true' if the player can use a 'hold piece'
var hold_piece := false setget set_hold_piece

## 'true' if line pieces should appear on all levels
var line_piece := false setget set_line_piece

## Current gameplay speed. The player can reduce this to make the game easier. They can also increase it to make
## the game harder, or to cheat on levels which otherwise require slow and thoughtful play.
var speed: int = Speed.DEFAULT setget set_speed

func set_hold_piece(new_hold_piece: bool) -> void:
	if hold_piece == new_hold_piece:
		return
	hold_piece = new_hold_piece
	emit_signal("hold_piece_changed", new_hold_piece)


func set_line_piece(new_line_piece: bool) -> void:
	if line_piece == new_line_piece:
		return
	line_piece = new_line_piece
	emit_signal("line_piece_changed", new_line_piece)


func set_speed(new_speed: int) -> void:
	if speed == new_speed:
		return
	speed = new_speed
	emit_signal("speed_changed", new_speed)


## Resets the difficulty settings to their default values.
func reset() -> void:
	from_json_dict({})


func from_json_dict(json: Dictionary) -> void:
	set_hold_piece(json.get("hold_piece", false))
	set_line_piece(json.get("line_piece", false))
	set_speed(Utils.enum_from_snake_case(Speed, json.get("speed", "")))


func to_json_dict() -> Dictionary:
	return {
		"hold_piece": hold_piece,
		"line_piece": line_piece,
		"speed": Utils.enum_to_snake_case(Speed, speed),
	}
