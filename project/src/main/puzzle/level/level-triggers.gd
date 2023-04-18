class_name LevelTriggers
## Triggers which cause strange things to happen during a level.
##
## A level can contain any number of triggers, and each trigger makes something happen at a specific time. For example,
## a trigger might rotate the pieces in the piece queue every 2 seconds, or a trigger might toggle the playfield
## invisible every time the player places a piece.

## key: (int) An enum from LevelTrigger.LevelTriggerPhase
## value: (Array) LevelTriggers which should happen during that phase
var triggers := {}

## Runs all triggers for the specified phase.
##
## Parameters:
## 	'phase': An enum from LevelTrigger.LevelTriggerPhase corresponding to the triggers to run.
##
## 	'event_params': (Optional) Phase-specific metadata used to decide whether the trigger should fire
func run_triggers(phase: int, event_params: Dictionary = {}) -> void:
	if not triggers.has(phase):
		return
	
	for trigger in triggers.get(phase, []):
		if trigger.should_run(phase, event_params):
			trigger.run()


func from_json_array(json: Array) -> void:
	for trigger_json in json:
		var trigger := LevelTrigger.new()
		trigger.from_json_dict(trigger_json)
		_add_trigger(trigger)


func to_json_array() -> Array:
	var appended_triggers := {}
	var result := []
	for phase in triggers:
		for trigger in triggers[phase]:
			if appended_triggers.has(trigger):
				# already appended
				continue

			appended_triggers[trigger] = true
			result.append(trigger.to_json_dict())
	return result


func is_default() -> bool:
	return triggers.empty()


## Returns 'true' if this level contains a trigger with the specified effect.
##
## Parameters:
## 	'effect_type': A LevelTriggerEffect class such as 'InsertLineEffect.LevelTriggerEffects'
func has_effect(effect_type) -> bool:
	var result := false
	
	for phase in triggers:
		for trigger_obj in triggers[phase]:
			var trigger: LevelTrigger = trigger_obj
			if trigger.effect is effect_type:
				result = true
				break
		
		if result:
			break
	
	return result


func _add_trigger(trigger: LevelTrigger) -> void:
	for phase in trigger.phases:
		if not triggers.has(phase):
			triggers[phase] = []
		triggers[phase].append(trigger)
