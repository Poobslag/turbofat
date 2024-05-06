extends Particles2D
## Draws confetti particles on the floor during the ending cutscene.

onready var _timer := $Timer

func _ready() -> void:
	if Global.get_overworld_ui():
		Global.get_overworld_ui().connect("chat_event_meta_played", self, "_on_OverworldUi_chat_event_meta_played")


## Listen for 'confetti' chat events and enable confetti.
##
## We spawn floor confetti particles after a delay, because it takes time for the confetti to reach the floor.
func _on_OverworldUi_chat_event_meta_played(meta_item: String) -> void:
	match meta_item:
		"confetti":
			_timer.start()


func _on_Timer_timeout() -> void:
	emitting = true
