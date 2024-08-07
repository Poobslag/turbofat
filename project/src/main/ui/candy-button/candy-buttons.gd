class_name CandyButtons
## Enums, constants and utilities for CandyButtons, eye-catching buttons with customizable colors and textures.

enum ButtonColor {
	NONE,
	RED,
	ORANGE,
	YELLOW,
	GREEN,
	BLUE,
	INDIGO,
	VIOLET,
}

## Repeating piece shapes which decorate the button.
enum ButtonShape {
	NONE,
	PIECE_J,
	PIECE_L,
	PIECE_O,
	PIECE_P,
	PIECE_Q,
	PIECE_T,
	PIECE_U,
	PIECE_V,
}

## Gradient which colors the button bright cyan when the button is focused.
const GRADIENT_FOCUSED := preload("res://src/main/ui/candy-button/gradient-focused.tres")

## Gradient which colors the button bright cyan when the button is focused and hovered.
const GRADIENT_FOCUSED_HOVER := preload("res://src/main/ui/candy-button/gradient-focused-hover.tres")

## Gradient which colors the button beige when the button is disabled.
const GRADIENT_DISABLED := preload("res://src/main/ui/candy-button/gradient-disabled.tres")

## Gradient which colors the button bright beige when the button is disabled and hovered.
const GRADIENT_DISABLED_HOVER := preload("res://src/main/ui/candy-button/gradient-disabled-hover.tres")

## Gradients for the various ButtonColor presets.
##
## key: (int) Enum from ButtonColor
## value: (Array, Gradient) Array with two entries for the gradients for the specified color:
## 	value[0]: (Gradient) Gradient to use when the button is not hovered.
## 	value[1]: (Gradient) Gradient to use when the button is hovered.
const GRADIENTS_BY_COLOR := {
	ButtonColor.NONE: [
		preload("res://src/main/ui/candy-button/gradient-none.tres"),
		preload("res://src/main/ui/candy-button/gradient-none-hover.tres")],
	ButtonColor.RED: [
		preload("res://src/main/ui/candy-button/gradient-red-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-red-hover.tres")],
	ButtonColor.ORANGE: [
		preload("res://src/main/ui/candy-button/gradient-orange-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-orange-hover.tres")],
	ButtonColor.YELLOW: [
		preload("res://src/main/ui/candy-button/gradient-yellow-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-yellow-hover.tres")],
	ButtonColor.GREEN: [
		preload("res://src/main/ui/candy-button/gradient-green-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-green-hover.tres")],
	ButtonColor.BLUE: [
		preload("res://src/main/ui/candy-button/gradient-blue-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-blue-hover.tres")],
	ButtonColor.INDIGO: [
		preload("res://src/main/ui/candy-button/gradient-indigo-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-indigo-hover.tres")],
	ButtonColor.VIOLET: [
		preload("res://src/main/ui/candy-button/gradient-violet-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-violet-hover.tres")],
}



## Textures for the various ButtonShape presets.
##
## key: (int) Enum from ButtonShape
## value: (Array, Texture) Array with two entries for the textures for the specified shape:
## 	value[0]: (Texture) texture to use when the button is not pressed.
## 	value[1]: (Texture) texture to use when the button is pressed.
const C3_TEXTURES_BY_SHAPE := {
	ButtonShape.NONE: [
		preload("res://assets/main/ui/candy-button/c3-blank.png"),
		preload("res://assets/main/ui/candy-button/c3-blank-pressed.png")],
	ButtonShape.PIECE_J: [
		preload("res://assets/main/ui/candy-button/c3-j.png"),
		preload("res://assets/main/ui/candy-button/c3-j-pressed.png")],
	ButtonShape.PIECE_L: [
		preload("res://assets/main/ui/candy-button/c3-l.png"),
		preload("res://assets/main/ui/candy-button/c3-l-pressed.png")],
	ButtonShape.PIECE_O: [
		preload("res://assets/main/ui/candy-button/c3-o.png"),
		preload("res://assets/main/ui/candy-button/c3-o-pressed.png")],
	ButtonShape.PIECE_P: [
		preload("res://assets/main/ui/candy-button/c3-p.png"),
		preload("res://assets/main/ui/candy-button/c3-p-pressed.png")],
	ButtonShape.PIECE_Q: [
		preload("res://assets/main/ui/candy-button/c3-q.png"),
		preload("res://assets/main/ui/candy-button/c3-q-pressed.png")],
	ButtonShape.PIECE_T: [
		preload("res://assets/main/ui/candy-button/c3-t.png"),
		preload("res://assets/main/ui/candy-button/c3-t-pressed.png")],
	ButtonShape.PIECE_U: [
		preload("res://assets/main/ui/candy-button/c3-u.png"),
		preload("res://assets/main/ui/candy-button/c3-u-pressed.png")],
	ButtonShape.PIECE_V: [
		preload("res://assets/main/ui/candy-button/c3-v.png"),
		preload("res://assets/main/ui/candy-button/c3-v-pressed.png")],
}
