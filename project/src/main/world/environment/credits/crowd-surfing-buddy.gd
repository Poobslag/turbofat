class_name CrowdSurfingBuddy
extends Creature
## Creature who bounces in a straight line alongside another creature, for a unique cutscene where the player and Fat
## Sensei crowd surf on a cheering crowd.

enum LeaderOrFollower {
	NONE,
	LEADER,
	FOLLOWER
}

## Thresholds where the creatures slow down or speed up to stay close to each other.
const TOO_CLOSE_THRESHOLD := 80.0
const TOO_FAR_THRESHOLD := 240.0

const AVERAGE_TRAVEL_SPEED := 60.0

## Rate at which to bounce. This is synchronized with the song "Sugar Crash" for the end credits.
const BOUNCES_PER_SECOND := 2.05000

## Creature's elevation at the bottom of their bounce.
const SURF_HEIGHT := 230
## Distance from the lowest to the highest point of the creature's bounce.
const BOUNCE_HEIGHT := 60

const MOOD_TIMER_MAX_DURATION := 5.9

## path to the other creature whom this creature is walking with
export (NodePath) var buddy_path: NodePath

## path to the destination. the leader stops moving if they reach this destination
export (NodePath) var destination_path: NodePath

## designates this creature as either a leader or follower
export (LeaderOrFollower) var leader_or_follower: int

var _velocity: Vector2

## the creature's desired velocity, based on how close they are to their buddy and destination
var _desired_velocity: Vector2

var _elevation_tween: SceneTreeTween

## other creature whom this creature is walking with
onready var _buddy: Creature = get_node(buddy_path)

## other creature whom this creature is walking with
onready var _destination: Node2D = get_node(destination_path)

## periodically changes the creature's mood and orientation
onready var _mood_timer := $MoodTimer

func _ready() -> void:
	stop()


func _process(delta: float) -> void:
	_velocity = lerp(_velocity, _desired_velocity, 0.01)
	position += _velocity * delta


## Stops the timers and tweens which handle the creature's mood and movement.
func stop() -> void:
	# stop bounce animation
	_elevation_tween = Utils.kill_tween(_elevation_tween)
	set_elevation(SURF_HEIGHT)
	
	# stop mood timer
	_mood_timer.stop()
	play_mood(Creatures.Mood.DEFAULT)
	
	# stop movement
	set_process(false)
	_desired_velocity = Vector2.ZERO
	_velocity = Vector2.ZERO


## Initializes the timers and tweens which handle the creature's mood and movement.
func play_bounce_animation() -> void:
	# start bounce animation
	_elevation_tween = Utils.recreate_tween(self, _elevation_tween)
	_elevation_tween.tween_property(self, "elevation", SURF_HEIGHT + BOUNCE_HEIGHT, 0.5 / BOUNCES_PER_SECOND) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_elevation_tween.tween_property(self, "elevation", SURF_HEIGHT, 0.5 / BOUNCES_PER_SECOND) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_elevation_tween.set_loops()
	
	# start mood timer
	_randomize_mood()
	_mood_timer.start(MOOD_TIMER_MAX_DURATION * randf())
	
	# start movement
	set_process(true)
	_refresh_desired_velocity()
	_velocity = _desired_velocity


## Assigns the creature a random mood and orientation.
##
## Creatures usually face left and smile, but they rotate between a few different moods and orientations.
func _randomize_mood() -> void:
	# randomize mood; usually a smile, but sometimes a laugh
	if randf() < 0.7:
		play_mood(Creatures.Mood.SMILE0)
	elif randf() < 0.7:
		play_mood(Creatures.Mood.LAUGH0)
	elif randf() < 0.7:
		play_mood(Creatures.Mood.LAUGH1)
	else:
		play_mood(Creatures.Mood.SMILE1)
	
	# randomize orientation; usually left, but sometimes right
	var face_right_chance := 0.4 if leader_or_follower == LeaderOrFollower.LEADER else 0.2
	if randf() < face_right_chance:
		set_orientation(Creatures.SOUTHEAST)
	else:
		set_orientation(Creatures.SOUTHWEST)


## Recalculates the creature's desired velocity, based on how close they are to their buddy and destination.
func _refresh_desired_velocity() -> void:
	# a multiplier for AVERAGE_TRAVEL_SPEED for how fast the creature should move
	var desired_speed_factor := 0.0
	
	# if the creature has reached their destination, they stop
	if position.x < _destination.position.x:
		desired_speed_factor = 0.0
	
	# if the creature is behind their buddy, they try to stay close to them
	if position.x >= _destination.position.x and leader_or_follower == LeaderOrFollower.FOLLOWER:
		var distance_threshold := \
				inverse_lerp(TOO_CLOSE_THRESHOLD, TOO_FAR_THRESHOLD, _buddy.position.distance_to(position))
		if distance_threshold >= 1.0:
			desired_speed_factor = 1.5
		elif distance_threshold >= 0.75:
			desired_speed_factor = 1.25
		elif distance_threshold >= 0.25:
			desired_speed_factor = 1.0
		elif distance_threshold > 0.0:
			desired_speed_factor = 0.75
		else:
			desired_speed_factor = 0.5
	
	# if the creature is in front of their buddy, their speed is purely random
	if position.x >= _destination.position.x and leader_or_follower == LeaderOrFollower.LEADER:
		desired_speed_factor = rand_range(0.5, 1.5)
	
	_desired_velocity = Global.to_iso(Vector2(-1, 1) * AVERAGE_TRAVEL_SPEED * desired_speed_factor)


func _on_MoveTimer_timeout() -> void:
	_refresh_desired_velocity()


func _on_MoodTimer_timeout() -> void:
	_randomize_mood()
	
	# randomize the mood timer's duration to keep the creature's emotions from being perfectly synchronized
	_mood_timer.start(MOOD_TIMER_MAX_DURATION * rand_range(0.5, 1.0))
