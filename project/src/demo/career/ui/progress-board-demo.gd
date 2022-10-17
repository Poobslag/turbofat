extends Node
## A demo which shows off the progress board's animations and states.
##
## Keys:
## 	[Q]: Hide the progress board.
## 	[W]: Briefly show the progress board, but do not animate.
## 	[E]: Briefly show and animate the progress board.
## 	[R]: Show the progress board.
## 	[S]: Toggle whether or not the sensei accompanies the player in this chapter.
## 	[0-9]: Set the time of day, 0=11:00 am, 6=10:00 pm.
## 	[=/-]: Move the player forward/backward on the progress board.

onready var _progress_board := $ProgressBoard
onready var _player := $ProgressBoard/ChalkboardRegion/Player

func _ready() -> void:
	PlayerData.career.show_progress = CareerData.ShowProgress.FOREVER
	_progress_board.show_progress()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_Q:
			PlayerData.career.show_progress = CareerData.ShowProgress.NONE
			_progress_board.show_progress()
		KEY_W:
			PlayerData.career.show_progress = CareerData.ShowProgress.STATIC
			_progress_board.show_progress()
		KEY_E:
			PlayerData.career.show_progress = CareerData.ShowProgress.ANIMATED
			_progress_board.show_progress()
		KEY_R:
			PlayerData.career.show_progress = CareerData.ShowProgress.FOREVER
			_progress_board.show_progress()
		KEY_S:
			if PlayerData.career.current_region().has_flag(CareerRegion.FLAG_NO_SENSEI):
				PlayerData.career.current_region().flags.erase(CareerRegion.FLAG_NO_SENSEI)
			else:
				PlayerData.career.current_region().flags[CareerRegion.FLAG_NO_SENSEI] = true
			
			_player.refresh()
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			PlayerData.career.hours_passed = Utils.key_num(event)
			if Input.is_key_pressed(KEY_SHIFT):
				_progress_board.refresh_and_animate()
			else:
				_progress_board.refresh()
		KEY_EQUAL:
			PlayerData.career.distance_travelled += 1
			_progress_board.refresh()
		KEY_MINUS:
			PlayerData.career.distance_travelled -= 1
			_progress_board.refresh()
