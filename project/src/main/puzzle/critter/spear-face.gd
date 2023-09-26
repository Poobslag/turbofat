extends Sprite
## Visuals for the face of a spear critter.
##
## Spears periodically blink and change their facial expression.

## Schedules the face to cycle between similar frames for a squigglevision effect.
onready var _wiggle_timer := $WiggleTimer

## Schedules the face to blink.
onready var _start_blink_timer := $StartBlinkTimer

## Schedules the face to re-open their eyes after blinking or squinting.
onready var _open_eyes_timer := $OpenEyesTimer

func _ready() -> void:
	_open_eyes()
	_schedule_blink()


## Closes the face's eyes forcefully and reopens them.
##
## Parameters:
## 	'duration': The duration in seconds to close our eyes.
func squint(duration: float) -> void:
	frame = Utils.randi_range(10, 11)
	_wiggle_timer.start()
	_open_eyes_timer.start(duration)


## Closes the face's eyes for a blink.
func _close_eyes() -> void:
	frame = Utils.randi_range(8, 9)


## Schedules the next blink event.
func _schedule_blink() -> void:
	_start_blink_timer.start(rand_range(6, 8))


## Opens the face's eyes after a squint or blink.
func _open_eyes() -> void:
	frame = Utils.randi_range(0, 7)


## Cycles the face to its next animation frame.
##
## Usually this involves alternating between two similar frames, although if the blink timer or open eyes timer have
## elapsed, this also cycles through the blink animation.
func _on_WiggleTimer_timeout() -> void:
	if _open_eyes_timer.is_stopped() and _start_blink_timer.is_stopped():
		# the spear needs to blink; close their eyes and restart the blink timer
		_close_eyes()
		_schedule_blink()
	elif frame in [8, 9]:
		# the spear finished blinking; open their eyes
		_open_eyes()
	else:
		# the spear is not doing anything special; wiggle their frames
		# warning-ignore:integer_division
		frame = int(frame / 2) * 2 + (1 if randf() < 0.66 else 0)


## When the open eyes timer elapses, we reopen our eyes and schedule the next blink.
func _on_OpenEyesTimer_timeout() -> void:
	_open_eyes()
	_wiggle_timer.start()
	_schedule_blink()
