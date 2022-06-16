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


func _on_RegionButtons_region_selected(region: CareerRegion) -> void:
	if PlayerData.career.is_region_locked(region):
		set_text(tr("Advance further into career mode to unlock new areas!"))
	else:
		set_text(region.description)
