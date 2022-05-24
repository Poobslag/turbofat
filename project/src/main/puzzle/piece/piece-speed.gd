class_name PieceSpeed
## Stores data about a specific 'speed level' such as how fast pieces should drop, how long it takes them to lock into
## the playfield, and how long to pause when clearing lines.

## speed string which appears in the 'speed' panel
var id: String

## how fast pieces should drop, as a fraction of 256. 32 = once every 8 frames, 512 = twice a frame
var gravity: int

## number of frames to pause before a new piece appears
var appearance_delay: int

## number of frames to pause before a new piece appears, after clearing a line/making a box
var line_appearance_delay: int

## number of frames the player has to hold left/right before the piece whooshes over
var delayed_auto_shift_delay: int

## number of frames to pause before locking a piece into the playfield
var lock_delay: int

## number of frames to pause after locking a piece, when the player can lock cancel and squish
var post_lock_delay: int

## number of frames to pause when clearing a line
var line_clear_delay: int

## number of frames to pause when making a box
var box_delay: int

func _init(init_id: String, init_gravity: int, init_appearance_delay: int, init_line_appearance_delay: int,
		init_post_lock_delay: int, init_delayed_auto_shift_delay: int, init_lock_delay: int,
		init_line_clear_delay: int, init_box_delay: int):
	id = init_id
	gravity = init_gravity
	appearance_delay = init_appearance_delay
	line_appearance_delay = init_line_appearance_delay
	post_lock_delay = init_post_lock_delay
	delayed_auto_shift_delay = init_delayed_auto_shift_delay
	lock_delay = init_lock_delay
	line_clear_delay = init_line_clear_delay
	box_delay = init_box_delay


## number of frames to spend clearing the entire playfield during after a top out
func playfield_clear_delay() -> int:
	return PieceSpeeds.current_speed.appearance_delay + PieceSpeeds.current_speed.lock_delay
