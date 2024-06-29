tool
class_name CreatureNameButton
extends CandyButtonC3
## A button which pops up a TextEdit to edit the creature's name.

signal name_changed(name)

var creature: Creature

onready var _popup := $NamePickerPopup

func _pressed() -> void:
	_click_sound.pitch_scale = rand_range(0.95, 1.05)
	SfxKeeper.copy(_click_sound).play()
	
	if creature:
		_popup.set_selected_name(creature.creature_name)
	# calculate the popup position; it appears to the left of the button, but stays within the viewport
	var popup_position := get_global_transform().origin
	popup_position += Vector2(-_popup.rect_size.x, 0)
	var screen_size := get_viewport_rect().size
	popup_position.x = clamp(popup_position.x, 0, screen_size.x - _popup.rect_size.x)
	popup_position.y = clamp(popup_position.y, 0, screen_size.y - _popup.rect_size.y)
	
	_popup.popup(Rect2(popup_position, _popup.rect_size))


func _on_NamePickerPopup_name_changed(name: String) -> void:
	emit_signal("name_changed", name)
