class_name HoldPieceDisplays
extends Control
## Displays the hold piece to the player and manages the hold piece display.
##
## There is only one hold piece display at a time. This code is named and organized how it is for symmetry with the
## Next Piece Display functionality, since they have a lot in common.

@export var piece_queue_path: NodePath
@export var HoldPieceDisplayScene

var display: HoldPieceDisplay

@onready var _piece_queue: PieceQueue = get_node(piece_queue_path)

## Contains visual elements for the hold piece. Only visible if the hold piece cheat is enabled.
@onready var holder := $Holder

func _ready() -> void:
	CurrentLevel.changed.connect(_on_Level_settings_changed)
	PuzzleState.game_prepared.connect(_on_PuzzleState_game_prepared)
	Pauser.paused_changed.connect(_on_Pauser_paused_changed)
	SystemData.gameplay_settings.hold_piece_changed.connect(_on_GameplaySettings_hold_piece_changed)
	
	display = HoldPieceDisplayScene.instantiate()
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


func _on_GameplaySettings_hold_piece_changed(_value: bool) -> void:
	_refresh()


## When the player advances to a later section in a tutorial, the hold piece might become enabled.
func _on_Level_settings_changed() -> void:
	_refresh()
