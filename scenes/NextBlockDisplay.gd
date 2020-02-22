"""
Contains logic for a single 'next block display'. A single display might only display the piece which is coming up 3
pieces from now. Several displays are shown at once.
"""
extends Node2D

onready var NextBlocks = get_node("..")

# currently displayed block type
var displayed_block

# how far into the future this display should look; 0 = show the next block, 10 = show the 11th block
var block_index = 0

func _process(delta):
	if NextBlocks != null && NextBlocks.next_blocks.size() > block_index:
		var next_block = NextBlocks.next_blocks[block_index]
		if next_block != displayed_block:
			# update the tilemap with the new block type
			$TileMap.clear()
			for i in range(0, next_block.pos_arr[0].size()):
				var cubit_pos = next_block.pos_arr[0][i]
				var cubit_color = next_block.color_arr[0][i]
				$TileMap.set_cell(cubit_pos.x, cubit_pos.y, \
						0, false, false, false, cubit_color)
			displayed_block = next_block
