extends Label
"""
Shows diagnostics for the player's movement physics. Enabled with the cheat code 'coyote'.
"""

onready var turbo: Turbo = get_parent()

func _process(delta: float) -> void:
	if visible:
		text = ""
		text += "-" if turbo.get_node("CoyoteTimer").is_stopped() else "c"
		text += "-" if turbo.get_node("JumpBuffer").is_stopped() else "b"
		text += "j" if turbo._jumping else "-"
		text += "s" if turbo._slipping else "-"
		text += "f" if turbo._friction else "-"
