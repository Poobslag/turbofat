#tool #uncomment to view creature in editor
extends CreatureCurve
## Shadow drawn below the creature's arm.

## cached NearArm sprite used for calculating shadows
var _near_arm: CreaturePackedSprite

## Disconnects creature visuals listeners specific to arm shadows.
##
## Overrides the superclass's implementation to disconnect additional listeners.
func disconnect_creature_visuals_listeners() -> void:
	super.disconnect_creature_visuals_listeners()
	_near_arm.frame_changed.disconnect(_on_NearArm_frame_changed)


## Connects creature visuals listeners specific to arm shadows.
##
## Overrides the superclass's implementation to connect additional listeners.
func connect_creature_visuals_listeners() -> void:
	super.connect_creature_visuals_listeners()
	_near_arm = creature_visuals.get_node("NearArm")
	_near_arm.frame_changed.connect(_on_NearArm_frame_changed)


## Updates the 'drawn' property based on the arm's current frame.
func refresh_drawn() -> void:
	super.refresh_drawn()
	if _near_arm.frame == 0:
		set_drawn(false)


func _on_NearArm_frame_changed() -> void:
	refresh_drawn()
