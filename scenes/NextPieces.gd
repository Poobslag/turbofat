extends Node2D

export (PackedScene) var NextPieceDisplay
onready var BlockTypes = preload("res://scenes/BlockTypes.gd").new()

var next_blocks = []
var next_piece_displays = []

func _ready():
	# ensure pieces are random
	randomize()
	fill_queue()
	
	add_display(0)
	add_display(1,  96,  0, 0.5)
	add_display(2, 164,  0, 0.5)
	add_display(3, 180, 64, 0.5)
	add_display(4, 180, 128, 0.5)
	add_display(5, 180, 192, 0.5)

func hide_pieces():
	for next_piece_display in next_piece_displays:
		next_piece_display.hide()

func start_game():
	next_blocks.clear()
	fill_queue()
	
	for next_piece_display in next_piece_displays:
		next_piece_display.show()

func add_display(block_index, x = 0, y = 0, scale = 1):
	var new_display = NextPieceDisplay.instance()
	new_display.block_index = block_index
	new_display.scale = Vector2(scale, scale)
	new_display.position = Vector2(x + (48 - 48 * scale), y + (48 - 48 * scale))
	add_child(new_display)
	next_piece_displays.append(new_display)

func pop_block_type():
	var next_block_type = next_blocks.pop_front()
	fill_queue()
	return next_block_type

func fill_queue():
	if next_blocks.empty():
		# take the 5 blocks necessary for a 3x3 and either a 3x4 or 3x5; shuffle them up
		var all_threes = [
			[BlockTypes.block_j, BlockTypes.block_p],
			[BlockTypes.block_l, BlockTypes.block_q],
			[BlockTypes.block_o, BlockTypes.block_v],
			[BlockTypes.block_t, BlockTypes.block_u]
		]
		var all_quads = [
			[BlockTypes.block_j, BlockTypes.block_t, BlockTypes.block_t],
			[BlockTypes.block_l, BlockTypes.block_t, BlockTypes.block_t],
			[BlockTypes.block_j, BlockTypes.block_j, BlockTypes.block_o],
			[BlockTypes.block_l, BlockTypes.block_l, BlockTypes.block_o],
			[BlockTypes.block_j, BlockTypes.block_l, BlockTypes.block_o]
		]
		var all_pentos = [
			[BlockTypes.block_p, BlockTypes.block_u, BlockTypes.block_v],
			[BlockTypes.block_q, BlockTypes.block_u, BlockTypes.block_v],
			[BlockTypes.block_p, BlockTypes.block_q, BlockTypes.block_v]
		]
		next_blocks += all_threes[randi() % all_threes.size()]
		if (randf() > 0.5):
			next_blocks += all_quads[randi() % all_quads.size()]
		else:
			next_blocks += all_pentos[randi() % all_pentos.size()]
		
		for mercy in range (0, 1000):
			next_blocks.shuffle()
			var no_touching_pieces = true
			for from_index in range(0, next_blocks.size() - 1):
				if next_blocks[from_index] == next_blocks[from_index + 1]:
					no_touching_pieces = false
			if no_touching_pieces:
				break
	
	while next_blocks.size() < 50:
		# fill a bag with one of each piece and one extra; draw them out in a random order, ensuring we never see two
		# of the same piece in a row
		var new_blocks = BlockTypes.all_types.duplicate()
		new_blocks.shuffle()
		
		# avoid having two of the same block consecutively
		if new_blocks[0] == next_blocks.back():
			new_blocks.pop_front()
			new_blocks.insert(int(rand_range(1, new_blocks.size() + 1)), next_blocks.back())
		
		# add one extra block
		var new_block_index = int(rand_range(1, new_blocks.size() + 1))
		var extra_block_types = BlockTypes.all_types.duplicate()
		extra_block_types.remove(extra_block_types.rfind(new_blocks[new_block_index - 1]))
		if (new_block_index < new_blocks.size()):
			extra_block_types.remove(extra_block_types.rfind(new_blocks[new_block_index]))
		new_blocks.insert(new_block_index, extra_block_types[randi() % extra_block_types.size()])
		
		next_blocks += new_blocks