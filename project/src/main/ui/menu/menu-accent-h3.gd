tool
extends TextureRect
## Brown accent splat which appears behind a menu label.
##
## This node's parent should always be a Label instance.

enum AccentWidth {
	NONE,
	SMALL,
	MEDIUM,
	LARGE,
	XL,
}

## key: (int) AccentWidth
## value: (Array, Texture) Textures for the specified accent width
const TEXTURES_BY_ACCENT_WIDTH := {
	AccentWidth.NONE: [
	],
	AccentWidth.SMALL: [
		preload("res://assets/main/ui/menu/menu-accent-h3-s1.png"),
		preload("res://assets/main/ui/menu/menu-accent-h3-s2.png"),
		preload("res://assets/main/ui/menu/menu-accent-h3-s3.png"),
	],
	AccentWidth.MEDIUM: [
		preload("res://assets/main/ui/menu/menu-accent-h3-m1.png"),
		preload("res://assets/main/ui/menu/menu-accent-h3-m2.png"),
		preload("res://assets/main/ui/menu/menu-accent-h3-m3.png"),
	],
	AccentWidth.LARGE: [
		preload("res://assets/main/ui/menu/menu-accent-h3-l1.png"),
		preload("res://assets/main/ui/menu/menu-accent-h3-l2.png"),
		preload("res://assets/main/ui/menu/menu-accent-h3-l3.png"),
	],
	AccentWidth.XL: [
		preload("res://assets/main/ui/menu/menu-accent-h3-xl1.png"),
		preload("res://assets/main/ui/menu/menu-accent-h3-xl2.png"),
		preload("res://assets/main/ui/menu/menu-accent-h3-xl3.png"),
	],
}

export (bool) var _refresh: bool setget refresh

export (int) var _accent_index: int

## Approximate accent width, calculated from our label's font and text
var _accent_width: int = AccentWidth.NONE

onready var _parent: Label = get_parent()

func _ready() -> void:
	refresh()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_initialize_onready_variables()


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_parent = get_parent()


## Updates our texture and appearance from our label's font and text.
##
## Parameters:
## 	'_value': Ignored
func refresh(_value: bool = false) -> void:
	if not _parent:
		_initialize_onready_variables()
	
	if not _parent:
		return
	
	_refresh_accent_width()
	_refresh_texture()


## Recalculates the '_accent_width' property from our label's font and text.
func _refresh_accent_width() -> void:
	var shown_text := tr(_parent.text)
	var string_width := _parent.get_font("font").get_string_size(shown_text).x
	
	if string_width < 60:
		_accent_width = AccentWidth.SMALL
	elif string_width < 90:
		_accent_width = AccentWidth.MEDIUM
	elif string_width < 150:
		_accent_width = AccentWidth.LARGE
	else:
		_accent_width = AccentWidth.XL


func _refresh_texture() -> void:
	var textures: Array = TEXTURES_BY_ACCENT_WIDTH[_accent_width]
	if not textures:
		texture = null
	else:
		texture = textures[_accent_index % TEXTURES_BY_ACCENT_WIDTH.size()]
	rect_size = texture.get_size() * 0.5
	rect_position = _parent.rect_size / 2 - rect_size / 2
