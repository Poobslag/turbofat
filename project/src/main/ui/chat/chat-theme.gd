class_name ChatTheme
## Stores metadata about the chat window's appearance.
##
## The chat window changes its appearance based on who's talking. For example, one character's speech might be blue
## with a black background, and giant blue soccer balls in the background. The chat theme defines the chat window's
## appearance, such as 'blue', 'soccer balls' and 'giant'.

enum NametagSize {
	OFF, # 0 characters
	SMALL, # 1-10 characters, approximately
	MEDIUM, # 11-20 characters, approximately
	LARGE, # 21-30 characters, approximately
	XL, # 31-60 characters, approximately
	XXL, # 61-90 characters, approximately
}

enum ChatLineSize {
	SMALL, # 1-2 lines at 50% capacity
	MEDIUM, # 2 lines at 75% capacity
	LARGE, # 3 lines at 75% capacity
	XL # 3 lines at 100% capacity
}

const DEFAULT_COLOR := Color.gray
const DEFAULT_ACCENT_SCALE := 8.0

const LINE_SMALL := ChatLineSize.SMALL
const LINE_MEDIUM := ChatLineSize.MEDIUM
const LINE_LARGE := ChatLineSize.LARGE
const LINE_XL := ChatLineSize.XL

const NAMETAG_OFF := NametagSize.OFF
const NAMETAG_SMALL := NametagSize.SMALL
const NAMETAG_MEDIUM := NametagSize.MEDIUM
const NAMETAG_LARGE := NametagSize.LARGE
const NAMETAG_XL := NametagSize.XL
const NAMETAG_XXL := NametagSize.XXL

## The scale of the accent's background texture
var accent_scale: float

## If 'true', the accent's foreground/background colors will be swapped
var accent_swapped: bool

## A number in the range [0, 15] referring to a background texture
var accent_texture_index: int

## The color of the chat window
var color: Color setget set_color

## If 'true', the backgrond will be black instead of white
var dark: bool setget set_dark

## virtual property; value is only exposed through getters/setters
var nametag_font_color setget ,get_nametag_font_color

## virtual property; value is only exposed through getters/setters
var accent_color: Color setget ,get_accent_color

## virtual property; value is only exposed through getters/setters
var border_color: Color setget ,get_border_color

func from_json_dict(dict: Dictionary) -> void:
	accent_scale = dict.get("accent_scale", DEFAULT_ACCENT_SCALE)
	accent_swapped = dict.get("accent_swapped", false)
	accent_texture_index = dict.get("accent_texture", 0)
	color = dict.get("color", DEFAULT_COLOR)
	dark = dict.get("dark", false)


func set_color(new_color: Color) -> void:
	color = new_color


func set_dark(new_dark: bool) -> void:
	dark = new_dark


func to_json_dict() -> Dictionary:
	var result := {}
	if accent_scale != DEFAULT_ACCENT_SCALE:
		result["accent_scale"] = accent_scale
	if accent_swapped:
		result["accent_swapped"] = accent_swapped
	if accent_texture_index:
		result["accent_texture"] = accent_texture_index
	if color != DEFAULT_COLOR:
		result["color"] = color.to_html(false)
	if dark:
		result["dark"] = dark
	return result


func get_nametag_font_color() -> Color:
	return Color.black if dark else Color.white


func get_accent_color() -> Color:
	var result := color
	if dark:
		# accent color is a darker version of the input color
		result.v = lerp(result.v, 0.33, 0.8)
	else:
		# accent color is a lighter, more saturated version of the input color
		result.v = lerp(result.v, 0.67, 0.8)
		result.s = pow(result.s, 0.22)
	return result


func get_border_color() -> Color:
	var result := color
	if dark:
		# border color is a lighter, more saturated version of the input color
		result.v = lerp(result.v, 0.78, 0.8)
		result.s = pow(result.s, 0.33)
	else:
		# border color is a darker version of the input color
		result.v = lerp(result.v, 0.22, 0.8)
	return result
