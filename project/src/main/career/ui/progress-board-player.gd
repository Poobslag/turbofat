extends Control
## Draws the player's chalk graphics on the progress board.
##
## This includes two components: a player graphic and a 'steps remaining' label.

## The maximum height in pixels the player's chalk graphics bounce while advancing.
const MAX_BOUNCE_HEIGHT := 40.0

## The lowest pitch for the player move sound.
const PLAYER_MOVE_SOUND_PITCH_SCALE_MIN := 0.9

## The highest pitch for the player move sound.
const PLAYER_MOVE_SOUND_PITCH_SCALE_MAX := 1.1

export (NodePath) var trail_path

## The visual spot where the player has advanced.
##
## When animating, this represents the player's target position.
var spots_travelled: int setget set_spots_travelled

## The visual spot where the player's chalk graphic should be drawn.
##
## When animating, this represents the player's current position. It can fall between two points, which is why it is a
## float and not an int.
var visual_spots_travelled: float setget set_visual_spots_travelled

## The height in pixels the player's chalk graphics bounce while advancing.
var _bounce_height := MAX_BOUNCE_HEIGHT

## The number label above the player's head which shows how far they will advance.
onready var _label := $Label

## Sprite which shows a chalk graphic of the player.
onready var _sprite: Sprite = $PlayerSprite

## Animates the player's chalk graphic to wave its arms.
onready var _sprite_animation_player := $PlayerSprite/AnimationPlayer
onready var _trail: ProgressBoardTrail = get_node(trail_path)

## Tweens the player's chalk graphic position along the trail.
onready var _tween: Tween = $Tween

## Plays a 'donk' sound as the player's chalk graphic bounces along the trail.
onready var _player_move_sound := $PlayerMoveSound

func _ready() -> void:
	refresh()


## Animates the player's chalk graphic to move along the trail.
##
## The player's chalk graphic bounces along the trail, playing sound effects which increase in pitch. A number over the
## player's head counts down, '3, 2, 1...' as they bounce.
##
## This can also move the player backwards. When moving backward, the sound effects decrease in pitch and the number
## is shown in red, '-3, -2, -1...'
##
## Parameters:
## 	'new_spots_travelled': The visual spot where the player should advance to.
##
## 	'duration': The duration in seconds the player should take to advance.
func play(new_spots_travelled: int, duration: float) -> void:
	# immediately assign spots_travelled; we use this for calculating the label
	spots_travelled = new_spots_travelled
	
	# calculate bounce height
	var bounce_factor := inverse_lerp(5.0, 1.0, clamp(duration, 1.0, 4.0))
	_bounce_height = MAX_BOUNCE_HEIGHT * lerp(0.10, 1.00, bounce_factor)
	
	# initialize the label
	_label.visible = true
	
	# launch the movement tween, causing the player sprite to move along the path
	_tween.remove_all()
	_tween.interpolate_property(self, "visual_spots_travelled", null, new_spots_travelled,
			duration)
	_tween.start()
	
	var starting_pitch := \
			PLAYER_MOVE_SOUND_PITCH_SCALE_MAX if _moving_backward() else PLAYER_MOVE_SOUND_PITCH_SCALE_MIN
	_player_move_sound.pitch_scale = starting_pitch


## Updates the sprite sheet frame, 'steps remaining' label and player position.
func refresh() -> void:
	if PlayerData.career.current_region().has_flag(CareerRegion.FLAG_NO_SENSEI):
		_sprite_animation_player.play("alone")
	else:
		_sprite_animation_player.play("default")
	
	if PlayerData.career.show_progress == Careers.ShowProgress.ANIMATED:
		_label.visible = true
	else:
		_label.visible = false
	
	var new_font_color := Color("ffff5555") if _moving_backward() else Color.white
	_label.set("custom_colors/font_color", new_font_color)
	
	_refresh_visual_spots_travelled()


func set_spots_travelled(new_spots_travelled: int) -> void:
	spots_travelled = new_spots_travelled
	visual_spots_travelled = new_spots_travelled
	_refresh_visual_spots_travelled()


func set_visual_spots_travelled(new_visual_spots_travelled: float) -> void:
	visual_spots_travelled = new_visual_spots_travelled
	_refresh_visual_spots_travelled()


## Returns 'true' if the player is currently moving backwards along the trail.
##
## When moving backwards, different sounds play and the number label is shown in red.
func _moving_backward() -> bool:
	return spots_travelled < visual_spots_travelled


## Updates the player's position and number label based on the 'visual_spots_travelled' value.
##
## Also plays the 'donk' sound as the player's graphics bounce along the trail.
func _refresh_visual_spots_travelled() -> void:
	if not is_inside_tree():
		return
	
	# update the player's position
	rect_position = _trail.get_spot_position(visual_spots_travelled)
	
	# Update the player's offset for a bouncing effect. We convert the fractional part of the visual spots travelled
	# into a parabola following the formula 'y = -(2x - 1)^2 + 1'
	var bounce_percent := visual_spots_travelled - int(visual_spots_travelled)
	bounce_percent = -4 * pow(bounce_percent, 2) + 4 * bounce_percent
	_sprite.offset.y = -_bounce_height * bounce_percent
	
	# update the label's text
	var old_text: String = _label.text
	var new_text: String
	if spots_travelled < visual_spots_travelled:
		new_text = str(floor(spots_travelled - visual_spots_travelled))
	else:
		new_text = str(ceil(spots_travelled - visual_spots_travelled))
	if old_text != new_text:
		_label.text = new_text
	
	# Play a 'donk' sound as the player's graphics bounce along the trail. We only play this when the tween is
	# active to avoid playing a sound effect when the progress board is initialized.
	if old_text != new_text and _tween.is_active():
		var target_pitch := \
				PLAYER_MOVE_SOUND_PITCH_SCALE_MIN if _moving_backward() else PLAYER_MOVE_SOUND_PITCH_SCALE_MAX
		_player_move_sound.pitch_scale = lerp(_player_move_sound.pitch_scale, target_pitch, 0.05)
		_player_move_sound.play()
