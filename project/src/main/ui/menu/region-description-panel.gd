extends Panel
## A panel on the region select screen which shows region descriptions.

onready var _label := $MarginContainer/Label

var text: String setget set_text

func _ready() -> void:
	_refresh_text()


func set_text(new_text: String) -> void:
	text = new_text
	_refresh_text()


func _refresh_text() -> void:
	if _label:
		_label.text = text


func _on_RegionButtons_locked_region_focused(_region: Object) -> void:
	set_text(tr("Advance further into career mode to unlock new areas!"))


func _on_RegionButtons_unlocked_region_focused(region: Object) -> void:
	set_text(region.description)
