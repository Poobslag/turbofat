class_name CreditsScroll
extends Control
## Credits scene which shows scrolling credits.
##
## Contains methods for adding visual elements to the credits and moving them around, which are called by a
## CreditsDirector.

## The vertical position where the credits fade out in TOP or BOTTOM positions.
const FADE_OUT_POINT_POSITION_TOP := Vector2.ZERO
const FADE_OUT_POINT_POSITION_BOTTOM := Vector2(0, 110)

## The horizontal positions for the credits in LEFT, CENTER or RIGHT positions.
const LINES_POSITION_LEFT := Vector2.ZERO
const LINES_POSITION_CENTER := Vector2(256, 0)
const LINES_POSITION_RIGHT := Vector2(512, 0)

export (PackedScene) var CreditsWallOfTextScene: PackedScene
export (PackedScene) var GodotCreditsLineScene: PackedScene
export (PackedScene) var TextCreditsLineScene: PackedScene
export (PackedScene) var TextCreditsIndentLineScene: PackedScene
export (PackedScene) var TurboFatCreditsLineScene: PackedScene

## Position of the scrolling part of the credits.
export (Credits.CreditsPosition) var credits_position := Credits.CreditsPosition.CENTER_BOTTOM \
		setget set_credits_position

var velocity: Vector2 = Vector2(0, -50)

var _horizontal_tween: SceneTreeTween
var _vertical_tween: SceneTreeTween

## Header which says 'Turbo Fat' over the scrolling lines.
onready var header: CreditsHeader = $FixedContainer/ScrollingContainer/Header

## Orb which floats around the credits screen, launching puzzle pieces.
onready var orb: CreditsOrb = $FixedContainer/OrbHolder/Orb

## A point near the top of the screen where lines fade out.
onready var _fade_out_point := $FixedContainer/FadeOutPoint
## A point near the bottom of the screen where lines fade in.
onready var _fade_in_point := $FixedContainer/FadeInPoint

## Scrolling area with lines, header and the orb
onready var _scrolling_container := $FixedContainer/ScrollingContainer

## Container for scrolling lines.
onready var _lines := $FixedContainer/ScrollingContainer/Lines

onready var _credits_pieces: CreditsPieces = $FixedContainer/OrbHolder/Pieces

func _ready() -> void:
	MusicPlayer.play_credits_bgm()


## Adds a text line like 'Directed by:'
func add_line(text: String) -> void:
	var line: TextCreditsLine = TextCreditsLineScene.instance()
	line.text = text
	_initialize_line(line)


## Adds an indented line like 'John Doe'
func add_indent_line(text: String) -> void:
	var indent_line: TextCreditsLine = TextCreditsIndentLineScene.instance()
	indent_line.text = text
	_initialize_line(indent_line)


## Adds a 'Proudly made with Godot' line.
func add_godot_line() -> void:
	var godot_line: CreditsLine = GodotCreditsLineScene.instance()
	_initialize_line(godot_line)


## Adds a centered 'Turbo Fat' line.
func add_turbo_fat_line() -> void:
	var turbo_fat_line: CreditsLine = TurboFatCreditsLineScene.instance()
	_initialize_line(turbo_fat_line)


## Shows a non-scrolling wall of text which remains on screen for a few seconds.
func show_wall_of_text(text: String, duration: float) -> void:
	var wall_of_text: CreditsWallOfText = CreditsWallOfTextScene.instance()
	wall_of_text.duration = duration
	wall_of_text.text = text
	wall_of_text.position = Vector2(20, _fade_in_point.position.y * 0.5 + _fade_out_point.position.y * 0.5)
	_lines.add_child(wall_of_text)


## Smoothly moves the credits to a new position, showing or hiding the header.
func set_credits_position(new_credits_position: int) -> void:
	var old_credits_position := credits_position
	credits_position = new_credits_position
	
	if Credits.is_position_top(credits_position) and not Credits.is_position_top(old_credits_position):
		# move credits to a top position; hide the header and raise the fade out point
		_shift_credits_vertically(false)
	
	if not Credits.is_position_top(credits_position) and Credits.is_position_top(old_credits_position):
		# move credits to a low position; show the header and lower the fade out point
		_shift_credits_vertically(true)
	
	if Credits.is_position_left(credits_position) and not Credits.is_position_left(old_credits_position):
		# move credits to a left position; shift everything horizontally
		_shift_credits_horizontally(LINES_POSITION_LEFT)
	
	if Credits.is_position_center(credits_position) and not Credits.is_position_center(old_credits_position):
		# move credits to a center position; shift everything horizontally
		_shift_credits_horizontally(LINES_POSITION_CENTER)
	
	if Credits.is_position_right(credits_position) and not Credits.is_position_right(old_credits_position):
		# move credits to a right position; shift everything horizontally
		_shift_credits_horizontally(LINES_POSITION_RIGHT)


func set_target_header_letter_for_piece(piece_index: int, header_letter_index: int) -> void:
	_credits_pieces.set_target_header_letter_for_piece(piece_index, header_letter_index)


## Adjusts the fade_out_point and shows or hides the header.
func _shift_credits_vertically(header_visible: bool) -> void:
	_vertical_tween = Utils.recreate_tween(self, _vertical_tween).set_parallel(true)
	_vertical_tween.tween_property(header, "modulate", \
			Color.white if header_visible else Color.transparent, 0.3).set_delay(0.7)
	_vertical_tween.tween_property(_fade_out_point, "position", \
			FADE_OUT_POINT_POSITION_BOTTOM if header_visible else FADE_OUT_POINT_POSITION_TOP, 1.5)


## Smoothly moves the credits horizontally to a new position.
func _shift_credits_horizontally(new_lines_position: Vector2) -> void:
	_horizontal_tween = Utils.recreate_tween(self, _horizontal_tween) \
			.set_parallel(true).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	_horizontal_tween.tween_property(_scrolling_container, "rect_position", new_lines_position, 0.5)


func _initialize_line(credits_line: CreditsLine) -> void:
	credits_line.velocity = velocity
	credits_line.fade_in_point_path = _fade_in_point.get_path()
	credits_line.fade_out_point_path = _fade_out_point.get_path()
	credits_line.position = Vector2(20, _fade_in_point.position.y + Credits.FADE_RANGE)
	_lines.add_child(credits_line)
