class_name TimerGroup
extends Node
## Manages a group of one-shot timers so that they can be cleaned up later.
##
## Godot's typical approach to running code after a delay is `yield(get_tree().create_timer(0.5), "timeout"`. This
## causes errors in asynchronous scenarios, such as restarting a level before the end screen pops up, or quitting to
## the main menu before an animation finishes. Instead of the following code:
##
## 	yield(get_tree().create_timer(0.5), "timeout")
## 	do_something()
##
## TimerGroup enables the following code:
##
## 	timer_group.start_timer(0.5).connect(self, "do_something")
##
## These timers will be cleaned up if the player changes scenes, or can be interrupted by calling TimerGroup.clear().

## Creates and starts a one-shot timer.
##
## This timer is freed when it times out or when the TimerGroup is cleared.
##
## Parameters:
## 	'wait_time': The amount of time to wait. A value of '0.0' will result in an error.
##
## Returns:
## 	Timer which has been added to the scene tree, and is currently active.
func start_timer(wait_time: float) -> Timer:
	var timer := add_timer(wait_time)
	timer.start()
	return timer


## Creates a one-shot timer, but does not start it.
##
## This timer is freed when it times out or when the TimerGroup is cleared.
##
## Parameters:
## 	'wait_time': The amount of time to wait. A value of '0.0' will result in an error.
##
## Returns:
## 	Timer which has been added to the scene tree, but is not yet active.
func add_timer(wait_time: float) -> Timer:
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = wait_time
	timer.connect("timeout", self, "_on_Timer_timeout_queue_free", [timer])
	add_child(timer)
	return timer


## Frees all timers.
func clear() -> void:
	for child in get_children():
		child.queue_free()


## When a timer times out, we free it.
func _on_Timer_timeout_queue_free(timer: Timer) -> void:
	if timer:
		timer.queue_free()
