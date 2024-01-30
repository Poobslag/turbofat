class_name CreditsPiece
extends Sprite
## Puzzle piece which appears on the credits.

enum TargetType {
	NONE,
	POSITION,
	NODE,
}

## Speed at which pieces are launched from the orb
const INITIAL_SPEED := 600

## Duration for pieces to float towards a target
const APPROACH_DURATION := 0.976

## Duration for pieces to float aimlessly
const DRIFT_DURATION := 2.0

const PIECE_COLORS_BY_FRAME := [
	Color("ff636d"), # T (V-Block)
	Color("ffb474"), # u (U-Block)
	Color("ffef7d"), # r (L-Block)
	Color("94ff82"), # b (Q-Block)
	Color("82fffb"), # o (O-Block)
	Color("82baff"), # f (J-Block)
	Color("b182ff"), # a (P-Block)
	Color("ff7afb"), # t (T-Block)
]

## The pieces's position/velocity/rotation as launched from the orb
var _source_position: Vector2
var _source_velocity: Vector2
var _source_rotation: float

## Enum from TargetType for the type of target the piece is homing in on, if any.
var _target_type: int

## For TargetType.NODE, this defines the node the piece is homing in on.
var _target_node: Node

## For TargetType.POSITION, this defines the position the piece is homing in on.
var _target_position: Vector2

## Number of seconds elapsed since the piece was launched
var _total_time: float

## Parameters:
## 	'init_orb': The orb which is launching this puzzle piece
##
## 	'init_progress_bar': The progress bar this puzzle piece should home in on
func initialize(init_orb: CreditsOrb) -> void:
	scale = init_orb.scale
	modulate = init_orb.modulate
	_source_position = init_orb.position
	_source_velocity = init_orb.pop_launch_dir() * INITIAL_SPEED
	_source_rotation = init_orb.rotation
	rotation = _source_rotation
	frame = init_orb.frame
	position = _source_position


func _process(delta: float) -> void:
	_total_time += delta
	
	# update source position/rotation
	_source_position += _source_velocity * delta
	_move()


func set_target_node(new_target_node: Node) -> void:
	_target_node = new_target_node
	_target_type = TargetType.NODE


func set_target_position(new_target_position: Vector2) -> void:
	_target_position = new_target_position
	_target_type = TargetType.POSITION


## Updates the piece's position to drift aimlessly or home in on a target.
func _move() -> void:
	match _target_type:
		TargetType.NONE:
			_drift_aimlessly()
		TargetType.POSITION:
			_approach_position(_target_position)
		TargetType.NODE:
			_approach_position(_target_node.get_global_transform().origin - get_parent().get_global_transform().origin)


## Updates the piece's position based on its initial velocity.
func _drift_aimlessly() -> void:
	position = _source_position
	if _total_time > DRIFT_DURATION:
		queue_free()


## Updates the piece's position to home in on a target.
func _approach_position(position_to_approach: Vector2) -> void:
	var flight_amount := clamp(_total_time / APPROACH_DURATION, 0, 1)
	flight_amount = pow(flight_amount, 1.5)
	position = lerp(_source_position, position_to_approach, flight_amount)
	if _total_time > APPROACH_DURATION:
		queue_free()
