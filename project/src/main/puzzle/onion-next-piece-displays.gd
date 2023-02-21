extends Control
## Displays upcoming pieces to the player during night mode and manages the next piece displays.
##
## These piece displays are synchronized with daytime piece displays, and rendered over them.

## The path to the daytime next piece displays to synchronize with.
export (NodePath) var next_piece_displays_path: NodePath

export (PackedScene) var OnionPieceDisplayScene

## array of OnionNextPieceDisplays which are shown to the player
var _onion_piece_displays := []

## next piece displays to synchronize with
onready var _next_piece_displays: NextPieceDisplays = get_node(next_piece_displays_path)

func _ready() -> void:
	Pauser.connect("paused_changed", self, "_on_Pauser_paused_changed")
	for i in range(NextPieceDisplays.DISPLAY_COUNT):
		_add_display(i)


func _process(_delta: float) -> void:
	_refresh_displays()


func _refresh_displays() -> void:
	for display in _onion_piece_displays:
		_refresh_display(display)


func _refresh_display(display: OnionPieceDisplay) -> void:
	display.visible = display.source_display.visible


## Adds a new next piece display.
func _add_display(piece_index: int) -> void:
	var new_display: OnionPieceDisplay = OnionPieceDisplayScene.instance()
	new_display.initialize(_next_piece_displays.get_display(piece_index))
	new_display.scale = new_display.source_display.scale
	new_display.position = new_display.source_display.position
	_refresh_display(new_display)
	add_child(new_display)
	_onion_piece_displays.append(new_display)


## When the player pauses, we hide the playfield so they can't cheat.
func _on_Pauser_paused_changed(value: bool) -> void:
	for display in _onion_piece_displays:
		display.visible = not value
