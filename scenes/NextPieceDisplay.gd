extends Node2D

onready var NextPieces = get_node("..")
var displayed_block
var block_index = 0

func _process(delta):
	if NextPieces != null && NextPieces.next_blocks.size() > block_index:
		var next_block = NextPieces.next_blocks[block_index]
		if next_block != displayed_block:
			$TileMap.clear()
			for i in range(0, next_block.pos_arr[0].size()):
				var cubit_pos = next_block.pos_arr[0][i]
				var cubit_color = next_block.color_arr[0][i]
				$TileMap.set_cell(cubit_pos.x, cubit_pos.y, \
						0, false, false, false, cubit_color)
			displayed_block = next_block
