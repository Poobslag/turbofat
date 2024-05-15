extends Node
## Demonstrates the shark puzzle critter.
##
## Keys:
## 	[0]: Disappear
## 	[1]: Wait, with a '...' speech bubble
## 	[2]: Dance animation
## 	[3]: Dance animation with a '...' speech bubble
## 	[4]: Eating animation, which also triggers fed animation afterwards
## 	[5]: Fed animation
## 	[6]: Squished animation
## 	[7]: Disappear
##
## 	[S]: Change the shark size to small/medium/large
## 	[H]: Change the shape of the eaten piece to empty/small/tall/wide/crazy
## 	[C]: Change the color of the eaten piece to brown/pink/bread/white/cake
## 	[D]: Change the eating duration to short/medium/long

const EATEN_COLORS := [
	[0, 0], [0, 1], [0, 2], [0, 3], [1, 4]
]

const EATEN_PIECE_SHAPES := [
	[], # null piece
	[Vector2(0, 0)], # single piece
	[Vector2(0, 0), Vector2(0, -1), Vector2(0, -2)], # tall piece
	[Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)], # wide piece
	[Vector2(-1, 0), Vector2(0, 0), Vector2(0, -1), Vector2(1, -1), Vector2(1, -2)], # crazy piece
]

const EAT_DURATIONS := [
	0.1, 0.5, 1.5
]

var _eaten_color_index := 0
var _eaten_piece_shape_index := 2
var _eat_duration_index := 1

onready var _shark := $Shark

func _ready() -> void:
	_shark.state = Shark.DANCING


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_0: _shark.state = Shark.NONE
		KEY_1: _shark.state = Shark.WAITING
		KEY_2: _shark.state = Shark.DANCING
		KEY_3: _shark.state = Shark.DANCING_END
		KEY_4: _eat()
		KEY_5: _shark.state = Shark.FED
		KEY_6: _shark.state = Shark.SQUISHED
		KEY_7: _shark.state = Shark.NONE
		
		KEY_S:
			_shark.shark_size = (_shark.shark_size + 1) % SharkConfig.SharkSize.size()
		
		KEY_H:
			_eaten_piece_shape_index = (_eaten_piece_shape_index + 1) % EATEN_PIECE_SHAPES.size()
			_eat()
		
		KEY_C:
			_eaten_color_index = (_eaten_color_index + 1) % EATEN_COLORS.size()
			_eat()
		
		KEY_D:
			_eat_duration_index = (_eat_duration_index + 1) % EAT_DURATIONS.size()
			_eat()


func _eat() -> void:
	_shark.clear_eaten_cells()
	for cell in EATEN_PIECE_SHAPES[_eaten_piece_shape_index]:
		_shark.set_eaten_cell(cell)
	_shark.set_eat_duration(EAT_DURATIONS[_eat_duration_index])
	_shark.set_eaten_color(EATEN_COLORS[_eaten_color_index][0], EATEN_COLORS[_eaten_color_index][1])
	_shark.state = Shark.EATING
