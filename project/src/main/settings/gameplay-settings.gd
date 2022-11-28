class_name GameplaySettings
## Manages settings which control the gameplay.

signal ghost_piece_changed(value)

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

## 'true' if pressing soft drop should perform a lock cancel
var soft_drop_lock_cancel := true

## The current gameplay speed. The player can reduce this to make the game easier. They can also increase it to make
## the game harder, or to cheat on levels which otherwise require slow and thoughtful play.
var speed: int = Speed.DEFAULT

func set_ghost_piece(new_ghost_piece: bool) -> void:
	if ghost_piece == new_ghost_piece:
		return
	ghost_piece = new_ghost_piece
	emit_signal("ghost_piece_changed", new_ghost_piece)


## Resets the gameplay settings to their default values.
func reset() -> void:
	from_json_dict({})


func to_json_dict() -> Dictionary:
	return {
		"ghost_piece": ghost_piece,
		"soft_drop_lock_cancel": soft_drop_lock_cancel,
		"speed": Utils.enum_to_snake_case(Speed, speed),
	}


func from_json_dict(json: Dictionary) -> void:
	set_ghost_piece(json.get("ghost_piece", true))
	soft_drop_lock_cancel = json.get("soft_drop_lock_cancel", true)
	speed = Utils.enum_from_snake_case(Speed, json.get("speed", ""))


## Returns a number in the range [0.0, ∞) for how piece gravity should be modified.
##
## A value like 2.0 means pieces should fall faster, and a value like 0.5 means they should fall slower.
func get_gravity_factor() -> float:
	return GRAVITY_FACTOR_BY_ENUM.get(speed, 1.0)
