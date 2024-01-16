extends Node2D
## Draws confetti particles falling through the air during the ending cutscene.

onready var _particles := $Particles2D

func _ready() -> void:
	if Global.get_overworld_ui():
		Global.get_overworld_ui().connect("chat_event_meta_played", self, "_on_OverworldUi_chat_event_meta_played")


## Listen for 'confetti' chat events and enable confetti.
func _on_OverworldUi_chat_event_meta_played(meta_item: String) -> void:
	match meta_item:
		"confetti":
			_particles.emitting = true
