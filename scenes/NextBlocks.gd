"""
Contains logic for displaying upcoming blocks to the player, organizing and maintaining all of the 'next block
displays'.
"""
extends Node2D

export (PackedScene) var NextBlockDisplay
onready var BlockTypes = preload("res://scenes/BlockTypes.gd").new()

# Queue of upcoming randomized blocks. The first few blocks are displayed to the player
var next_blocks = []

# The "next block displays" which are shown to the user
var next_block_displays = []

func _ready():
	# Ensure blocks are random
	randomize()
	fill_queue()
	
	# The main "next block display" is full size
	add_display(0)
	
	# There are many other smaller displays to the size
	add_display(1,  96,  0, 0.5)
	add_display(2, 164,  0, 0.5)
	add_display(3, 180, 64, 0.5)
	add_display(4, 180, 128, 0.5)
	add_display(5, 180, 192, 0.5)

"""
Hides all next block displays. We can't let the player see the upcoming blocks before the game starts.
"""
func hide_blocks():
	for next_block_display in next_block_displays:
		next_block_display.hide()

"""
Starts a new game, randomizing the blocks and filling the block queues.
"""
func start_game():
	next_blocks.clear()
	fill_queue()
	
	for next_block_display in next_block_displays:
		next_block_display.show()

"""
Adds a new 'next block display'.
"""
func add_display(block_index, x = 0, y = 0, scale = 1):
	var new_display = NextBlockDisplay.instance()
	new_display.block_index = block_index
	new_display.scale = Vector2(scale, scale)
	new_display.position = Vector2(x + (48 - 48 * scale), y + (48 - 48 * scale))
	add_child(new_display)
	next_block_displays.append(new_display)

"""
Pops the next block off the queue.
"""
func pop_block_type():
	var next_block_type = next_blocks.pop_front()
	fill_queue()
	return next_block_type

"""
This method fills the queue of upcoming blocks with newly randomized blocks, following a specific algorithm.

During the game, the random algorithm works as follows: All 8 blocks are randomly thrown into a bag with 1 random
block. They’re shuffled fairly, but you’re guaranteed to never pull the same block twice-in-a-row. This makes it so
that you're always able to make four simple 3x3 boxes, but sometimes the extra block is a pain in the ass. This
prevents the game from being too simple.

Initially, the random algorithm works a little differently: The game comes up with the five blocks necessary to make a
small and large box and shuffles them. This undermines the simple strategy of starting every game by making 4 3x3
boxes.
"""
func fill_queue():
	if next_blocks.empty():
		# calculate five blocks which can make a 3x3 and either a 3x4 or 3x5
		var all_threes = [
			[BlockTypes.block_j, BlockTypes.block_p],
			[BlockTypes.block_l, BlockTypes.block_q],
			[BlockTypes.block_o, BlockTypes.block_v],
			[BlockTypes.block_t, BlockTypes.block_u]
		]
		next_blocks += all_threes[randi() % all_threes.size()]
		if (randf() > 0.5):
			var all_quads = [
				[BlockTypes.block_j, BlockTypes.block_t, BlockTypes.block_t],
				[BlockTypes.block_l, BlockTypes.block_t, BlockTypes.block_t],
				[BlockTypes.block_j, BlockTypes.block_j, BlockTypes.block_o],
				[BlockTypes.block_l, BlockTypes.block_l, BlockTypes.block_o],
				[BlockTypes.block_j, BlockTypes.block_l, BlockTypes.block_o]
			]
			next_blocks += all_quads[randi() % all_quads.size()]
		else:
			var all_pentos = [
				[BlockTypes.block_p, BlockTypes.block_u, BlockTypes.block_v],
				[BlockTypes.block_q, BlockTypes.block_u, BlockTypes.block_v],
				[BlockTypes.block_p, BlockTypes.block_q, BlockTypes.block_v]
			]
			next_blocks += all_pentos[randi() % all_pentos.size()]
		
		# shuffle the five blocks until the same block doesn't appear twice-in-a-row
		for mercy in range (0, 1000):
			next_blocks.shuffle()
			var no_touching_blocks = true
			for from_index in range(0, next_blocks.size() - 1):
				if next_blocks[from_index] == next_blocks[from_index + 1]:
					no_touching_blocks = false
			if no_touching_blocks:
				break
	
	while next_blocks.size() < 50:
		# fill a bag with one of each block and one extra; draw them out in a random order, ensuring we never see two
		# of the same block in a row
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