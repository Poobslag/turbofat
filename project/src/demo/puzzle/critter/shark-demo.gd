extends Node
## Demo which shows off the shark puzzle critter.
##
## Keys:
## [0]: Disappear
## [1]: Wait, with a '...' speech bubble
## [2]: Dance animation
## [3]: Dance animation with a '...' speech bubble
## [4]: Eating animation, which also triggers fed animation afterwards
## [5]: Fed animation
## [6]: Squished animation
## [7]: Disappear
##
## [Q,W,E]: Change the shark size to small/medium/large
## [A,S,D,F,G]: Change the shape of the eaten piece
## [H,J,K,L,;]: Change the color of the eaten piece
## [Z,X,C]: Change the eating duration

const EATEN_PIECE_SHAPES := [
	[], # null piece
	[Vector2(0, 0)], # single piece
	[Vector2(0, 0), Vector2(0, -1), Vector2(0, -2)], # tall piece
	[Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)], # wide piece
	[Vector2(-1, 0), Vector2(0, 0), Vector2(0, -1), Vector2(1, -1), Vector2(1, -2)], # crazy piece
]

@onready var _shark := $Shark

func _ready() -> void:
	_shark.set_eaten_cell(Vector2.ZERO)


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_0: _shark.state = Shark.NONE
		KEY_1: _shark.state = Shark.WAITING
		KEY_2: _shark.state = Shark.DANCING
		KEY_3: _shark.state = Shark.DANCING_END
		KEY_4: _shark.state = Shark.EATING
		KEY_5: _shark.state = Shark.FED
		KEY_6: _shark.state = Shark.SQUISHED
		KEY_7: _shark.state = Shark.NONE
		
		KEY_Q: _shark.shark_size = SharkConfig.SharkSize.SMALL
		KEY_W: _shark.shark_size = SharkConfig.SharkSize.MEDIUM
		KEY_E: _shark.shark_size = SharkConfig.SharkSize.LARGE
		
		KEY_A: set_eaten_piece_shape_index(0)
		KEY_S: set_eaten_piece_shape_index(1)
		KEY_D: set_eaten_piece_shape_index(2)
		KEY_F: set_eaten_piece_shape_index(3)
		KEY_G: set_eaten_piece_shape_index(4)
		
		KEY_H: _shark.set_eaten_color(0, 0)
		KEY_J: _shark.set_eaten_color(0, 1)
		KEY_K: _shark.set_eaten_color(0, 2)
		KEY_L: _shark.set_eaten_color(0, 3)
		KEY_SEMICOLON: _shark.set_eaten_color(1, 4)
		
		KEY_Z: _shark.set_eat_duration(0.1)
		KEY_X: _shark.set_eat_duration(0.5)
		KEY_C: _shark.set_eat_duration(1.5)


func set_eaten_piece_shape_index(new_eaten_piece_shape_index: int) -> void:
	_shark.clear_eaten_cells()
	for cell in EATEN_PIECE_SHAPES[new_eaten_piece_shape_index]:
		_shark.set_eaten_cell(cell)
