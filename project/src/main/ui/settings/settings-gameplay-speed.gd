extends Control
## UI control for adjusting the gameplay speed.
##
## The gameplay speed affects how fast pieces fall in puzzle mode.

onready var _option_button: OptionButton = $OptionButton

func _ready() -> void:
	_option_button.add_item(tr("Slowestest"), GameplaySettings.Speed.SLOWESTEST)
	_option_button.add_item(tr("Slowest"), GameplaySettings.Speed.SLOWEST)
	_option_button.add_item(tr("Slower"), GameplaySettings.Speed.SLOWER)
	_option_button.add_item(tr("Slow"), GameplaySettings.Speed.SLOW)
	_option_button.add_item(tr("Default"), GameplaySettings.Speed.DEFAULT)
	_option_button.add_item(tr("Fast"), GameplaySettings.Speed.FAST)
	_option_button.add_item(tr("Faster"), GameplaySettings.Speed.FASTER)
	_option_button.add_item(tr("Fastest"), GameplaySettings.Speed.FASTEST)
	_option_button.add_item(tr("Fastestest"), GameplaySettings.Speed.FASTESTEST)
	
	_option_button.selected = _option_button.get_item_index(SystemData.gameplay_settings.speed)


func _on_OptionButton_item_selected(index: int) -> void:
	var item_id := _option_button.get_item_id(index)
	SystemData.gameplay_settings.speed = item_id
