class_name PieceInput
extends Node
## Handles input for controlling the player's piece.

@onready var left: FrameInput = $Left
@onready var right: FrameInput = $Right
@onready var cw: FrameInput = $Cw
@onready var ccw: FrameInput = $Ccw
@onready var soft_drop: FrameInput = $SoftDrop
@onready var hard_drop: FrameInput = $HardDrop
@onready var swap_hold_piece: FrameInput = $SwapHoldPiece

## Records any inputs to a buffer to be replayed later.
func buffer_inputs() -> void:
	for child in get_children():
		child.buffer_input()


## Replays any inputs which were pressed while buffering.
func pop_buffered_inputs() -> void:
	for child in get_children():
		child.pop_buffered_input()


func is_cw_just_pressed() -> bool: return cw.is_just_pressed()
func is_cw_pressed() -> bool: return cw.is_pressed()
func set_cw_input_as_handled() -> void: cw.set_input_as_handled()

func is_ccw_just_pressed() -> bool: return ccw.is_just_pressed()
func is_ccw_pressed() -> bool: return ccw.is_pressed()
func set_ccw_input_as_handled() -> void: ccw.set_input_as_handled()

func is_left_just_pressed() -> bool: return left.is_just_pressed()
func is_left_pressed() -> bool: return left.is_pressed()
func is_left_das_active() -> bool: return left.is_das_active()
func set_left_das_active() -> void: left.pressed_frames = 3600
func set_left_input_as_handled() -> void: left.set_input_as_handled()

func is_right_just_pressed() -> bool: return right.is_just_pressed()
func is_right_pressed() -> bool: return right.is_pressed()
func is_right_das_active() -> bool: return right.is_das_active()
func set_right_das_active() -> void: right.pressed_frames = 3600
func set_right_input_as_handled() -> void: right.set_input_as_handled()

func is_soft_drop_just_pressed() -> bool: return soft_drop.is_just_pressed()
func is_soft_drop_pressed() -> bool: return soft_drop.is_pressed()

func is_hard_drop_just_pressed() -> bool: return hard_drop.is_just_pressed()
func is_hard_drop_das_active() -> bool: return hard_drop.is_das_active()

func is_swap_hold_piece_just_pressed() -> bool: return swap_hold_piece.is_just_pressed()
func is_swap_hold_piece_pressed() -> bool: return swap_hold_piece.is_pressed()
