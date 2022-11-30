class_name GameplaySettings
## Manages settings which control the gameplay.

signal ghost_piece_changed(value)
signal soft_drop_lock_cancel_changed(value)
signal speed_changed(value)
signal line_piece_changed(value)
signal hold_piece_changed(value)

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

## Returns a number in the range [0.0, ∞) for how piece gravity should be modified for each gameplay speed setting.
##
## A value like 2.0 means pieces should fall faster, and a value like 0.5 means they should fall slower.
const GRAVITY_FACTOR_BY_ENUM := {
	Speed.DEFAULT: 1.0,
	Speed.SLOW: 0.707,
	Speed.SLOWER: 0.500,
	Speed.SLOWEST: 0.333,
	Speed.SLOWESTEST: 0.0,
	Speed.FAST: 1.414,
	Speed.FASTER: 1.5,
	Speed.FASTEST: 2.0,
	Speed.FASTESTEST: 100.0,
}

## 'true' if a ghost piece should be shown during the puzzle sections.
var ghost_piece := true setget set_ghost_piece

## 'true' if the player can use a 'hold piece'
var hold_piece := false setget set_hold_piece

## 'true' if line pieces should appear on all levels
var line_piece := false setget set_line_piece

## 'true' if pressing soft drop should perform a lock cancel
var soft_drop_lock_cancel := true setget set_soft_drop_lock_cancel

## The current gameplay speed. The player can reduce this to make the game easier. They can also increase it to make
## the game harder, or to cheat on levels which otherwise require slow and thoughtful play.
var speed: int = Speed.DEFAULT setget set_speed

func set_ghost_piece(new_ghost_piece: bool) -> void:
	if ghost_piece == new_ghost_piece:
		return
	ghost_piece = new_ghost_piece
	emit_signal("ghost_piece_changed", new_ghost_piece)


func set_soft_drop_lock_cancel(new_soft_drop_lock_cancel: bool) -> void:
	if soft_drop_lock_cancel == new_soft_drop_lock_cancel:
		return
	soft_drop_lock_cancel = new_soft_drop_lock_cancel
	emit_signal("soft_drop_lock_cancel_changed", new_soft_drop_lock_cancel)


func set_speed(new_speed: int) -> void:
	if speed == new_speed:
		return
	speed = new_speed
	emit_signal("speed_changed", new_speed)


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


## Resets the gameplay settings to their default values.
func reset() -> void:
	from_json_dict({})


func to_json_dict() -> Dictionary:
	return {
		"ghost_piece": ghost_piece,
		"hold_piece": hold_piece,
		"line_piece": line_piece,
		"soft_drop_lock_cancel": soft_drop_lock_cancel,
		"speed": Utils.enum_to_snake_case(Speed, speed),
	}


func from_json_dict(json: Dictionary) -> void:
	set_ghost_piece(json.get("ghost_piece", true))
	set_hold_piece(json.get("hold_piece", false))
	set_line_piece(json.get("line_piece", false))
	set_soft_drop_lock_cancel(json.get("soft_drop_lock_cancel", true))
	set_speed(Utils.enum_from_snake_case(Speed, json.get("speed", "")))


## Returns a number in the range [0.0, ∞) for how piece gravity should be modified.
##
## A value like 2.0 means pieces should fall faster, and a value like 0.5 means they should fall slower.
func get_gravity_factor() -> float:
	return GRAVITY_FACTOR_BY_ENUM.get(speed, 1.0)
