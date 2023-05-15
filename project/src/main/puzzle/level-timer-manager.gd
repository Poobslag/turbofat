extends Node
## Starts and stops level-specific timers during a puzzle.
##
## Some levels define behavior where something happens every 5 seconds. These timer definitions are kept in the
## LevelTimers script, but the actual timer objects which count down are kept here.

## Maximum amount of timers which a level can define
const MAX_TIMER_COUNT := 10

## key: (int) timer index
## value: (LevelTrigger) timer's trigger
const PHASES_BY_TIMER_INDEX := {
	0: LevelTrigger.TIMER_0,
	1: LevelTrigger.TIMER_1,
	2: LevelTrigger.TIMER_2,
	3: LevelTrigger.TIMER_3,
	4: LevelTrigger.TIMER_4,
	5: LevelTrigger.TIMER_5,
	6: LevelTrigger.TIMER_6,
	7: LevelTrigger.TIMER_7,
	8: LevelTrigger.TIMER_8,
	9: LevelTrigger.TIMER_9,
}

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	PuzzleState.connect("game_started", self, "_on_PuzzleState_game_started")
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")
	
	# create placeholder timers. different levels might start some, all or none of these timers
	for i in range(MAX_TIMER_COUNT):
		var timer := Timer.new()
		timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
		timer.connect("timeout", self, "_on_Timer_timeout", [i])
		add_child(timer)


func _start_all() -> void:
	for timer_index in range(CurrentLevel.settings.timers.get_timer_count()):
		var timer: Timer = get_child(timer_index)
		timer.start(CurrentLevel.settings.timers.get_timer_initial_interval(timer_index))


func _stop_all() -> void:
	for i in range(MAX_TIMER_COUNT):
		var timer: Timer = get_child(i)
		timer.stop()


## Starts any timers needed for the current level.
func _on_PuzzleState_game_started() -> void:
	_start_all()


## Stops any timers needed for the current level.
func _on_PuzzleState_game_ended() -> void:
	_stop_all()


## Stops any timers needed for the current level.
func _on_PuzzleState_game_prepared() -> void:
	_stop_all()


## Runs all triggers for the specified timer.
func _on_Timer_timeout(timer_index: int) -> void:
	CurrentLevel.settings.triggers.run_triggers(PHASES_BY_TIMER_INDEX[timer_index])
	if CurrentLevel.settings.timers.get_timer_initial_interval(timer_index) \
			!= CurrentLevel.settings.timers.get_timer_interval(timer_index):
		var timer: Timer = get_child(timer_index)
		timer.start(CurrentLevel.settings.timers.get_timer_interval(timer_index))
