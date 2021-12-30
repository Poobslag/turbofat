class_name Landmark
extends Control
## Draws a landmark icon and distance label for career mode's chalkboard map.

## Icon types which represent landmarks
enum LandmarkType {
	NONE, # no icon; this looks strange on the map and should probably never be deliberately used
	CACTUS,
	FOREST,
	GEAR,
	ISLAND,
	MYSTERY, # question mark; this is currently used for the final unreachable destination
	RAINBOW,
	SKULL,
	VOLCANO,
}

const NONE := LandmarkType.NONE
const CACTUS := LandmarkType.CACTUS
const FOREST := LandmarkType.FOREST
const GEAR := LandmarkType.GEAR
const ISLAND := LandmarkType.ISLAND
const MYSTERY := LandmarkType.MYSTERY
const RAINBOW := LandmarkType.RAINBOW
const SKULL := LandmarkType.SKULL
const VOLCANO := LandmarkType.VOLCANO

export (LandmarkType) var type: int setget set_type
export (int) var distance: int setget set_distance

var _landmark_resources_by_type := {
	NONE: null,
	CACTUS: preload("res://assets/main/ui/career/map/landmark-cactus.png"),
	FOREST: preload("res://assets/main/ui/career/map/landmark-forest.png"),
	GEAR: preload("res://assets/main/ui/career/map/landmark-gear.png"),
	ISLAND: preload("res://assets/main/ui/career/map/landmark-island.png"),
	MYSTERY: preload("res://assets/main/ui/career/map/landmark-mystery.png"),
	RAINBOW: preload("res://assets/main/ui/career/map/landmark-rainbow.png"),
	SKULL: preload("res://assets/main/ui/career/map/landmark-skull.png"),
	VOLCANO: preload("res://assets/main/ui/career/map/landmark-volcano.png"),
}

# Shows the landmark's icon
onready var _texture_rect := $TextureRect

# Shows the landmark's distance
onready var _label := $Label

func _ready() -> void:
	_refresh_type()
	_refresh_distance()
	
	# Shift the texture/label around randomly so they're not in a perfect line
	var random_offset := Vector2(rand_range(-6, 6), rand_range(-30, 30))
	_texture_rect.rect_position += random_offset
	_label.rect_position += random_offset


## The position on the left side of the landmark where a chalk line can connect.
##
## This position is relative to the entire map, not relative to this landmark.
func left_connection_point() -> Vector2:
	return _texture_center() + Vector2(-45, 20)


## The position on the right side of the landmark where a chalk line can connect.
##
## This position is relative to the entire map, not relative to this landmark.
func right_connection_point() -> Vector2:
	return _texture_center() + Vector2(45, 20)


func set_type(new_type: int) -> void:
	type = new_type
	_refresh_type()


func set_distance(new_distance: int) -> void:
	distance = new_distance
	_refresh_distance()


## Returns the coordinates of the center of our texture, relative to the map
func _texture_center() -> Vector2:
	return rect_position + _texture_rect.rect_position + _texture_rect.rect_size * Vector2(0.5, 0.5)


## Updates our icon texture based on the current 'type' value
func _refresh_type() -> void:
	if not is_inside_tree():
		return
	_texture_rect.texture = _landmark_resources_by_type.get(type)


## Updates our distance label based on the current 'distance' value
func _refresh_distance() -> void:
	if not is_inside_tree():
		return
	_label.text = StringUtils.comma_sep(distance)
