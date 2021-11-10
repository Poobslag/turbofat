extends Node
## Starts and stops level-specific timers during a puzzle.
##
## Some levels define behavior where something happens every 5 seconds. These timer definitions are kept in the
## LevelTimers script, but the actual timer objects which count down are kept here.

## The maximum amount of timers which a level can define
const MAX_TIMER_COUNT := 1

## key: timer index
## value: an enum from LevelTriggerPhase for the timer's trigger
const PHASES_BY_TIMER_INDEX := {
	0: LevelTrigger.TIMER_0,
}

func _ready() -> void:
	PuzzleState.connect("game_started", self, "_on_PuzzleState_game_started")
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")
	
	# create placeholder timers. different levels might start some, all or none of these timers
	for i in range(MAX_TIMER_COUNT):
		var timer := Timer.new()
		timer.connect("timeout", self, "_on_Timer_timeout", [i])
		add_child(timer)


## Starts any timers needed for the current level.
func _on_PuzzleState_game_started() -> void:
	for timer_index in range(CurrentLevel.settings.timers.get_timer_count()):
		var timer: Timer = get_child(timer_index)
		timer.start(CurrentLevel.settings.timers.get_timer_interval(timer_index))


## Stops any timers needed for the current level.
func _on_PuzzleState_game_ended() -> void:
	for i in range(MAX_TIMER_COUNT):
		var timer: Timer = get_child(i)
		timer.stop()


## Runs all triggers for the specified timer.
func _on_Timer_timeout(timer_index: int) -> void:
	CurrentLevel.settings.triggers.run_triggers(PHASES_BY_TIMER_INDEX[timer_index])
