extends Node2D
## Launches and stores the puzzle pieces which appear on the loading screen.

export (NodePath) var orb_path: NodePath
export (NodePath) var progress_bar_path: NodePath
export (PackedScene) var piece_scene: PackedScene

onready var _orb: LoadingOrb = get_node(orb_path)
onready var _progress_bar: LoadingProgressBar = get_node(progress_bar_path)

func _ready() -> void:
	_orb.connect("frame_changed", self, "_on_Orb_frame_changed")


## When the orb advances to the next frame, we launch a puzzle piece.
func _on_Orb_frame_changed() -> void:
	var piece := piece_scene.instance()
	piece.initialize(_orb, _progress_bar)
	add_child(piece)
