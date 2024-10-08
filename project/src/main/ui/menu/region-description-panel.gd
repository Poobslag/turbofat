extends Panel
## Panel on the region select screen which shows region descriptions.

var text: String setget set_text

onready var _label := $MarginContainer/Label

func _ready() -> void:
	_refresh_text()


func set_text(new_text: String) -> void:
	text = new_text
	_refresh_text()


func _refresh_text() -> void:
	if _label:
		_label.text = text


func _on_RegionButtons_locked_region_focused(_region: Object) -> void:
	set_text(tr("Advance further into Adventure mode to unlock new areas!"))


func _on_RegionButtons_unlocked_region_focused(region: Object) -> void:
	set_text(region.description)
