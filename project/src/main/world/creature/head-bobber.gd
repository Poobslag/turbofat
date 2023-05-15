#tool #uncomment to view creature in editor
class_name HeadBobber
extends Sprite2D
## Bobs the character's head up and down.
##
## Provides a few different 'bob modes', so that the character can shudder, nod, or laugh in different situations.

## ways the creature's head can move ambiently
enum HeadBobMode {
	OFF, # no movement
	BOB, # nodding vertically
	BOUNCE, # bouncing vertically like a ball hitting the floor
	SHUDDER, # shaking left and right
}

const BOB_OFF := HeadBobMode.OFF
const BOB_BOB := HeadBobMode.BOB
const BOB_BOUNCE := HeadBobMode.BOUNCE
const BOB_SHUDDER := HeadBobMode.SHUDDER

## these three fields control the creature's head motion: how it's moving, as well as how much/how fast
@export var head_bob_mode := HeadBobMode.BOB: set = set_head_bob_mode
@export var head_motion_pixels := 2.0
@export var head_motion_seconds := 6.5

## these constants control how much the creature's head bobs up and down 
const HEAD_BOB_SECONDS := 6.5
const HEAD_BOB_PIXELS := 2.0

## total number of seconds which have elapsed since the object was created
var _total_seconds := 0.0

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_total_seconds += delta
	var head_phase := _total_seconds * PI / head_motion_seconds
	match head_bob_mode:
		HeadBobMode.BOB:
			var bob_amount := head_motion_pixels * sin(2 * head_phase)
			position.y = -100 + bob_amount
		HeadBobMode.BOUNCE:
			var bounce_amount: float = head_motion_pixels * (1 - 2 * abs(sin(head_phase)))
			position.y = -100 + bounce_amount
		HeadBobMode.SHUDDER:
			var shudder_amount: float = head_motion_pixels * clamp(2 * sin(2 * head_phase), -1.0, 1.0)
			position.x = shudder_amount
			position.y = -100


func reset_head_bob() -> void:
	set_head_bob_mode(BOB_BOB)
	head_motion_pixels = HEAD_BOB_PIXELS
	head_motion_seconds = HEAD_BOB_SECONDS


func set_head_bob_mode(new_mode: HeadBobMode) -> void:
	head_bob_mode = new_mode
	# Some head bob animations like 'shudder' offset the x position; reset it back to the center
	position.x = 0
