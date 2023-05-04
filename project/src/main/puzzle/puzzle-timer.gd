extends Label
## UI component showing how long the player has spent on the current puzzle.

func _ready() -> void:
	PuzzleState.game_prepared.connect(_on_PuzzleState_game_prepared)
	CurrentLevel.changed.connect(_on_Level_settings_changed)
	
	_init_visible()
	_refresh_text()


func _process(_delta: float) -> void:
	_refresh_text()


## Updates the label to be visible/invisible appropriately.
##
## We don't display a timer for timed levels as it would be redundant.
func _init_visible() -> void:
	visible = CurrentLevel.settings.finish_condition.type != Milestone.TIME_OVER
	set_process(visible)


## Updates the label to show the number of seconds the player has spent on the current puzzle.
func _refresh_text() -> void:
	text = StringUtils.format_duration(int(ceil(PuzzleState.level_performance.seconds)))


func _on_PuzzleState_game_prepared() -> void:
	_init_visible()


func _on_Level_settings_changed() -> void:
	_init_visible()
