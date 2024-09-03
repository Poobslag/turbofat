extends TutorialModule
## Tutorial module for the 'Basic Techniques' tutorial.
##
## Shows messages and advances the player through the tutorial as they complete tasks.

## monitors what the player has done so far during this tutorial
var _line_clears := 0
var _box_clears := 0
var _boxes_built := 0
var _squish_moves := 0
var _snack_stacks := 0

## monitors what the player did with their newest piece
var _did_line_clear := false
var _did_box_clear := false
var _did_build_box := false
var _did_build_cake := false
var _did_squish_move := false

func _ready() -> void:
	PuzzleState.connect("after_game_prepared", self, "_on_PuzzleState_after_game_prepared")
	PuzzleState.connect("game_started", self, "_on_PuzzleState_game_started")
	
	playfield.connect("box_built", self, "_on_Playfield_box_built")
	PuzzleState.connect("after_piece_written", self, "_on_PuzzleState_after_piece_written")
	playfield.connect("line_cleared", self, "_on_Playfield_line_cleared")
	piece_manager.connect("squish_moved", self, "_on_PieceManager_squish_moved")
	piece_manager.connect("piece_spawned", self, "_on_PieceManager_piece_spawned")
	
	if CurrentLevel.settings.other.skip_intro:
		puzzle.hide_buttons()
	else:
		# display a welcome message before the game starts
		hud.set_message(tr("Welcome to Turbo Fat!"
				+ " You seem to already be familiar with this sort of game, so let's dive right in."))


func prepare_tutorial_level() -> void:
	.prepare_tutorial_level()
	match CurrentLevel.settings.id:
		"tutorial/basics_1":
			hud.skill_tally_item("SnackBox").visible = true
			hud.skill_tally_item("BoxClear").visible = true
			hud.set_message(tr("Try making a snack box by arranging two pieces into a square."))
		"tutorial/basics_2":
			hud.skill_tally_item("SquishMove").visible = true
			hud.set_message(tr("Next, try holding soft drop to squish pieces through these gaps."))
		"tutorial/basics_3":
			hud.skill_tally_item("SnackStack").visible = true
			hud.set_message(tr("One last lesson! Try holding soft drop to squish and complete these boxes."))
		"tutorial/basics_4":
			dismiss_sensei([tr("You're a remarkably quick learner." \
					+ " I think I hear some customers!\n\nSee if you can earn ¥100.")])


## Advance to the next level in the tutorial.
##
## The level to advance to depends on what the player's accomplished so far. If they perform squish moves or snack
## boxes before they're instructed to, they can skip parts of the tutorial.
func _advance_level() -> void:
	PuzzleState.level_performance.lost = false
	if CurrentLevel.settings.id == "tutorial/basics_0" and _did_build_cake and _did_squish_move:
		# the player did something crazy; skip the tutorial entirely
		
		# change the level immediately; don't wait for dialog to finish
		var level_id := "tutorial/oh_my"
		PuzzleState.prepare_level_change(level_id)
		PuzzleState.change_level(level_id)
		
		hud.set_big_message(ChatLibrary.add_mega_lull_characters(tr("OH, MY!!!")))
		hud.enqueue_pop_out()
		
		# force match to end
		PuzzleState.level_performance.lines = 100
		PuzzleState.end_game()
	elif _boxes_built == 0 or _box_clears == 0:
		hud.set_message(tr("Good job!"))
		change_level("tutorial/basics_1")
	elif _squish_moves == 0:
		hud.set_message(tr("Nicely done!"))
		change_level("tutorial/basics_2")
	elif _snack_stacks == 0:
		hud.set_message(tr("Impressive!"))
		change_level("tutorial/basics_3")
	else:
		hud.set_message(tr("Oh! I thought that would be more difficult..."))
		change_level("tutorial/basics_4")
		start_customer_countdown()


func _handle_line_clear_message() -> void:
	if _did_line_clear and _line_clears == 1:
		hud.set_message(tr("Well done!\n\nLine clears earn ¥1. Maybe more if you can build a combo."))


## Enqueues a message describing how to progress in the tutorial, after skipping.
##
## Skipping the tutorial shows a message like 'Wow, you did a squish move!' But if we display that forever, the player
## might forget how to progress in the tutorial. This function displays a 'how to progress' message after a delay.
func _add_post_skip_message() -> void:
	match CurrentLevel.settings.id:
		"tutorial/basics_0":
			hud.enqueue_message(tr("Clear a row by filling it with blocks."))
		"tutorial/basics_1":
			if _boxes_built == 0:
				hud.enqueue_message(tr("Try making a snack box by arranging two pieces into a square."))
			elif _box_clears == 0:
				hud.enqueue_message(tr("Try clearing a few box lines."))


