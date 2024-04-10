class_name RegionSelectButton
extends MarginContainer
## Button on the region select screen which selects a career region.
##
## For layout purposes, this is technically not an actual Button object but instead is a Control which has a Button in
## it. However, it supports several button behaviors such as the disabled property and focus_entered/focus_exited
## signals.

## Emitted when the player launches a career region.
signal region_chosen

## List of different button types which decide the image shown on the button.
enum Type {
	NONE,
	
	# career regions
	LEMON,
	LEMON_2,
	POKI,
	SAND,
	MARSH,
	LAVA,
	
	# training modes
	MARATHON,
	ULTRA,
	SPRINT,
	RANK,
	SANDBOX,
}

## text to show at the top of the button, like 'Merrymellow Marsh'
var region_name := "" setget set_region_name

## button's visual index, the leftmost shown button has an index of '0'
var button_index := 0 setget set_button_index

## 'true' if the button is disabled
var disabled := false setget set_disabled

## Image shown on the button.
var button_type: int = Type.NONE setget set_button_type

## Array of level ranks for levels in this region. Incomplete levels are treated as rank 999.
var ranks := []

## Number in the range [0.0, 1.0] for how close the player is to completing the region.
var completion_percent := 0.0

## key: (Type)
## value: (Array, Resource) pair of texture resources to use when the button is enabled or disabled
var _texture_pairs_by_type := {
	Type.NONE: [preload("res://assets/main/career/ui/region-default.png"),
			preload("res://assets/main/career/ui/region-default-off.png")],
	Type.LEMON: [preload("res://assets/main/career/ui/region-lemon.png"),
			preload("res://assets/main/career/ui/region-lemon-off.png")],
	Type.LEMON_2: [preload("res://assets/main/career/ui/region-lemon-2.png"),
			preload("res://assets/main/career/ui/region-lemon-2-off.png")],
	Type.POKI: [preload("res://assets/main/career/ui/region-poki.png"),
			preload("res://assets/main/career/ui/region-poki-off.png")],
	Type.SAND: [preload("res://assets/main/career/ui/region-sand.png"),
			preload("res://assets/main/career/ui/region-sand-off.png")],
	Type.MARSH: [preload("res://assets/main/career/ui/region-marsh.png"),
			preload("res://assets/main/career/ui/region-marsh-off.png")],
	Type.LAVA: [preload("res://assets/main/career/ui/region-lava.png"),
			preload("res://assets/main/career/ui/region-lava-off.png")],
	
	Type.MARATHON: [preload("res://assets/main/career/ui/training-marathon.png"),
			preload("res://assets/main/career/ui/training-marathon-off.png")],
	Type.ULTRA: [preload("res://assets/main/career/ui/training-ultra.png"),
			preload("res://assets/main/career/ui/training-ultra-off.png")],
	Type.SPRINT: [preload("res://assets/main/career/ui/training-sprint.png"),
			preload("res://assets/main/career/ui/training-sprint-off.png")],
	Type.RANK: [preload("res://assets/main/career/ui/training-rank.png"),
			preload("res://assets/main/career/ui/training-rank-off.png")],
	Type.SANDBOX: [preload("res://assets/main/career/ui/training-sandbox.png"),
			preload("res://assets/main/career/ui/training-sandbox-off.png")],
}

## 'true' if this button just received focus this frame. A mouse click which grants focus doesn't emit a 'region
## started' event
var _focus_just_entered := false

## 'true' if the 'region started' signal should be emitted in response to a button click.
var _emit_region_chosen := false

onready var grade_hook := $Button/GradeHook

onready var _button := $Button
onready var _button_name_label := $Button/NameLabel
onready var _button_polygon2d := $Button/Polygon2D

func _ready() -> void:
	_refresh()


func _process(_delta: float) -> void:
	_focus_just_entered = false


func set_button_index(new_button_index: int) -> void:
	button_index = new_button_index
	
	# align top for buttons #1/3/5..., bottom for buttons #2/4/6...
	set("custom_constants/margin_top", null)
	set("custom_constants/margin_bottom", null)
	set("custom_constants/margin_bottom" if posmod(button_index, 2) == 0 else "custom_constants/margin_top", 40)


func set_button_type(new_button_type: int) -> void:
	button_type = new_button_type
	_refresh()


func set_disabled(new_disabled: bool) -> void:
	disabled = new_disabled
	_refresh()


func set_region_name(new_region_name: String) -> void:
	region_name = new_region_name
	_refresh()


func grab_focus() -> void:
	_button.grab_focus()


## Refreshes the button's image and text based on our current properties.
func _refresh() -> void:
	if not is_inside_tree():
		return
	
	_button.disabled = disabled
	_button_name_label.text = region_name
	
	# change the button's image
	var texture_pair: Array = _texture_pairs_by_type[button_type]
	_button_polygon2d.texture = texture_pair[1] if disabled else texture_pair[0]
	
	# change the font outline color to match the button's outline color
	var new_outline_color: Color
	if _button.has_focus():
		new_outline_color = Color("007a99")
	elif disabled:
		new_outline_color = Color("41281e")
	else:
		new_outline_color = Color("6c4331")
	var font: DynamicFont = _button_name_label.get("custom_fonts/font")
	font.outline_color = new_outline_color


func _on_Button_focus_entered() -> void:
	_refresh()
	_focus_just_entered = true
	emit_signal("focus_entered")


func _on_Button_button_down() -> void:
	if _focus_just_entered:
		pass
	else:
		_emit_region_chosen = true


func _on_Button_pressed() -> void:
	if _emit_region_chosen:
		_emit_region_chosen = false
		emit_signal("region_chosen")


func _on_Button_focus_exited() -> void:
	_refresh()
	emit_signal("focus_exited")
