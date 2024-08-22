tool
class_name GradientHelper
extends Node
## Calculates the currently active gradient for a CandyButton.
##
## CandyButtons are colored using a gradient, and this gradient changes based on the button's color, focus state,
## hovered state and disabled state.

## Emitted when the gradient changes due to a change in the button's properties, such as whether it's focused or not.
signal gradient_changed

## CandyButton used to decide the active gradient.
onready var _button := get_parent()

var gradient: Gradient = preload("res://src/main/ui/candy-button/gradient-none.tres") setget set_gradient

func _ready() -> void:
	_button.connect("color_changed", self, "_on_Button_color_changed")
	_button.connect("disabled_changed", self, "_on_Button_disabled_changed")
	_button.connect("focus_entered", self, "_on_Button_focus_entered")
	_button.connect("focus_exited", self, "_on_Button_focus_exited")
	_button.connect("hovered_changed", self, "_on_Button_hovered_changed")
	_refresh_gradient()


func set_gradient(new_gradient: Gradient) -> void:
	if gradient == new_gradient:
		return
	
	gradient = new_gradient
	emit_signal("gradient_changed")


## Updates our gradient based on the button's properties, such as whether it's focused or not.
func _refresh_gradient() -> void:
	var new_gradient: Gradient
	if _button.has_focus():
		# if the button is focused, we use a bright cyan color
		new_gradient = CandyButtons.GRADIENT_FOCUSED_HOVER if _button.is_hovered() else CandyButtons.GRADIENT_FOCUSED
	elif _button.disabled:
		new_gradient = CandyButtons.GRADIENT_DISABLED_HOVER if _button.is_hovered() else CandyButtons.GRADIENT_DISABLED
	else:
		# if the button is not focused, we use the user-specified color
		var gradients: Array = CandyButtons.GRADIENTS_BY_COLOR[_button.color]
		new_gradient = gradients[1] if _button.is_hovered() else gradients[0]
	
	set_gradient(new_gradient)


func _on_Button_color_changed() -> void:
	_refresh_gradient()


func _on_Button_disabled_changed() -> void:
	_refresh_gradient()


func _on_Button_focus_entered() -> void:
	_refresh_gradient()


func _on_Button_focus_exited() -> void:
	_refresh_gradient()


func _on_Button_hovered_changed() -> void:
	_refresh_gradient()
