class_name LevelTriggers
"""
Triggers which cause strange things to happen during a level.

A level can contain any number of triggers, and each trigger makes something happen at a specific time. For example, a
trigger might rotate the pieces in the piece queue every 2 seconds, or a trigger might toggle the playfield invisible
every time the player places a piece.
"""

# key: An enum from LevelTrigger.LevelTriggerPhase
# value: An array of LevelTriggers which should happen during that phase
var _triggers := {}

"""
Runs all triggers for the specified phase.

Parameters:
	'phase': An enum from LevelTrigger.LevelTriggerPhase corresponding to the triggers to run.
	
	'event_params': (Optional) Phase-specific metadata used to decide whether the trigger should fire
"""
func run_triggers(phase: int, event_params: Dictionary = {}) -> void:
	if not _triggers.has(phase):
		return
	
	for trigger in _triggers.get(phase, []):
		if trigger.should_run(phase, event_params):
			trigger.run()


func from_json_array(json: Array) -> void:
	for trigger_json in json:
		var trigger := LevelTrigger.new()
		trigger.from_json_dict(trigger_json)
		_add_trigger(trigger)


func _add_trigger(trigger: LevelTrigger) -> void:
	for phase in trigger.phases:
		if not _triggers.has(phase):
			_triggers[phase] = []
		_triggers[phase].append(trigger)
