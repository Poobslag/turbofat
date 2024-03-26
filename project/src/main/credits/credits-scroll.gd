class_name CreditsScroll
extends Control
## Credits scene which shows scrolling credits.
##
## Contains methods for adding visual elements to the credits and moving them around, which are called by a
## CreditsDirector.

## The vertical position where the credits fade out in TOP or BOTTOM positions.
const FADE_OUT_POINT_POSITION_TOP := Vector2.ZERO
const FADE_OUT_POINT_POSITION_BOTTOM := Vector2(0, 110)

## The horizontal positions for the movie which plays alongside the credits.
const MOVIE_POSITION_OFFSCREEN_LEFT := Vector2(-512, 0)
const MOVIE_POSITION_LEFT := Vector2(0, 0)
const MOVIE_POSITION_RIGHT := Vector2(512, 0)
const MOVIE_POSITION_OFFSCREEN_RIGHT := Vector2(1024, 0)

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

## 'true' if the credits movie should be playing onscreen. The credits movie will still not be visible if the credits
## position is CENTER_BOTTOM or CENTER_TOP, since the lines will be in the way.
var movie_visible: bool = false setget set_movie_visible

var _movie_tween_x: SceneTreeTween

var _lines_tween_x: SceneTreeTween
var _lines_tween_y: SceneTreeTween

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
onready var _left_transformation_target := $FixedContainer/ScrollingContainer/LeftTransformationTarget
onready var _right_transformation_target := $FixedContainer/ScrollingContainer/RightTransformationTarget

## Container for scrolling lines.
onready var _lines := $FixedContainer/ScrollingContainer/Lines

## Puzzle pieces which fly out of the floating orb.
onready var _credits_pieces: CreditsPieces = $FixedContainer/OrbHolder/Pieces

## Movie which plays alongside the credits lines.
onready var _movie: Node2D = $Movie

func _ready() -> void:
	MusicPlayer.play_credits_bgm()
	
	# initialize the movie to visible but transparent; this way the tweens don't have to toggle the 'visible' property
	_movie.visible = true
	_movie.modulate = Color.transparent


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
	
	_shift_credits(old_credits_position, new_credits_position)
	_shift_movie(movie_visible, movie_visible, old_credits_position, new_credits_position)


func set_movie_visible(new_movie_visible: bool) -> void:
	var old_movie_visible := movie_visible
	movie_visible = new_movie_visible
	
	_shift_movie(old_movie_visible, new_movie_visible, credits_position, credits_position)


## Makes a piece target a letter in the header.
func set_target_header_letter_for_piece(piece_index: int, header_letter_index: int) -> void:
	_credits_pieces.set_target_header_letter_for_piece(piece_index, header_letter_index)


## Makes a piece target a pinup on the left side.
func set_left_transformation_target_for_piece(piece_index: int) -> void:
	# calculate the position of the left transformation target relative to the orb holder
	var target_position: Vector2 = \
			_left_transformation_target.get_global_transform().origin \
			- orb.get_parent().get_global_transform().origin
	
	_credits_pieces.set_target_position_for_piece(piece_index, target_position)


## Makes a piece target a pinup on the right side.
func set_right_transformation_target_for_piece(piece_index: int) -> void:
	# calculate the position of the left transformation target relative to the orb holder
	var target_position: Vector2 = \
			_right_transformation_target.get_global_transform().origin \
			- orb.get_parent().get_global_transform().origin
	
	_credits_pieces.set_target_position_for_piece(piece_index, target_position)


## Shifts the title credits lines based on the credits position.
func _shift_credits(old_credits_position: int, new_credits_position: int) -> void:
	if Credits.is_position_top(new_credits_position) and not Credits.is_position_top(old_credits_position):
		# move credits to a top position; hide the header and raise the fade out point
		_shift_lines_vertically(false)
	
	if not Credits.is_position_top(new_credits_position) and Credits.is_position_top(old_credits_position):
		# move credits to a low position; show the header and lower the fade out point
		_shift_lines_vertically(true)
	
	if Credits.is_position_left(new_credits_position) and not Credits.is_position_left(old_credits_position):
		# move credits to a left position; shift everything horizontally
		_shift_lines_horizontally(LINES_POSITION_LEFT)
	
	if Credits.is_position_center(new_credits_position) and not Credits.is_position_center(old_credits_position):
		# move credits to a center position; shift everything horizontally
		_shift_lines_horizontally(LINES_POSITION_CENTER)
	
	if Credits.is_position_right(new_credits_position) and not Credits.is_position_right(old_credits_position):
		# move credits to a right position; shift everything horizontally
		_shift_lines_horizontally(LINES_POSITION_RIGHT)


