extends Node
## Demonstrates the progress board's animations and states.
##
## Keys:
## 	[0-9]: Set the time of day, 0=11:00 am, 6=10:00 pm.
## 	[Shift + 0]: Prepare a career scenario where the player is 3 steps from a boss level for Poki Desert.
## 	[Q]: Hide the progress board.
## 	[W]: Briefly show the progress board, but do not animate.
## 	[E]: Briefly show and animate the progress board.
## 	[R]: Permanently show the progress board.
## 	[S]: Toggle whether or not the sensei accompanies the player in this chapter.
## 	[I]: Show the intro board.
## 	[L]: Toggle whether or not the player topped out.
## 	[Z-M]: Animate the player advancing 0-25 steps.
## 	[Shift + Z-M]: Animate the player going backward 0-25 steps.
## 	[=/-]: Move the player forward/backward on the progress board.

onready var _progress_board := $ProgressBoard
onready var _label := $Label
onready var _player := $ProgressBoard/ChalkboardRegion/Swoosher/Player

func _ready() -> void:
	PlayerData.career.hours_passed = 2
	PlayerData.career.show_progress = Careers.ShowProgress.STATIC
	_progress_board.show_progress()
	_refresh_label()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_Q:
			_progress_board.suppress_hide = false
			PlayerData.career.show_progress = Careers.ShowProgress.NONE
			_progress_board.show_progress()
		KEY_W:
			_progress_board.suppress_hide = false
			PlayerData.career.show_progress = Careers.ShowProgress.STATIC
			_progress_board.show_progress()
		KEY_E:
			_progress_board.suppress_hide = false
			PlayerData.career.show_progress = Careers.ShowProgress.ANIMATED
			_progress_board.show_progress()
		KEY_R:
			_progress_board.suppress_hide = true
			PlayerData.career.show_progress = Careers.ShowProgress.STATIC
			_progress_board.show_progress()
		KEY_I:
			_progress_board.show_intro()
		KEY_L:
			PlayerData.career.lost = not PlayerData.career.lost
		KEY_Z:
			_animate_progress(0 * (-1 if Input.is_key_pressed(KEY_SHIFT) else 1))
		KEY_X:
			_animate_progress(1 * (-1 if Input.is_key_pressed(KEY_SHIFT) else 1))
		KEY_C:
			_animate_progress(2 * (-1 if Input.is_key_pressed(KEY_SHIFT) else 1))
		KEY_V:
			_animate_progress(3 * (-1 if Input.is_key_pressed(KEY_SHIFT) else 1))
		KEY_B:
			_animate_progress(5 * (-1 if Input.is_key_pressed(KEY_SHIFT) else 1))
		KEY_N:
			_animate_progress(10 * (-1 if Input.is_key_pressed(KEY_SHIFT) else 1))
		KEY_M:
			_animate_progress(25 * (-1 if Input.is_key_pressed(KEY_SHIFT) else 1))
		KEY_S:
			if PlayerData.career.current_region().has_flag(CareerRegion.FLAG_NO_SENSEI):
				PlayerData.career.current_region().flags.erase(CareerRegion.FLAG_NO_SENSEI)
			else:
				PlayerData.career.current_region().flags[CareerRegion.FLAG_NO_SENSEI] = true
			_player.refresh()
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			if Input.is_key_pressed(KEY_SHIFT) and Utils.key_scancode(event) == KEY_0:
				PlayerData.career.distance_travelled = 28
				PlayerData.career.best_distance_travelled = 28
				_progress_board.refresh()
			else:
				PlayerData.career.hours_passed = Utils.key_num(event)
				_progress_board.refresh()
		KEY_EQUAL:
			PlayerData.career.show_progress = Careers.ShowProgress.STATIC
			PlayerData.career.distance_earned = 0
			PlayerData.career.distance_travelled += 10 if Input.is_key_pressed(KEY_SHIFT) else 1
			_progress_board.refresh()
		KEY_MINUS:
			PlayerData.career.show_progress = Careers.ShowProgress.STATIC
			PlayerData.career.distance_earned = 0
			PlayerData.career.distance_travelled -= 10 if Input.is_key_pressed(KEY_SHIFT) else 1
			PlayerData.career.distance_travelled = int(max(PlayerData.career.distance_travelled, 0))
			_progress_board.refresh()
	_refresh_label()


func _refresh_label() -> void:
	var new_text := ""
	new_text += "lost=%s\n" % [PlayerData.career.lost]
	new_text += "distance_earned=%s\n" % [PlayerData.career.distance_earned]
	new_text += "distance_travelled=%s\n" % [PlayerData.career.distance_travelled]
	new_text += "show_progress=%s\n" % \
			[Utils.enum_to_snake_case(Careers.ShowProgress, PlayerData.career.show_progress)]
	
	_label.text = new_text.strip_edges()


func _animate_progress(distance_earned: int) -> void:
	PlayerData.career.distance_earned = distance_earned
	if PlayerData.career.current_region().length == Careers.MAX_DISTANCE_TRAVELLED:
		PlayerData.career.distance_travelled = int(min(PlayerData.career.distance_travelled,
				PlayerData.career.current_region().start + 5))
	PlayerData.career.show_progress = Careers.ShowProgress.ANIMATED
	PlayerData.career.progress_board_start_distance_travelled = PlayerData.career.distance_travelled
	PlayerData.career.distance_travelled += distance_earned
	_progress_board.refresh()
	_progress_board.play()
