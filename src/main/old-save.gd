class_name OldSave
"""
Provides backwards compatibility with older save formats.

This class's size will worsen with each change to our save system. Once it gets too large (600 lines or so) we should
consider dropping backwards compatibility for older versions.
"""

# Filename for v0.0517 data. Can be changed for tests
var player_data_filename_0517 := "user://turbofat.save"

class StringTransformer:
	"""
	Applies a series of regex transformations.
	"""
	
	var _regex := RegEx.new()
	var transformed: String
	
	func _init(s: String) -> void:
		transformed = s
	
	"""
	Apply a regex transformation.
	"""
	func sub(pattern: String, replacement: String) -> void:
		_regex.compile(pattern)
		transformed = _regex.sub(transformed, replacement, true)


"""
Returns 'true' if the player has an old save file, but no new save file.

This indicates we should convert their old save file to the new format.
"""
func only_has_old_save() -> bool:
	return has_old_save() and not has_new_save()


"""
Returns 'true' if the player has a save file in the current format.
"""
func has_new_save() -> bool:
	var save_game := File.new()
	var result := save_game.file_exists(PlayerSave.player_data_filename)
	save_game.close()
	return result


"""
Returns 'true' if the player has a save file in an old format.
"""
func has_old_save() -> bool:
	var save_game := File.new()
	var result := save_game.file_exists(player_data_filename_0517)
	save_game.close()
	return result


"""
Converts the player's old save file to the new format.
"""
func transform_old_save() -> void:
	if has_new_save():
		push_error("Won't overwrite new save with old save")
		return
	if not has_old_save():
		push_error("No old save to restore")
		return
	
	# transform 0.0517 data to current format
	var save_json_text := Global.get_file_as_text(player_data_filename_0517)
	var transformer := StringTransformer.new(save_json_text)
	transformer.transformed += "\n{\"type\":\"version\",\"value\":\"15d2\"}"
	transformer.sub("plyr({.*})", "{\"type\":\"player-info\",\"value\":$1},")
	transformer.sub("scenario_name", "key")
	transformer.sub("scen{\"scenario_history\":(\\[.*\\])(.*)}", "{\"type\":\"scenario-history\",\"value\":$1$2},")
	transformer.sub("\"died\":false", "\"top_out_count\":0,\"lost\":false")
	transformer.sub("\"died\":true", "\"top_out_count\":1,\"lost\":true")
	transformer.transformed = "[%s]" % transformer.transformed
	transformer.transformed = JSONBeautifier.beautify_json(transformer.transformed, 1)
	save_json_text = transformer.transformed
	
	Global.write_file(PlayerSave.player_data_filename, save_json_text)
