extends Control
## Draws the shadow cast on the wooden surface behind the playfield.
##
## The shape of this shadow changes based on whether the hold piece cheat is enabled.

@onready var _normal_shadow: Polygon2D = $NormalShadow
@onready var _hold_piece_shadow: Polygon2D = $HoldPieceShadow

func _ready() -> void:
	SystemData.gameplay_settings.hold_piece_changed.connect(_on_GameplaySettings_hold_piece_changed)
	_refresh()


func _refresh() -> void:
	_hold_piece_shadow.visible = CurrentLevel.is_hold_piece_cheat_enabled()
	_normal_shadow.visible = not _hold_piece_shadow.visible


func _on_GameplaySettings_hold_piece_changed(_value: bool) -> void:
	_refresh()
