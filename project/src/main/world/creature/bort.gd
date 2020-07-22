extends Creature
"""
Script which controls a character 'Bort' on the overworld.

Makes him run back and forth.
"""

export (NodePath) var overworld_ui_path: NodePath

onready var _overworld_ui: OverworldUi = get_node(overworld_ui_path)

func _ready() -> void:
	_overworld_ui.connect("chat_started", self, "_on_OverworldUi_chat_started")
	_overworld_ui.connect("chat_ended", self, "_on_OverworldUi_chat_ended")


"""
Run back and forth every few seconds.
"""
func _on_MoveTimer_timeout() -> void:
	var move_dir: Vector2
	if not non_iso_walk_direction and randf() < 0.20:
		move_dir = Vector2(-1, -1) if position.y > 340 else Vector2(1, 1)
	set_non_iso_walk_direction(move_dir)


"""
Stop moving when chatting, and prevent further movement.
"""
func _on_OverworldUi_chat_started() -> void:
	if self in _overworld_ui.chatters:
		$MoveTimer.paused = true
		set_non_iso_walk_direction(Vector2.ZERO)
		play_movement_animation("idle")
		orient_toward(ChattableManager.spira)


"""
Unpause movement when the current conversation ends.
"""
func _on_OverworldUi_chat_ended() -> void:
	$MoveTimer.paused = false
