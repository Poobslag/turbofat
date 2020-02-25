"""
Stores data about the different 'speed levels' such as how fast pieces should drop, how long it takes them to lock
into the playfield, and how long to pause when clearing lines.

Much of this speed data was derived from wikis for other piece-dropping games which have the concept of a 'hold piece'
so it's likely it will change over time to become more lenient.
"""
extends Node

const G = 256

var all_speeds = [
	# Level 1: Beginner
	PieceSpeed.new(   4, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new(   6, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new(  10, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new(  16, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new(  24, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new(  32, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new(  48, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new(  64, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new(  96, 20, 20,  7, 16, 30, 40),
	# Level 10: 0.5 G
	PieceSpeed.new( 128, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new( 152, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new( 176, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new( 200, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new( 224, 20, 20,  7, 16, 30, 40),
	# Level 15: 1 G
	PieceSpeed.new( 1*G, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new( 2*G, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new( 3*G, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new( 4*G, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new( 5*G, 20, 20,  7, 16, 30, 40),
	# Speed 20: 20G
	PieceSpeed.new(20*G, 20, 20,  7, 16, 30, 40),
	PieceSpeed.new(20*G, 20, 20,  7, 10, 30, 25),
	PieceSpeed.new(20*G, 20, 12,  7, 10, 30, 16),
	PieceSpeed.new(20*G, 12,  8,  7, 10, 30, 10),
	PieceSpeed.new(20*G,  8,  4,  7, 10, 30,  8),
	# Speed 25: Likely impossible
	PieceSpeed.new(20*G,  8,  4,  5,  8, 24,  6),
	PieceSpeed.new(20*G,  8,  4,  5,  8, 20,  6),
	PieceSpeed.new(20*G,  8,  3,  5,  8, 18,  5),
	PieceSpeed.new(20*G,  8,  3,  5,  8, 16,  5),
	PieceSpeed.new(20*G,  2,  2,  5,  8, 14,  4),
	PieceSpeed.new(20*G,  2,  2,  5,  6, 12,  4),
	PieceSpeed.new(20*G,  1,  1,  5,  6, 10,  3),
	PieceSpeed.new(20*G,  1,  1,  5,  6,  8,  3),
]

"""
Stores data about a specific 'speed levels' such as how fast pieces should drop, how long it takes them to lock into
the playfield, and how long to pause when clearing lines.
"""
class PieceSpeed:
	# how fast pieces should drop, as a fraction of 256. 32 = once every 8 frames, 512 = twice a frame
	var gravity
	
	# number of frames to pause before a new piece appears
	var appearance_delay
	
	# number of frames to pause before a new piece appears, after clearing a line/making a box
	var line_appearance_delay
	
	# number of frames the player has to hold left/right before the piece whooshes over
	var delayed_auto_shift_delay
	
	# number of frames to pause before locking a piece into the playfield
	var lock_delay
	
	# number of frames to pause after locking a piece into the playfield
	var post_lock_delay
	
	# number of frames to pause when clearing a line
	var line_clear_delay
	
	func _init(init_gravity, init_appearance_delay, init_line_appearance_delay, init_post_lock_delay, \
			init_delayed_auto_shift_delay, init_lock_delay, init_line_clear_delay):
		gravity = init_gravity
		appearance_delay = init_appearance_delay
		line_appearance_delay = init_line_appearance_delay
		post_lock_delay = init_post_lock_delay
		delayed_auto_shift_delay = init_delayed_auto_shift_delay
		lock_delay = init_lock_delay
		line_clear_delay = init_line_clear_delay
