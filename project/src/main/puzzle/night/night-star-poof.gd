class_name NightStarPoof
extends Node2D
## Star poof spawned when the player clears a row containing vegetables during night mode.

func _ready() -> void:
	## emit four stars which are approximately orthoganally perpendicular
	for poof in [$Poof1, $Poof2, $Poof3, $Poof4]:
		poof.emitting = true


func _on_Timer_timeout() -> void:
	queue_free()
