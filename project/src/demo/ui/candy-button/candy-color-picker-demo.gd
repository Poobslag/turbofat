extends Node
## Demonstrates the CandyColorPicker with different palettes.
##
## Keys:
## 	[Q]: Assign a palette with 0 colors.
## 	[W]: Assign a palette with 4 colors.
## 	[E]: Assign a palette with 8 colors.
## 	[R]: Assign a palette with 24 colors.
## 	[T]: Assign a palette with 100 colors.

onready var _color_rect := $ColorRect
onready var _color_picker: CandyColorPicker = $ColorPicker

func _ready() -> void:
	_assign_color_presets(24)
	_color_picker.grab_focus()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_Q:
			_assign_color_presets(0)
		KEY_W:
			_assign_color_presets(4)
		KEY_E:
			_assign_color_presets(8)
		KEY_R:
			_assign_color_presets(24)
		KEY_T:
			_assign_color_presets(100)


func _assign_color_presets(count: int) -> void:
	_color_picker.color_presets = color_presets(count)


func color_presets(count: int) -> Array:
	var result := []
	if count >= 8:
		result.append(Color.white)
		result.append(Color.gray)
		result.append(Color.black)
	while result.size() < count:
		var random_color := Color(randf(), randf(), randf())
		result.append(random_color)
	return result


func _on_ColorPicker_color_changed(color: Color) -> void:
	_color_rect.color = color


func _on_ColorPicker_resized() -> void:
	if not _color_picker:
		return
	
	_color_picker.rect_position = (Global.window_size - _color_picker.rect_size) / 2
