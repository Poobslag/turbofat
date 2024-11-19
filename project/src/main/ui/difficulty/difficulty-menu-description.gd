extends Label
## Shows a description of the currently active or currently selected difficulty.

## key: (int) Enum from DifficultyData.Speed
## value: (String) description
var descriptions_by_speed := {
	DifficultyData.Speed.FASTESTEST: tr("Faster than intended - who needs strategy? Get down with the quickness!"),
	DifficultyData.Speed.FASTEST: tr("Faster than intended - who needs strategy? Get down with the quickness!"),
	DifficultyData.Speed.FASTER: tr("Faster than intended - who needs strategy? Get down with the quickness!"),
	DifficultyData.Speed.FAST: tr("Faster than intended - who needs strategy? Get down with the quickness!"),
	DifficultyData.Speed.DEFAULT: tr("The heart of Turbo Fat - balancing quick moves with clever strategy."),
	DifficultyData.Speed.SLOW: tr("Slower pieces, shorter levels - chill vibes only, please."),
	DifficultyData.Speed.SLOWER: tr("Slower pieces, shorter levels - chill vibes only, please."),
	DifficultyData.Speed.SLOWEST: tr("Slower pieces, shorter levels - chill vibes only, please."),
	DifficultyData.Speed.SLOWESTEST: tr("Zero gravity, super-short levels - pure tranquility at your own pace."),
}

func _ready() -> void:
	for difficulty_button in get_tree().get_nodes_in_group("difficulty_buttons"):
		difficulty_button.connect("focus_entered", self, "_on_DifficultyButton_focus_entered")
		difficulty_button.connect("focus_exited", self, "_on_DifficultyButton_focus_exited")
	PlayerData.difficulty.connect("speed_changed", self, "_on_DifficultyData_speed_changed")


func _refresh() -> void:
	if not is_inside_tree():
		return
	
	# show a description for the currently chosen difficulty
	var speed: int = PlayerData.difficulty.speed
	
	# the focused difficulty overrides the currently chosen difficulty, so that the player can browse
	if get_focus_owner() is DifficultyButton:
		speed = get_focus_owner().speed
	
	text = descriptions_by_speed.get(speed)


func _on_DifficultyData_speed_changed(_value: int) -> void:
	_refresh()


func _on_DifficultyButton_focus_entered() -> void:
	_refresh()


func _on_DifficultyButton_focus_exited() -> void:
	_refresh()
