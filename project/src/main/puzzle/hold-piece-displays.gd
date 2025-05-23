class_name HoldPieceDisplays
extends Control
## Displays the hold piece to the player and manages the hold piece display.
##
## There is only one hold piece display at a time. This code is named and organized how it is for symmetry with the
## Next Piece Display functionality, since they have a lot in common.

export (NodePath) var piece_queue_path: NodePath

export (PackedScene) var HoldPieceDisplayScene

var display: HoldPieceDisplay

## Contains visual elements for the hold piece. Only visible if the hold piece cheat is enabled.
onready var holder := $Holder

onready var _piece_queue: PieceQueue = get_node(piece_queue_path)

func _ready() -> void:
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	Pauser.connect("paused_changed", self, "_on_Pauser_paused_changed")
	PlayerData.difficulty.connect("hold_piece_changed", self, "_on_DifficultyData_hold_piece_changed")
	
	display = HoldPieceDisplayScene.instance()
	display.initialize(_piece_queue)
	display.scale = Vector2(0.5, 0.5)
	display.position = Vector2(11, 14)
	display.hide()
	holder.add_child(display)
	
	_refresh()


func _refresh() -> void:
	holder.visible = CurrentLevel.is_hold_piece_cheat_enabled()


## Gets ready for a new game, randomizing the pieces and filling the piece queues.
func _on_PuzzleState_game_prepared() -> void:
	display.show()


## When the player pauses, we hide the hold piece so they can't cheat.
func _on_Pauser_paused_changed(value: bool) -> void:
	display.visible = not value


func _on_DifficultyData_hold_piece_changed(_value: bool) -> void:
	_refresh()


## When the player advances to a later section in a tutorial, the hold piece might become enabled.
func _on_Level_settings_changed() -> void:
	_refresh()
