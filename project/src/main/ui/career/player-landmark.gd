extends Control
## Draws the player on the career mode's chalkboard map.
##
## This includes four components: a player graphic, a distance label, a dot along the player's current path, and a
## line connecting the player's dot to the distance label.

## The player's current distance in steps.
var distance := 0 setget set_distance

## The endpoints of the line connecting the two landmarks before and after the player.
var landmark_endpoints := [Vector2.ZERO, Vector2.ZERO] setget set_landmark_endpoints

## How far the player has progressed between the two landmarks before and after the player.
var progress_percent := 0.0 setget set_progress_percent

## Shows the player's distance.
onready var _label: Label = $Label

## Shows a dot along the player's current path.
onready var _dot_sprite: Sprite = $DotSprite

## Shows a player graphic above the path.
onready var _player_sprite: Sprite = $PlayerSprite

## Shows a line connecting the player's dot to the distance label.
onready var _line: Line2D = $Line2D

func _ready() -> void:
	_refresh()

func set_distance(new_distance: int) -> void:
	distance = new_distance
	_refresh()


func set_landmark_endpoints(new_landmark_endpoints: Array) -> void:
	landmark_endpoints = new_landmark_endpoints
	_refresh()


func set_progress_percent(new_progress_percent: float) -> void:
	progress_percent = new_progress_percent
	_refresh()


## Recalculates the positions and values for all visual components.
func _refresh() -> void:
	_label.text = StringUtils.comma_sep(distance)
	
	# position the player's dot
	_dot_sprite.position = lerp(landmark_endpoints[0], landmark_endpoints[1], progress_percent)
	# connect line to the player's dot
	_line.points[0] = _dot_sprite.position
	
	# position the distance label
	_label.rect_position = lerp(landmark_endpoints[0], \
			landmark_endpoints[1], 0.5) + Vector2(-_label.rect_size.x * 0.5, 25)
	# connect line to the distance label
	_line.points[1] = _label.rect_position + Vector2(_label.rect_size.x * 0.5, 0)
	
	# position the player sprite
	_player_sprite.position = lerp(landmark_endpoints[0], \
			landmark_endpoints[1], progress_percent * 0.5 + 0.25) + Vector2(0, -40)
