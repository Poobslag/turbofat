extends Control
## Displays a large "Goal!" message in the center of the progress board when the player reaches the goal.

onready var _puzzle_message := $PuzzleMessage

func _on_Player_travelling_finished() -> void:
	if PlayerData.career.is_boss_level():
		_puzzle_message.show_message(PuzzleMessage.GOOD, tr("Goal!"))
