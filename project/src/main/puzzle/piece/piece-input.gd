class_name PieceInput
extends Node
"""
Handles input for controlling the player's piece.
"""

"""
Records any inputs to a buffer to be replayed later.
"""
func buffer_inputs() -> void:
	for child in get_children():
		child.buffer_input()


"""
Replays any inputs which were pressed while buffering.
"""
func pop_buffered_inputs() -> void:
	for child in get_children():
		child.pop_buffered_input()


func is_cw_just_pressed() -> bool: return $Cw.is_just_pressed()
func is_cw_pressed() -> bool: return $Cw.is_pressed()
func set_cw_input_as_handled() -> void: $Cw.set_input_as_handled()

func is_ccw_just_pressed() -> bool: return $Ccw.is_just_pressed()
func is_ccw_pressed() -> bool: return $Ccw.is_pressed()
func set_ccw_input_as_handled() -> void: $Ccw.set_input_as_handled()

func is_left_just_pressed() -> bool: return $Left.is_just_pressed()
func is_left_pressed() -> bool: return $Left.is_pressed()
func is_left_das_active() -> bool: return $Left.is_das_active()
func set_left_das_active() -> void: $Left.pressed_frames = 3600
func set_left_input_as_handled() -> void: $Left.set_input_as_handled()

func is_right_just_pressed() -> bool: return $Right.is_just_pressed()
func is_right_pressed() -> bool: return $Right.is_pressed()
func is_right_das_active() -> bool: return $Right.is_das_active()
func set_right_das_active() -> void: $Right.pressed_frames = 3600
func set_right_input_as_handled() -> void: $Right.set_input_as_handled()

func is_soft_drop_just_pressed() -> bool: return $SoftDrop.is_just_pressed()
func is_soft_drop_pressed() -> bool: return $SoftDrop.is_pressed()

func is_hard_drop_just_pressed() -> bool: return $HardDrop.is_just_pressed()
func is_hard_drop_das_active() -> bool: return $HardDrop.is_das_active()
