extends Timer
## Timer which randomizes its wait time each time it elapses.

export (float) var min_wait_time := 1.0
export (float) var max_wait_time := 1.0

func _ready() -> void:
	# When the timer is initialized, we randomize its wait time.
	wait_time = rand_range(min_wait_time, max_wait_time)
	connect("timeout", self, "_on_timeout")


## When the timer elapses, we randomize its wait time.
func _on_timeout() -> void:
	wait_time = rand_range(min_wait_time, max_wait_time)
