#tool #uncomment to view creature in editor
extends AnimationPlayer
## Moves the creature's body parts around as they become fatter.
##
## While this is an AnimationPlayer, the animation is only used to rearrange their body parts. It shouldn't ever be
## played as an animation.

@export var creature_visuals_path: NodePath: set = set_creature_visuals_path

var _creature_visuals: CreatureVisuals

func _ready() -> void:
	_refresh_creature_visuals_path()


func set_creature_visuals_path(new_creature_visuals_path: NodePath) -> void:
	creature_visuals_path = new_creature_visuals_path
	_refresh_creature_visuals_path()


func _refresh_creature_visuals_path() -> void:
	if not (is_inside_tree() and not creature_visuals_path.is_empty()):
		return
	
	if _creature_visuals:
		_creature_visuals.visual_fatness_changed.disconnect(_on_CreatureVisuals_visual_fatness_changed)
		_creature_visuals.orientation_changed.disconnect(_on_CreatureVisuals_orientation_changed)
		_creature_visuals.movement_mode_changed.disconnect(_on_CreatureVisuals_movement_mode_changed)
	
	root_node = creature_visuals_path
	_creature_visuals = get_node(creature_visuals_path)
	
	_creature_visuals.visual_fatness_changed.connect(_on_CreatureVisuals_visual_fatness_changed)
	_creature_visuals.orientation_changed.connect(_on_CreatureVisuals_orientation_changed)
	_creature_visuals.movement_mode_changed.connect(_on_CreatureVisuals_movement_mode_changed)


func _refresh_sprite_positions() -> void:
	if not is_inside_tree():
		return
	
	play("fat-se" if _creature_visuals.orientation in [Creatures.SOUTHWEST, Creatures.SOUTHEAST] else "fat-nw")
	advance(_creature_visuals.visual_fatness)
	stop()
	_creature_visuals.emit_signal("head_moved")


func _on_CreatureVisuals_visual_fatness_changed() -> void:
	_refresh_sprite_positions()


func _on_CreatureVisuals_orientation_changed(_old_orientation: Creatures.Orientation, _new_orientation: Creatures.Orientation) -> void:
	_refresh_sprite_positions()


func _on_CreatureVisuals_movement_mode_changed(_old_mode: Creatures.MovementMode, new_mode: Creatures.MovementMode) -> void:
	if new_mode != Creatures.SPRINT:
		_refresh_sprite_positions()
