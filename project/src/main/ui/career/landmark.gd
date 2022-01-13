class_name Landmark
extends Control
## Draws a landmark icon and distance label for career mode's chalkboard map.

## Icon types which represent landmarks
enum LandmarkType {
	NONE, # no icon; this looks strange on the map and should probably never be deliberately used
	
	# regular landmark icons
	CACTUS,
	FOREST,
	GEAR,
	ISLAND,
	MYSTERY, # question mark; this is currently used for the final unreachable destination
	RAINBOW,
	SKULL,
	VOLCANO,
	
	# circles which appear on the left side of the map
	CIRCLES_1,
	CIRCLES_2,
	CIRCLES_3,
	CIRCLES_4,
	CIRCLES_5,
	CIRCLES_6,
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

const CIRCLES_1 := LandmarkType.CIRCLES_1
const CIRCLES_2 := LandmarkType.CIRCLES_2
const CIRCLES_3 := LandmarkType.CIRCLES_3
const CIRCLES_4 := LandmarkType.CIRCLES_4
const CIRCLES_5 := LandmarkType.CIRCLES_5
const CIRCLES_6 := LandmarkType.CIRCLES_6

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
	CIRCLES_1: preload("res://assets/main/ui/career/map/circles-1.png"),
	CIRCLES_2: preload("res://assets/main/ui/career/map/circles-2.png"),
	CIRCLES_3: preload("res://assets/main/ui/career/map/circles-3.png"),
	CIRCLES_4: preload("res://assets/main/ui/career/map/circles-4.png"),
	CIRCLES_5: preload("res://assets/main/ui/career/map/circles-5.png"),
	CIRCLES_6: preload("res://assets/main/ui/career/map/circles-6.png"),
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


## Preemptively initialize onready variables to avoid null references.
func _enter_tree() -> void:
	_texture_rect = $TextureRect
	_label = $Label


## The position on the left side of the landmark where a chalk line can connect.
##
## This position is relative to the entire map, not relative to this landmark.
func left_connection_point() -> Vector2:
	return _texture_center() + Vector2(-45, 20)


## The position on the right side of the landmark where a chalk line can connect.
##
## This position is relative to the entire map, not relative to this landmark.
func right_connection_point() -> Vector2:
	return _texture_center() + (Vector2(48, 18) if _is_circles_type() else Vector2(45, 20))


func set_type(new_type: int) -> void:
	type = new_type
	_refresh_type()


func set_distance(new_distance: int) -> void:
	distance = new_distance
	_refresh_distance()


## Returns 'true' if this landmark renders the circles on the left side of the map
func _is_circles_type() -> bool:
	return type in [CIRCLES_1, CIRCLES_2, CIRCLES_3, CIRCLES_4, CIRCLES_5, CIRCLES_6]


## Returns the coordinates of the center of our texture, relative to the map
func _texture_center() -> Vector2:
	return rect_position + _texture_rect.rect_position + _texture_rect.rect_size * Vector2(0.5, 0.5)


## Updates our icon texture based on the current 'type' value
func _refresh_type() -> void:
	if not is_inside_tree():
		return
	_texture_rect.texture = _landmark_resources_by_type.get(type)
	_texture_rect.rect_size = Vector2(120, 90) if _is_circles_type() else Vector2(90, 90)
	_texture_rect.modulate = Color("64646e") if _is_circles_type() else Color("c8c8c8")


## Updates our distance label based on the current 'distance' value
func _refresh_distance() -> void:
	if not is_inside_tree():
		return
	_label.text = StringUtils.comma_sep(distance)
