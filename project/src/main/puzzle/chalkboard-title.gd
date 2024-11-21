extends Label
## UI component showing the level title.

var _max_width: float

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")
	
	_max_width = rect_size.x
	
	_refresh_text()


func _refresh_text() -> void:
	if CurrentLevel.is_tutorial() and CurrentLevel.settings.other.start_level:
		# For tutorials, the first part defines a name, and later parts don't. It's nice to have tutorials start and
		# end with the tutorial title on the chalkboard, so we preserve the existing title for later tutorial parts.
		return
	
	var name_to_show := tr(CurrentLevel.settings.name)
	
	# truncate long level names to something like "Lorum ipsum dol..."
	var font: DynamicFont = get_theme_default_font()
	if font.get_string_size("“%s”" % [name_to_show]).x > _max_width:
		name_to_show = name_to_show.substr(0, name_to_show.length() - 3).strip_edges()
		while name_to_show and font.get_string_size("“%s...”" % [name_to_show]).x > _max_width:
			name_to_show = name_to_show.substr(0, name_to_show.length() - 1).strip_edges()
		name_to_show += "..."
	
	text = "“%s”" % [name_to_show]


func _on_Level_settings_changed() -> void:
	_refresh_text()


func _on_PuzzleState_game_prepared() -> void:
	_refresh_text()
