extends HBoxContainer
## UI component for reenabling one-time tips, such as the confirmation when restarting/giving up in Adventure mode

var _reenabled_tween: SceneTreeTween

onready var _reenabled_label: Label = $HBoxContainer/Reenabled

func _ready() -> void:
	# hide the 'Re-enabled!' message until we need to display it
	_reenabled_label.modulate = Color.transparent


func _on_Button_pressed() -> void:
	SystemData.misc_settings.show_give_up_confirmation = true
	
	# display the 'Re-enabled!' message, and gradually fade it out
	_reenabled_label.modulate = Color.white
	_reenabled_tween = Utils.recreate_tween(self, _reenabled_tween)
	_reenabled_tween.tween_property(_reenabled_label, "modulate", Color.transparent, 3.0)
