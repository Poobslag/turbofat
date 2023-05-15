extends HBoxContainer
## UI control for changing the feeding animation

@onready var _option_button: OptionButton = $OptionButton

func _ready() -> void:
	_option_button.add_item(tr("Linear"))
	_option_button.add_item(tr("Bouncy"))
	_option_button.selected = SystemData.graphics_settings.feeding_animation


func _on_OptionButton_item_selected(_index: int) -> void:
	SystemData.graphics_settings.feeding_animation = _index