func _handle_box_clear_message() -> void:
	if _did_box_clear:
		if _box_clears == 1:
			match CurrentLevel.settings.id:
				"tutorial/basics_0":
					hud.set_message(tr("Well done!\n\nBox clears earn you five times as much money."
							+ " Maybe more than that if you're clever."))
					_add_post_skip_message()
					hud.skill_tally_item("BoxClear").visible = true
				"tutorial/basics_1":
					hud.set_message(tr("Well done!\n\nBox clears earn you five times as much money."
							+ " Maybe more than that if you're clever."))
					_add_post_skip_message()


func _handle_squish_move_message() -> void:
	if _did_squish_move:
		if _squish_moves == 1:
			match CurrentLevel.settings.id:
				"tutorial/basics_0", "tutorial/basics_1":
					hud.set_message(tr("Oh my, you're not supposed to know how to do that!\n\n"
							+ "...But yes, squish moves can help you out of a jam."))
					_add_post_skip_message()
					hud.skill_tally_item("SquishMove").visible = true
					hud.skill_tally_item("SquishMove").increment()
				"tutorial/basics_2":
					hud.set_message(tr("Well done!\n\nSquish moves can help you out of a jam."
							+ " They're also good for certain boxes."))


func _handle_build_box_message() -> void:
	if _did_build_box:
		if _boxes_built == 1:
			match CurrentLevel.settings.id:
				"tutorial/basics_0":
					hud.set_message(tr("Oh my, you're not supposed to know how to do that!\n\n"
							+ "...But yes, those boxes earn ¥15 when you clear them."))
					_add_post_skip_message()
					hud.skill_tally_item("SnackBox").visible = true
					hud.skill_tally_item("SnackBox").increment()
				"tutorial/basics_1":
					hud.set_message(tr("Well done!\n\nThose boxes earn ¥15 when you clear them."
					+ " Try clearing a few box lines."))


func _handle_snack_stack_message() -> void:
	if CurrentLevel.settings.id == "tutorial/basics_3" and _did_build_box and _did_squish_move:
		hud.skill_tally_item("SnackStack").increment()
		_snack_stacks += 1
		if _snack_stacks == 1:
			hud.set_message(tr("Impressive! Using squish moves," \
					+ " you can organize boxes in tall vertical stacks and earn a lot of money."))


func _on_PieceManager_piece_spawned(_piece: ActivePiece) -> void:
	_did_line_clear = false
	_did_squish_move = false
	_did_build_box = false
	_did_box_clear = false
	_did_build_cake = false


func _on_PieceManager_squish_moved(_piece: ActivePiece, _old_pos: Vector2) -> void:
	_did_squish_move = true
	_squish_moves += 1


func _on_Playfield_box_built(_rect: Rect2, color: int) -> void:
	_did_build_box = true
	_boxes_built += 1
	
	if Foods.is_cake_box(color):
		_did_build_cake = true


func _on_Playfield_line_cleared(_y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	_did_line_clear = true
	_line_clears += 1
	
	if _box_ints:
		_did_box_clear = true
		_box_clears += 1
		hud.skill_tally_item("BoxClear").increment()


## After a piece is written to the playfield, we check if the player should advance further in the tutorial.
func _on_PuzzleState_after_piece_written() -> void:
	# print tutorial messages if the player did something noteworthy
	_handle_line_clear_message()
	_handle_squish_move_message()
	_handle_build_box_message()
	_handle_box_clear_message()
	_handle_snack_stack_message()
	
	match CurrentLevel.settings.id:
		"tutorial/basics_0":
			if _line_clears >= 2: _advance_level()
		"tutorial/basics_1":
			if _boxes_built >= 2 and _box_clears >= 2: _advance_level()
		"tutorial/basics_2":
			if not _did_squish_move:
				playfield.tile_map.restore_state()
			if _squish_moves >= 2:
				_advance_level()
		"tutorial/basics_3":
			if not _did_build_box:
				playfield.tile_map.restore_state()
			if _snack_stacks >= 2:
				_advance_level()


func _on_PuzzleState_after_game_prepared() -> void:
	hud.show_skill_tally_items()
	
	hud.skill_tally_item("SnackBox").visible = false
	hud.skill_tally_item("BoxClear").visible = false
	hud.skill_tally_item("SquishMove").visible = false
	hud.skill_tally_item("SnackStack").visible = false
	
	_line_clears = 0
	_box_clears = 0
	_boxes_built = 0
	_squish_moves = 0
	_snack_stacks = 0
	
	prepare_tutorial_level()


func _on_PuzzleState_game_started() -> void:
	if CurrentLevel.settings.other.skip_intro:
		hud.set_message(tr("Welcome to Turbo Fat!"
					+ " You seem to already be familiar with this sort of game, so let's dive right in."
					+ "\n\nClear a row by filling it with blocks."))
	else:
		hud.set_message(tr("Clear a row by filling it with blocks."))
