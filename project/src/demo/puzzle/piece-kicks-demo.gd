extends Node
## Prints piece kick information using GitHub wiki markdown.
##
## Keys:
## 	[1/2/3]: Show spawn positions for the (Left/Center/Right) position
## 	[C/I/J/K/L/P/Q/S/T/U/V/Z]: Show piece kicks for the specified piece

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_C, KEY_K, KEY_V:
			_show_kick_table_and_headers("C, K, V Piece Kicks", PieceTypes.piece_c)
		KEY_I:
			_show_kick_table_and_headers("I Piece Kicks", PieceTypes.piece_i)
		KEY_J, KEY_L, KEY_S, KEY_Z:
			_show_kick_table_and_headers("J, L, S, Z Piece Kicks", PieceTypes.piece_j)
		KEY_O:
			_show_kick_table_and_headers("O Piece Kicks", PieceTypes.piece_o)
		KEY_P:
			_show_kick_table_and_headers("P Piece Kicks", PieceTypes.piece_p)
		KEY_Q:
			_show_kick_table_and_headers("Q Piece Kicks", PieceTypes.piece_q)
		KEY_T:
			_show_kick_table_and_headers("T Piece Kicks", PieceTypes.piece_t)
		KEY_U:
			_show_kick_table_and_headers("U Piece Kicks", PieceTypes.piece_u)
		KEY_1:
			_show_spawn_table_and_headers("Left Spawn Positions", PieceMover.SPAWN_LEFT)
		KEY_2:
			_show_spawn_table_and_headers("Center Spawn Positions", PieceMover.SPAWN_CENTER)
		KEY_3:
			_show_spawn_table_and_headers("Right Spawn Positions", PieceMover.SPAWN_RIGHT)


func _show_spawn_table_and_headers(header: String, spawns: Array) -> void:
	var result := ""
	result += "**%s**\n" % [header]
	result += "\n"
	
	result += _spawn_table(spawns) + "\n"
	result += "\n"
	$TextEdit.text = result


func _spawn_table(spawns: Array) -> String:
	var result := "|"
	
	for i in range(6):
		result += " Spawn %s   |" % [i + 1]
	result += "\n"
	
	result += "|"
	for _i in range(6):
		result += "-----------|"
	result += "\n"
	
	result += "|"
	for spawn_index in range(18):
		if spawn_index < spawns.size():
			result += "`(%2s, %2s)` |" % [int(spawns[spawn_index].x), int(spawns[spawn_index].y)]
		if spawn_index % 6 == 5:
			result += "\n"
			if spawn_index >= spawns.size() - 1:
				break
			else:
				result += "|"
	return result


func _show_kick_table_and_headers(header: String, piece: PieceType) -> void:
	var result := ""
	
	result += "**%s**\n" % [header]
	result += "\n"
	
	result += _kick_table(piece) + "\n"
	result += "\n"
	
	$TextEdit.text = result


func _kick_table(piece: PieceType) -> String:
	var result := ""
	
	var max_tests := 1
	for key in piece.kicks:
		max_tests = max(max_tests, piece.kicks[key].size() + 1)
	
	result += "|           "
	for i in range(max_tests):
		result += "| Test %d     " % [i + 1]
	result += "|\n"
	
	result += "|-----------"
	for _i in range(max_tests):
		result += "|------------"
	result += "|\n"
	
	for key in [1, 10, 12, 21, 23, 32, 30, 3, 02, 20, 13, 31]:
		if not key in piece.kicks:
			continue
		
		var rotation_label := _rotation_label(key)
		result += "| **%s** | `( 0,  0)` " % [rotation_label]
		for kick in piece.kicks[key]:
			var markdown_column := "| `(%2s, %2s)` " % [int(kick.x), int(kick.y)]
			while markdown_column.length() < 13:
				markdown_column += " "
			result += markdown_column
		for _i in range(max_tests - piece.kicks[key].size() - 1):
			result += "|            "
		result += "|\n"
	return result


func _rotation_label(key: int) -> String:
	var rotation_names := ["0", "R", "2", "L"]
	# warning-ignore:integer_division
	var from_orientation := int(key / 10)
	var to_orientation := key % 10
	return "%s → %s" % [rotation_names[from_orientation], rotation_names[to_orientation]]
