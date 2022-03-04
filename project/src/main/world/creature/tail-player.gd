extends AnimationPlayer
## Animates a creature's tail.
##
## Specifically, this animation player ensures the tail is always moving if nothing else is animating it.

export (NodePath) var movement_player_path: NodePath
export (NodePath) var creature_visuals_path: NodePath

onready var _creature_visuals: CreatureVisuals = get_node(creature_visuals_path)
onready var _movement_player: AnimationPlayer = get_node(movement_player_path)

func _ready() -> void:
	_movement_player.connect("animation_started", self, "_on_MovementPlayer_animation_started")
	_creature_visuals.connect("orientation_changed", self, "_on_CreatureVisuals_orientation_changed")


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		# avoid playing animations in editor
		return
	
	if not is_playing() and not _movement_player.current_animation.begins_with("sprint"):
		_play_tail_ambient_animation()


## Plays an appropriate tail ambient animation for the creature's orientation and movement state.
func _play_tail_ambient_animation() -> void:
	var tail_ambient_animation: String
	if _creature_visuals.orientation in [Creatures.SOUTHWEST, Creatures.SOUTHEAST]:
		tail_ambient_animation = "ambient-se"
	else:
		tail_ambient_animation = "ambient-nw"
	play(tail_ambient_animation)


func _on_MovementPlayer_animation_started(anim_name: String) -> void:
	if anim_name.begins_with("sprint"):
		stop()


func _on_CreatureVisuals_orientation_changed(_old_orientation: int, _new_orientation: int) -> void:
	if is_playing():
		_play_tail_ambient_animation()
