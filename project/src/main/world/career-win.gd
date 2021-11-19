extends Node
## Shows a 'You win!' screen when the player finishes career mode

onready var _button := $Button
onready var _label := $Label

func _ready() -> void:
	# prepare the label text
	_label.text = ""
	_label.text += "Distance: %s\n\n" % [PlayerData.career.distance_travelled]
	_label.text += "Earnings: %s" % [StringUtils.format_money(PlayerData.career.daily_earnings)]
	PlayerData.career.advance_calendar()
	PlayerSave.save_player_data()
	
	_button.grab_focus()


func _on_Button_pressed() -> void:
	SceneTransition.pop_trail()
