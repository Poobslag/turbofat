extends Node
## A unique cutscene where the player and Fat Sensei crowd surf on a cheering crowd.

onready var _crowd_surf_director: CrowdSurfDirector = $Environment/CrowdSurfDirector

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


## Plays the cutscene animation.
func play() -> void:
	_crowd_surf_director.play()
