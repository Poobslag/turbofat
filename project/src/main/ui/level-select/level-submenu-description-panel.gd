extends Panel
## A panel on the level select screen which shows level descriptions.

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


## When an unlocked level is selected, we display the level's description.
func _on_LevelButtons_unlocked_level_selected(settings: LevelSettings) -> void:
	set_text(settings.description)


## When a locked level is selected, we tell the player how to unlock it.
func _on_LevelButtons_locked_level_selected(_settings: LevelSettings) -> void:
	set_text(tr("Play this level in Career mode to unlock it!"))
