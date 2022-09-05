extends Sprite
## A puzzle piece which appears on the loading screen.
##
## The puzzle piece has a 3-part lifecycle:
## 	1. Flying towards the loading bar from the 'source' to the 'target'
## 	2. Crawling along the loading bar at a constant rate
## 	3. Fading out and deleting itself

## The speed at which pieces are launched from the orb
const INITIAL_SPEED := 600

## The duration for pieces to float towards the loading bar
const PIECE_FLIGHT_DURATION := 1.0

## The speed at which pieces crawl along the loading bar
const CRAWL_SPEED := 120

## The X coordinate which pieces crawl past on the loading bar, which makes them fade out
const FADE_OUT_X := 80

## The duration it takes pieces to fade out when they crawl off left side of the loading bar
const FADE_OUT_DURATION := 0.3

const PIECE_COLORS_BY_FRAME := [
	Color("ff636d"), # T (V-Block)
	Color("ffb474"), # u (U-Block)
	Color("ffef7d"), # r (L-Block)
	Color("94ff82"), # b (Q-Block)
	Color("82fffb"), # o (O-Block)
	Color("82baff"), # f (J-Block)
	Color("b182ff"), # a (P-Block)
	Color("ff7afb"), # t (T-Block)
]

## The pieces's position/velocity/rotation as launched from the orb, without homing them towards the loading bar
var _source_position: Vector2
var _source_velocity: Vector2
var _source_rotation: float

## The pieces's target position/rotation on the loading bar, ignoring how they were originally launched
var _target_position: Vector2
var _target_rotation: float

## The number of seconds elapsed since the piece was launched
var _total_time: float

## How the piece should wobble on the loading bar
var _wobble_amount := rand_range(0.15, 0.30)
var _wobble_period := rand_range(0.98, 1.63)
var _wobble_offset := rand_range(0, 10)

## 'true' if the piece is colored, having landed on the loading bar
var _colored := false

## 'true' if the piece is fading out, having crawled off the left side of the loading bar
var _fading := false

## the progress bar the piece should home in on
var _progress_bar: LoadingProgressBar

## particles emitted when the piece hits the loading bar
onready var _particles := $Particles

## Parameters:
## 	'init_orb': The orb which is launching this puzzle piece
##
## 	'init_progress_bar': The progress bar this puzzle piece should home in on
func initialize(init_orb: LoadingOrb, init_progress_bar: LoadingProgressBar) -> void:
	_progress_bar = init_progress_bar
	scale = init_orb.scale
	modulate = init_orb.modulate
	_source_position = init_orb.position
	_source_velocity = init_orb.pop_launch_dir() * INITIAL_SPEED
	_source_rotation = init_orb.rotation
	frame = init_orb.frame
	
	_refresh()


func _process(delta: float) -> void:
	_total_time += delta
	
	# update source position/rotation
	_source_position += _source_velocity * delta
	
	# update target position/rotation
	if _total_time > PIECE_FLIGHT_DURATION:
		_target_position += Vector2.LEFT * CRAWL_SPEED * delta
	else:
		_target_position = _progress_bar.progress_point()
	
	_refresh()


## Recalculates our position/rotation based on whether we're flying/crawling and how much time has elapsed.
func _refresh() -> void:
	_target_rotation = _source_rotation + _wobble_amount * sin(_wobble_period * (_total_time + _wobble_offset))
	
	# lerp between source/target
	var flight_amount := clamp(_total_time / PIECE_FLIGHT_DURATION, 0, 1)
	flight_amount = pow(flight_amount, 1.5)
	position = lerp(_source_position, _target_position, flight_amount)
	rotation = lerp(_source_rotation, _target_rotation, flight_amount)
	
	if _total_time > PIECE_FLIGHT_DURATION and not _colored:
		_colored = true
		modulate = PIECE_COLORS_BY_FRAME[frame]
		_particles.emitting = true
	
	if _total_time > PIECE_FLIGHT_DURATION and position.x < FADE_OUT_X and not _fading:
		# if we're at our target position and it's below a threshold, fade out
		_fading = true
		var tween := create_tween()
		tween.tween_property(self, "modulate", Utils.to_transparent(modulate), FADE_OUT_DURATION)
		tween.connect("finished", self, "_on_FadeTween_finished")


func _on_FadeTween_finished() -> void:
	queue_free()