## Shifts the credits movie based on the credits position.
func _shift_movie(old_movie_visible: bool, new_movie_visible: bool, \
		old_credits_position: int, new_credits_position: int) -> void:
	
	# The movie swoops offscreen if it's set invisible or blocked by the credit scroll.
	var tweening_out := old_movie_visible and not Credits.is_position_center(old_credits_position) \
			and (new_credits_position != old_credits_position or new_movie_visible == false)
	
	# The movie swoops onscreen if it's set visible and not blocked by the credits scroll.
	var tweening_in := new_movie_visible and not Credits.is_position_center(new_credits_position) \
			and (new_credits_position != old_credits_position or old_movie_visible == false)
	
	if tweening_out:
		_movie_tween_x = Utils.recreate_tween(self, _movie_tween_x)
		_movie_tween_x.tween_property(_movie, "modulate", Color.transparent, 0.1).set_delay(0.2)
		var new_movie_position: Vector2
		if Credits.is_position_left(old_credits_position):
			new_movie_position = MOVIE_POSITION_OFFSCREEN_RIGHT
		else:
			new_movie_position = MOVIE_POSITION_OFFSCREEN_LEFT
		_movie_tween_x.parallel().tween_property(_movie, "position", new_movie_position, 0.5) \
				.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	
	if tweening_in:
		if not tweening_out:
			_movie_tween_x = Utils.recreate_tween(self, _movie_tween_x)
		
		# Set the movie position so that it swoops in from the correct direction offscreen
		if tweening_out or _movie.position in [MOVIE_POSITION_OFFSCREEN_LEFT, MOVIE_POSITION_OFFSCREEN_RIGHT]:
			var new_source_movie_position: Vector2
			if Credits.is_position_right(new_credits_position):
				new_source_movie_position = MOVIE_POSITION_OFFSCREEN_LEFT
			else:
				new_source_movie_position = MOVIE_POSITION_OFFSCREEN_RIGHT
			_movie_tween_x.tween_callback(_movie, "set", ["position", new_source_movie_position])
		
		_movie_tween_x.tween_property(_movie, "modulate", Color.white, 0.1).set_delay(0.2)
		var new_movie_position: Vector2
		if Credits.is_position_left(new_credits_position):
			new_movie_position = MOVIE_POSITION_RIGHT
		else:
			new_movie_position = MOVIE_POSITION_LEFT
		_movie_tween_x.parallel().tween_property(_movie, "position", new_movie_position, 0.5) \
				.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)


## Adjusts the fade_out_point and shows or hides the header.
func _shift_lines_vertically(header_visible: bool) -> void:
	_lines_tween_y = Utils.recreate_tween(self, _lines_tween_y).set_parallel(true)
	_lines_tween_y.tween_property(header, "modulate", \
			Color.white if header_visible else Color.transparent, 0.3).set_delay(0.7)
	_lines_tween_y.tween_property(_fade_out_point, "position", \
			FADE_OUT_POINT_POSITION_BOTTOM if header_visible else FADE_OUT_POINT_POSITION_TOP, 1.5)


## Smoothly moves the credits horizontally to a new position.
func _shift_lines_horizontally(new_lines_position: Vector2) -> void:
	_lines_tween_x = Utils.recreate_tween(self, _lines_tween_x) \
			.set_parallel(true).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	_lines_tween_x.tween_property(_scrolling_container, "rect_position", new_lines_position, 0.5)


func _initialize_line(credits_line: CreditsLine) -> void:
	credits_line.velocity = velocity
	credits_line.fade_in_point_path = _fade_in_point.get_path()
	credits_line.fade_out_point_path = _fade_out_point.get_path()
	credits_line.position = Vector2(20, _fade_in_point.position.y + Credits.FADE_RANGE)
	_lines.add_child(credits_line)
