class_name GameplaySettings
## Manages settings which control the gameplay.

signal ghost_piece_changed(value)
signal soft_drop_lock_cancel_changed(value)

## 'true' if a ghost piece should be shown during the puzzle sections.
var ghost_piece := true setget set_ghost_piece

## 'true' if pressing soft drop should perform a lock cancel
var soft_drop_lock_cancel := false setget set_soft_drop_lock_cancel

## Transient properties which are temporarily stored for backwards compatibility.
##
## Currently, this includes the old 'hold_piece', 'line_piece' and 'speed' properties. These properties were moved
## from SystemData to PlayerData, but for our backwards-compatibility logic to run and populate PlayerData with the
## player's old settings, they need to be stored somewhere between when SystemData is upgraded and PlayerData is
## upgraded.
var legacy_properties := {}

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


## Resets the gameplay settings to their default values.
func reset() -> void:
	from_json_dict({})


func to_json_dict() -> Dictionary:
	return {
		"ghost_piece": ghost_piece,
		"soft_drop_lock_cancel": soft_drop_lock_cancel,
	}


func from_json_dict(json: Dictionary) -> void:
	set_ghost_piece(json.get("ghost_piece", true))
	set_soft_drop_lock_cancel(json.get("soft_drop_lock_cancel", false))
	legacy_properties = json.get("legacy_properties", {})
