class_name ProgressBoardTitle
extends Control
## Title at the top of the progress board.
##
## This includes a label showing the region name which is bookended by a set of icons.

## Icon types which change with the region
enum IconType {
	NONE, # no icon
	
	CACTUS,
	FOREST,
	GEAR,
	ISLAND,
	MYSTERY, # question mark; this is currently used for the final unreachable destination
	RAINBOW,
	SKULL,
	VOLCANO,
}

const NONE := IconType.NONE
const CACTUS := IconType.CACTUS
const FOREST := IconType.FOREST
const GEAR := IconType.GEAR
const ISLAND := IconType.ISLAND
const MYSTERY := IconType.MYSTERY
const RAINBOW := IconType.RAINBOW
const SKULL := IconType.SKULL
const VOLCANO := IconType.VOLCANO

var _icon_resources_by_type := {
	NONE: null,
	
	CACTUS: preload("res://assets/main/career/ui/map/landmark-cactus.png"),
	FOREST: preload("res://assets/main/career/ui/map/landmark-forest.png"),
	GEAR: preload("res://assets/main/career/ui/map/landmark-gear.png"),
	ISLAND: preload("res://assets/main/career/ui/map/landmark-island.png"),
	MYSTERY: preload("res://assets/main/career/ui/map/landmark-mystery.png"),
	RAINBOW: preload("res://assets/main/career/ui/map/landmark-rainbow.png"),
	SKULL: preload("res://assets/main/career/ui/map/landmark-skull.png"),
	VOLCANO: preload("res://assets/main/career/ui/map/landmark-volcano.png"),
}

## Text of the label showing the region name.
var text: String: set = set_text

## Enum from IconType for the type of icon to show alongside the title.
var icon_type: IconType: set = set_icon_type

## Label which shows the region name.
@onready var _label := $HBoxContainer/Label

## Icons which change with the region.
@onready var _left_icon := $HBoxContainer/Control1/TextureRect
@onready var _right_icon := $HBoxContainer/Control2/TextureRect

func _ready() -> void:
	_refresh()


func set_text(new_text: String) -> void:
	text = new_text
	_refresh()


func set_icon_type(new_icon_type: IconType) -> void:
	icon_type = new_icon_type
	_refresh()


## Updates the label's text and icon graphics.
func _refresh() -> void:
	# refresh text
	_label.text = text
	
	# refresh icons
	_left_icon.texture = _icon_resources_by_type.get(icon_type)
	_right_icon.texture = _left_icon.texture
