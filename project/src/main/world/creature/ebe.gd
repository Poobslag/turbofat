extends Creature
"""
Script which controls a character 'Ebe' on the overworld.

Makes her run back and forth.
"""

export (NodePath) var overworld_ui_path: NodePath

onready var _overworld_ui: OverworldUi = get_node(overworld_ui_path)

func _ready() -> void:
	_overworld_ui.connect("chat_started", self, "_on_OverworldUi_chat_started")
	_overworld_ui.connect("chat_ended", self, "_on_OverworldUi_chat_ended")
	$MoveTimer.connect("timeout", self, "_on_MoveTimer_timeout")


"""
Run back and forth every few seconds.
"""
func _on_MoveTimer_timeout() -> void:
	var move_dir: Vector2
	if not non_iso_walk_direction and randf() < 0.25:
		move_dir = Vector2(-1, -1) if position.y > 250 else Vector2(1, 1)
	set_non_iso_walk_direction(move_dir)


"""
Stop moving when chatting, and prevent further movement.
"""
func _on_OverworldUi_chat_started() -> void:
	if self in _overworld_ui.chatters:
		$MoveTimer.paused = true
		set_non_iso_walk_direction(Vector2.ZERO)
		play_movement_animation("idle")
		orient_toward(ChattableManager.player)


"""
Unpause movement when the current conversation ends.
"""
func _on_OverworldUi_chat_ended() -> void:
	$MoveTimer.paused = false
