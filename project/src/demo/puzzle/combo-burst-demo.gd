extends Node
## Shows off the combo bursts.
##
## Keys:
## 	[1]: Show an x10 combo burst.
## 	[3]: Show an x30 combo burst.
## 	[5]: Show an x50 combo burst.
## 	[0]: Show an x100 combo burst.

export (PackedScene) var ComboBurstScene: PackedScene

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_1: _add_combo_burst(10)
		KEY_3: _add_combo_burst(30)
		KEY_5: _add_combo_burst(50)
		KEY_0: _add_combo_burst(100)


func _add_combo_burst(combo: int) -> void:
	var combo_burst := ComboBurstScene.instance()
	combo_burst.position = Global.window_size / 2
	combo_burst.combo = combo
	combo_burst.scale = Vector2(2, 2)
	add_child(combo_burst)
