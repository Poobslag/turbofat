extends Control
## Displays the hold piece to the player during night mode and manages the hold piece display.
##
## These piece displays are synchronized with daytime piece displays, and rendered over them.

## The path to the daytime hold piece displays to synchronize with.
export (NodePath) var hold_piece_displays_path: NodePath

export (PackedScene) var NightPieceDisplayScene

var _display: NightPieceDisplay

## daytime hold piece displays to synchronize with
onready var _hold_piece_displays: HoldPieceDisplays = get_node(hold_piece_displays_path)

## Contains visual elements for the hold piece. Only visible if the hold piece cheat is enabled.
onready var holder := $Holder

func _ready() -> void:
	Pauser.connect("paused_changed", self, "_on_Pauser_paused_changed")
	
	_display = NightPieceDisplayScene.instance()
	_display.initialize(_hold_piece_displays.display)
	_display.scale = _display.source_display.scale
	_display.position = _display.source_display.position
	_refresh_display()
	holder.add_child(_display)


func _process(_delta: float) -> void:
	holder.visible = _hold_piece_displays.holder.visible
	_refresh_display()


func _refresh_display() -> void:
	_display.visible = _display.source_display.visible


## When the player pauses, we hide the playfield so they can't cheat.
func _on_Pauser_paused_changed(value: bool) -> void:
	_display.visible = not value
