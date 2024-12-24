extends Node
## Emits signals when the scene tree is paused or unpaused, and manages a lock system for pausing.

## emitted when the scene tree is paused or unpaused
signal paused_changed(value)

var _paused: bool

## Set of request ids representing scripts which currently want the game to remain paused.
##
## key: (String) pause request id
## value: true
var _pausers := {}

func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS


## Purges all pause requests and unpauses the game.
func reset() -> void:
	if not is_inside_tree():
		return
	_pausers.clear()
	get_tree().paused = false


func _process(_delta: float) -> void:
	if not is_inside_tree():
		return
	if get_tree().paused != _paused:
		_paused = get_tree().paused
		emit_signal("paused_changed", _paused)


## Adds or removes a request for the game to pause.
##
## The game will pause when any script wants the game to pause. The game will unpause when all scripts want the game
## to unpause.
##
## Parameters:
## 	'request_id': A request id like 'settings-menu' representing a script which wants the game to remain paused.
##
## 	'paused': 'true' to pause, 'false' to unpause.
func toggle_pause(request_id: String, paused: bool) -> void:
	if not is_inside_tree():
		return
	if paused:
		_pausers[request_id] = true
	else:
		_pausers.erase(request_id)
	
	get_tree().paused = false if _pausers.empty() else true
