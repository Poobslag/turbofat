tool
class_name ConfettiCannon
extends OverworldObstacle
## A confetti cannon which fires confetti during the ending cutscene.

## Directions a confetti cannon can face
enum Orientation {
	SOUTHEAST,
	SOUTHWEST,
	NORTHWEST,
	NORTHEAST,
}

## key: (int) Enum from Orientation
## value: (Vector2) Blast sprite offset for an orientation
const BLAST_OFFSET_BY_ORIENTATION := {
	Orientation.SOUTHEAST: Vector2(7, -287),
	Orientation.SOUTHWEST: Vector2(-381, -287),
	Orientation.NORTHWEST: Vector2(-374, -287),
	Orientation.NORTHEAST: Vector2(0, -287),
}

const SOUTHEAST := Orientation.SOUTHEAST
const SOUTHWEST := Orientation.SOUTHWEST
const NORTHWEST := Orientation.NORTHWEST
const NORTHEAST := Orientation.NORTHEAST

export (Orientation) var orientation: int setget set_orientation

onready var _animation_player := $AnimationPlayer
onready var _blast := $Visuals/Blast
onready var _cannon := $Visuals/Cannon

func _ready() -> void:
	if Global.get_overworld_ui():
		Global.get_overworld_ui().connect("chat_event_meta_played", self, "_on_OverworldUi_chat_event_meta_played")
	
	_refresh_orientation()


func set_orientation(new_orientation: int) -> void:
	orientation = new_orientation
	_refresh_orientation()


## Animates the cannon firing.
func fire() -> void:
	_animation_player.play("fire")


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_animation_player = $AnimationPlayer
	_blast = $Visuals/Blast
	_cannon = $Visuals/Cannon


## Updates the cannon's visuals based on its orientation.
func _refresh_orientation() -> void:
	if not is_inside_tree():
		return
	
	if Engine.editor_hint:
		if not _cannon:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	_cannon.frame = 0 if orientation in [SOUTHEAST, SOUTHWEST] else 1
	_cannon.flip_h = true if orientation in [SOUTHWEST, NORTHEAST] else false
	_blast.offset = BLAST_OFFSET_BY_ORIENTATION[orientation]
	_blast.flip_h = true if orientation in [SOUTHWEST, NORTHWEST] else false
	_blast.z_index = -1 if orientation in [NORTHWEST, NORTHEAST] else 0


## Listen for 'confetti' chat events and fire confetti.
func _on_OverworldUi_chat_event_meta_played(meta_item: String) -> void:
	match meta_item:
		"confetti":
			fire()
