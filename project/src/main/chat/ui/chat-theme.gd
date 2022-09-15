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
const DEFAULT_ACCENT_AMOUNT_DARK := 0.24
const DEFAULT_ACCENT_AMOUNT_LIGHT := 0.18

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
var accent_scale: float = DEFAULT_ACCENT_SCALE

## If 'true', the accent's foreground/background colors will be swapped
var accent_swapped: bool

## A number in the range [0, 15] referring to a background texture
var accent_texture_index: int

## The color of the chat window
var color: Color = DEFAULT_COLOR setget set_color

## If 'true', the backgrond will be black instead of white
var dark: bool setget set_dark

## The color for the nametag font; black or white.
## virtual property; value is only exposed through getters/setters
var nametag_font_color setget ,get_nametag_font_color

## The scale of the accent's background texture
## virtual property; value is only exposed through getters/setters
var accent_color: Color setget ,get_accent_color

## The color for the frame border, nametag background and text.
## virtual property; value is only exposed through getters/setters
var border_color: Color setget ,get_border_color

## The opacity of the accent's background texture.
## virtual property; value is only exposed through getters/setters
var accent_amount: float setget ,get_accent_amount

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


func get_accent_amount() -> float:
	return DEFAULT_ACCENT_AMOUNT_DARK if dark else DEFAULT_ACCENT_AMOUNT_LIGHT


func get_accent_color() -> Color:
	var result := color
	
	var color_brightness := Utils.brightness(result)
	if dark:
		if color_brightness < 0.30:
			# avoid dark accents on black backgrounds, they're hard to see
			result = result.lightened(0.30 - color_brightness)
		elif color_brightness > 0.60:
			# avoid dark accents on black backgrounds, they're too distracting
			result = result.darkened(color_brightness - 0.60)
	else:
		if color_brightness > 0.50:
			# avoid light accents on white backgrounds, they're hard to see
			result = result.darkened(color_brightness - 0.50)
		elif color_brightness < 0.25:
			# avoid dark accents on white backgrounds, they're too distracting
			result = result.lightened(0.25 - color_brightness)
	
	return result


func get_border_color() -> Color:
	var result := color
	
	# desaturate the text and brighten/darken it
	result.s = lerp(result.s, 0.0, 0.2)
	result.v = lerp(result.v, 0.78 if dark else 0.22, 0.5)
	
	# make further adjustments for especially bright/dark colors
	var color_brightness := Utils.brightness(result)
	if dark and color_brightness < 0.40:
		result = result.lightened(0.40 - color_brightness)
	elif not dark and color_brightness > 0.30:
		result = result.darkened(color_brightness - 0.30)
	
	return result
