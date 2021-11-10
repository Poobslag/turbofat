extends VBoxContainer
## A panel shown on the main menu containing developer tools.
##
## The panel only appears in debug builds of the game.

func _ready() -> void:
	# only show debug panel for debug builds
	visible = OS.is_debug_build()


func _on_StressTest_pressed() -> void:
	SceneTransition.push_trail("res://src/main/ui/CreatureStressTest.tscn")
