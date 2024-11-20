class_name DifficultyButton
extends Button
## Button on the difficulty screen which selects a difficulty.

## key: (int) Enum from DifficultyData.Speed
## value: (Array, Resource) pair of texture resources to use when the difficulty is chosen or not
const TEXTURE_PAIRS_BY_SPEED := {
	DifficultyData.Speed.FASTESTEST: [preload("res://assets/main/ui/difficulty/turbo.png"),
			preload("res://assets/main/ui/difficulty/turbo-off.png")],
	DifficultyData.Speed.FASTEST: [preload("res://assets/main/ui/difficulty/turbo.png"),
			preload("res://assets/main/ui/difficulty/turbo-off.png")],
	DifficultyData.Speed.FASTER: [preload("res://assets/main/ui/difficulty/turbo.png"),
			preload("res://assets/main/ui/difficulty/turbo-off.png")],
	DifficultyData.Speed.FAST: [preload("res://assets/main/ui/difficulty/turbo.png"),
			preload("res://assets/main/ui/difficulty/turbo-off.png")],
	DifficultyData.Speed.DEFAULT: [preload("res://assets/main/ui/difficulty/normal.png"),
			preload("res://assets/main/ui/difficulty/normal-off.png")],
	DifficultyData.Speed.SLOW: [preload("res://assets/main/ui/difficulty/relaxed.png"),
			preload("res://assets/main/ui/difficulty/relaxed-off.png")],
	DifficultyData.Speed.SLOWER: [preload("res://assets/main/ui/difficulty/relaxed.png"),
			preload("res://assets/main/ui/difficulty/relaxed-off.png")],
	DifficultyData.Speed.SLOWEST: [preload("res://assets/main/ui/difficulty/relaxed.png"),
			preload("res://assets/main/ui/difficulty/relaxed-off.png")],
	DifficultyData.Speed.SLOWESTEST: [preload("res://assets/main/ui/difficulty/zen.png"),
			preload("res://assets/main/ui/difficulty/zen-off.png")],
}

export (DifficultyData.Speed) var speed: int = DifficultyData.Speed.DEFAULT

## key: (int) Enum from DifficultyData.Speed
## value: (String) Difficulty name shown on the button
var difficulty_names_by_speed := {
	DifficultyData.Speed.FASTESTEST: tr("Turbo Mode"),
	DifficultyData.Speed.FASTEST: tr("Turbo Mode"),
	DifficultyData.Speed.FASTER: tr("Turbo Mode"),
	DifficultyData.Speed.FAST: tr("Turbo Mode"),
	DifficultyData.Speed.DEFAULT: tr("Normal Mode"),
	DifficultyData.Speed.SLOW: tr("Relaxed Mode"),
	DifficultyData.Speed.SLOWER: tr("Relaxed Mode"),
	DifficultyData.Speed.SLOWEST: tr("Relaxed Mode"),
	DifficultyData.Speed.SLOWESTEST: tr("Zen Mode"),
}

onready var _polygon2d := $Polygon2D
onready var _name_label := $NameLabel

func _ready() -> void:
	PlayerData.difficulty.connect("speed_changed", self, "_on_DifficultyData_speed_changed")
	
	_refresh()


## Updates the button's text and texture based on the button's difficulty and the player's chosen difficulty.
func _refresh() -> void:
	_name_label.text = difficulty_names_by_speed[speed]
	
	# change the button's image
	var texture_pair: Array = TEXTURE_PAIRS_BY_SPEED[speed]
	_polygon2d.texture = texture_pair[0] if is_button_difficulty_chosen() else texture_pair[1]
	
	# change the font outline color to match the button's outline color
	var new_outline_color: Color
	if has_focus():
		new_outline_color = Color("007a99")
	elif disabled:
		new_outline_color = Color("41281e")
	else:
		new_outline_color = Color("6c4331")
	var font: DynamicFont = _name_label.get("custom_fonts/font")
	font.outline_color = new_outline_color


## Returns:
## 	'true' if the button's difficulty matches the player's chosen difficulty.
func is_button_difficulty_chosen() -> bool:
	return speed == PlayerData.difficulty.speed


func _pressed() -> void:
	PlayerData.difficulty.speed = speed
	PlayerSave.schedule_save()
	_refresh()


func _on_DifficultyData_speed_changed(_value: int) -> void:
	_refresh()


func _on_Button_focus_entered() -> void:
	_refresh()


func _on_Button_focus_exited() -> void:
	_refresh()
