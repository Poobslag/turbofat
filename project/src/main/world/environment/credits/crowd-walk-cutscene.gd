extends Node
## A unique cutscene where the player and Fat Sensei walk through a cheering crowd.

onready var _crowd_walk_director: CrowdWalkDirector = $Environment/CrowdWalkDirector

onready var _bg := $Bg
onready var _launch_bg := $LaunchBg
onready var _environment := $Environment
onready var _camera := $Camera2D

## Makes the cutscene appear, setting it as the current cutscene within its viewport.
func show() -> void:
	_bg.visible = true
	_launch_bg.visible = false
	_environment.visible = true
	_camera.current = true


## Makes the cutscene disappear, unsetting it as the current cutscene within its viewport.
func hide() -> void:
	_bg.visible = false
	_launch_bg.visible = false
	_environment.visible = false
	_camera.current = false
	_crowd_walk_director.stop()


## Plays the cutscene animation.
##
## Parameters:
## 	'time_until_launch': Delay in seconds until the player and Fat Sensei should be tossed into the air.
func play(time_until_launch: float) -> void:
	_crowd_walk_director.play(time_until_launch)
