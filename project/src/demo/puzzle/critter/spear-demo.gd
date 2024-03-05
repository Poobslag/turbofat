extends Node
## Demo which shows off the spear (asparagus) puzzle critter.
##
## Keys:
## 	[0]: Disappear
## 	[1]: Wait with a '...' bubble
## 	[2]: Wait with a '!' bubble
## 	[3]: Pop into view
## 	[4]: Pop out of view
## 	[5]: Disappear
## 	[D]: Toggle the spear's pop animation duration
## 	[L]: Toggle the spear's length
## 	Arrows: Change the spear's orientation

const POP_ANIM_DURATIONS := [
	0.1, 0.35, 0.75
]

const POP_LENGTHS := [
	100, 300, 500, 700, 900
]

var _pop_anim_duration_index := 2
var _pop_length_index := 1

onready var _spear_narrow := $Spear
onready var _spear_wide := $SpearWide

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_0:
			for spear in [_spear_narrow, _spear_wide]:
				spear.state = Spear.NONE
		KEY_1:
			for spear in [_spear_narrow, _spear_wide]:
				spear.state = Spear.WAITING
		KEY_2:
			for spear in [_spear_narrow, _spear_wide]:
				spear.state = Spear.WAITING_END
		KEY_3:
			for spear in [_spear_narrow, _spear_wide]:
				spear.state = Spear.POPPED_IN
		KEY_4:
			for spear in [_spear_narrow, _spear_wide]:
				spear.state = Spear.POPPED_OUT
		KEY_5:
			for spear in [_spear_narrow, _spear_wide]:
				spear.state = Spear.NONE
		
		KEY_LEFT:
			for spear in [_spear_narrow, _spear_wide]:
				spear.side = Spear.RIGHT
				spear.position.x = Global.window_size.x - 100
		KEY_RIGHT:
			for spear in [_spear_narrow, _spear_wide]:
				spear.side = Spear.LEFT
				spear.position.x = 100
		
		KEY_D:
			_pop_anim_duration_index = (_pop_anim_duration_index + 1) % POP_ANIM_DURATIONS.size()
			for spear in [_spear_narrow, _spear_wide]:
				_pop(spear)
		
		KEY_L:
			_pop_length_index = (_pop_length_index + 1) % POP_LENGTHS.size()
			for spear in [_spear_narrow, _spear_wide]:
				_pop(spear)


func _pop(spear: Spear) -> void:
	spear.pop_duration = POP_ANIM_DURATIONS[_pop_anim_duration_index]
	spear.pop_length = POP_LENGTHS[_pop_length_index]
	
	if spear.state == Spear.POPPED_IN:
		spear.set_state(Spear.NONE)
	else:
		spear.set_state(Spear.POPPED_IN)
