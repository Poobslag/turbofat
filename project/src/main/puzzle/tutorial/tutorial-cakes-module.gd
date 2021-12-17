extends TutorialModule
## Tutorial module for the 'Make Cakes' tutorial.
##
## Shows messages and advances the player through the tutorial as they complete tasks.

## player statistics for the current tutorial section
var _cakes_built := 0
var _failure_count := 0

## 'true' if the player built a cake with their newest piece
var _did_build_cake := false

## 'true' if player completed or failed the current tutorial section
var _level_finished := false

var _cakes_diagram_0 := preload("res://assets/main/puzzle/tutorial/cakes-diagram-0.png")
var _cakes_diagram_1 := preload("res://assets/main/puzzle/tutorial/cakes-diagram-1.png")

func _ready() -> void:
	PuzzleState.connect("after_game_prepared", self, "_on_PuzzleState_after_game_prepared")
	PuzzleState.connect("after_piece_written", self, "_on_PuzzleState_after_piece_written")
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")
	playfield.connect("box_built", self, "_on_Playfield_box_built")
	piece_manager.connect("piece_spawned", self, "_on_PieceManager_piece_spawned")
	
	hud.set_message(tr("Today we'll learn about cake boxes!\n\nDo you remember how boxes work?"))


func prepare_tutorial_level() -> void:
	.prepare_tutorial_level()
	
	_cakes_built = 0
	_level_finished = false
	PuzzleState.level_performance.pieces = 0
	
	match CurrentLevel.settings.id:
		"tutorial/cakes_0":
			hud.skill_tally_item("SnackBox").visible = true
			hud.set_message(tr("Try making some snack boxes by arranging pairs of pieces into squares."))
		"tutorial/cakes_1":
			hud.get_tutorial_diagram().show_diagram(_cakes_diagram_0)
			hud.set_message(tr("Arranging pieces into a square makes a snack box worth ¥15."
					+ "\n\nBut rectangles make cake boxes worth ¥40!"))
			hud.enqueue_message(tr("A cake box needs exactly three pieces in a rectangle.\n\nNo more, no less."))
			hud.enqueue_message(tr("There are eight ways to do it."
					+ "\n\nI could show you, but I want you to try it yourself!"))
			_advance_level()
		"tutorial/cakes_2":
			_prepare_cake_tally_item(1)
			if _failure_count >= 1:
				hud.set_message(tr("Give it another try.\n\nSee if you can make a rectangle."))
			else:
				hud.set_message(tr("Let's start by making gelatin.\n\nCan you make a rectangle with these pieces?"))
		"tutorial/cakes_3":
			_prepare_cake_tally_item(1)
			if _failure_count >= 1:
				hud.set_message(tr("Give it another try.\n\nSee if you can make a rectangle."))
			else:
				hud.set_message(tr("Next let's try double-decker brownies.\n\nCan you make another cake box with this?"))
		"tutorial/cakes_4":
			_prepare_cake_tally_item(2)
			if _failure_count >= 3:
				hud.set_message(tr("I'll give you a small hint:\n\nBoth chocolate pieces go into the left box."))
			elif _failure_count >= 1:
				hud.set_message(tr("Give it another try.\n\nSee if you can make two rectangles."))
			else:
				hud.set_message(tr("Here's something more difficult. Can you make two cake boxes at once?"))
		"tutorial/cakes_5":
			hud.get_tutorial_diagram().show_diagram(_cakes_diagram_1)
			hud.set_message(tr("You can make cake boxes with the bigger pieces."
					+ "\n\nAnd they're worth three times as much sideways!"))
			hud.enqueue_message(tr("See all those stars? Each star becomes a tasty treat for our customers."
					+ " And more treats means more money!"))
			hud.enqueue_message(tr("Let's see if you can figure out these last four recipes without my help."))
			_advance_level()
		"tutorial/cakes_6":
			_prepare_cake_tally_item(1)
			if _failure_count >= 1:
				hud.set_message(tr("Give it another try.\n\nSee if you can make a rectangle."))
			else:
				hud.set_message(tr("How about some cheesecake?\n\nYou'll need a bigger rectangle this time."))
		"tutorial/cakes_7":
			_prepare_cake_tally_item(1)
			if _failure_count >= 1:
				hud.set_message(tr("Give it another try.\n\nSee if you can make a rectangle."))
			else:
				hud.set_message(tr("Let's try some strawberry cake.\n\nCan you make a cake box with these pieces?"))
		"tutorial/cakes_8":
			_prepare_cake_tally_item(2)
			if _failure_count >= 1:
				hud.set_message(tr("Give it another try.\n\nSee if you can make two rectangles."))
			else:
				hud.set_message(tr("Okay, final two recipes!\n\n...Can you make two cakes at once?"))
		"tutorial/cakes_9":
			# reset timer, scores
			PuzzleState.reset()
			puzzle.scroll_to_new_creature()
			
			hud.set_message(tr("I'm getting a tummy ache!"
					+ "\n\nTry your new cake recipes on these customers, while I go lie down..."))
			hud.enqueue_pop_out()


func _prepare_cake_tally_item(max_value: int) -> void:
	hud.skill_tally_item("CakeBox").visible = true
	hud.skill_tally_item("CakeBox").max_value = max_value
	hud.skill_tally_item("CakeBox").reset()


## Advance to the next level in the tutorial.
func _advance_level() -> void:
	_level_finished = true
	
	var delay_between_levels := PuzzleState.DELAY_SHORT
	var failed_section := false
	match CurrentLevel.settings.id:
		"tutorial/cakes_0":
			if _cakes_built == 0:
				hud.set_message(tr("Good! Snack boxes are worth lots of money. But, we can do better!"))
			elif _cakes_built < 3:
				hud.set_message(tr("Good job!\n\nIt seems like you understand cake boxes already."))
			elif _cakes_built >= 3:
				hud.set_message(tr("Ahha ha ha!\n\nYou're just trying to impress me."))
		"tutorial/cakes_1":
			# wait for the player to finish reading the diagram
			delay_between_levels = PuzzleState.DELAY_LONG
		"tutorial/cakes_2":
			if _cakes_built >= 1:
				_schedule_finish_line_clears()
				hud.set_message(tr("Good job! You can make gelatin with a J, L and O piece."))
			else:
				hud.set_message(tr("Oops! ...Let's try that again."))
				failed_section = true
		"tutorial/cakes_3":
			if _cakes_built >= 1:
				_schedule_finish_line_clears()
				hud.set_message(tr("Oh? But I even gave you an extra piece to trick you!\n\nHmm, how about this."))
			else:
				hud.set_message(tr("Oops! ...Let's try that again."))
				failed_section = true
		"tutorial/cakes_4":
			if _cakes_built >= 2:
				_schedule_finish_line_clears()
				hud.set_message(tr("Wow, color me impressed!\n\nBut, there's one more thing you should know about cake boxes."))
			elif _cakes_built == 1:
				hud.set_message(tr("Oh, you're half way there! ...Now try for the other one."))
				failed_section = true
			else:
				hud.set_message(tr("Oops! ...Let's try that again."))
				failed_section = true
		"tutorial/cakes_5":
			# wait for the player to finish reading the diagram
			delay_between_levels = PuzzleState.DELAY_LONG
		"tutorial/cakes_6":
			if _cakes_built >= 1:
				_schedule_finish_line_clears()
				hud.set_message(tr("Wow, that looks delicious!"))
			else:
				hud.set_message(tr("Oops! ...Let's try that again."))
				failed_section = true
		"tutorial/cakes_7":
			if _cakes_built >= 1:
				_schedule_finish_line_clears()
				hud.set_message(tr("Good job!"))
			else:
				hud.set_message(tr("Oops! ...Let's try that again."))
				failed_section = true
		"tutorial/cakes_8":
			if _cakes_built >= 2:
				_schedule_finish_line_clears()
				hud.set_message(tr("Wow! That's all eight recipes."))
			elif _cakes_built == 1:
				hud.set_message(tr("Oh, you're half way there! ...Now try for the other one."))
				failed_section = true
			else:
				hud.set_message(tr("Oops! ...Let's try that again."))
				failed_section = true
	
	var level_ids := [
		"tutorial/cakes_0", "tutorial/cakes_1", "tutorial/cakes_2", "tutorial/cakes_3",
		"tutorial/cakes_4", "tutorial/cakes_5", "tutorial/cakes_6", "tutorial/cakes_7",
		"tutorial/cakes_8", "tutorial/cakes_9",
	]
	var new_level_id: String
	if failed_section:
		_failure_count += 1
		new_level_id = CurrentLevel.settings.id
	else:
		_failure_count = 0
		new_level_id = level_ids[level_ids.find(CurrentLevel.settings.id) + 1]
	change_level(new_level_id, delay_between_levels)


## Clears lines for any completed cake/snack boxes.
##
## Each cake makes a unique kind of food. We clear the lines so that the player can see what they made.
func _schedule_finish_line_clears() -> void:
	hud.puzzle.get_playfield().line_clearer.schedule_finish_line_clears()


func _handle_build_cake_message() -> void:
	if _did_build_cake and _cakes_built == 1 and CurrentLevel.settings.id == "tutorial/cakes_0":
		hud.set_message(tr("Alright, you little showoff.\n\n...Have you been studying?"))
		hud.enqueue_message(tr("Make a few more snack boxes.\n\n...Or cake boxes, if you must."))


## After a piece is written to the playfield, we check if the player should advance further in the tutorial.
##
## We also sometimes display messages from the sensei.
func _on_PuzzleState_after_piece_written() -> void:
	if _level_finished:
		# The 'after_piece_written' signal is also triggered when deleting lines after a tutorial section. We ignore
		# these signals to avoid an infinite loop.
		return
	
	# print tutorial messages if the player did something noteworthy
	_handle_build_cake_message()
	
	match CurrentLevel.settings.id:
		"tutorial/cakes_0":
			if hud.skill_tally_item("SnackBox").is_complete():
				_advance_level()
		"tutorial/cakes_2", "tutorial/cakes_3", "tutorial/cakes_4", \
		"tutorial/cakes_6", "tutorial/cakes_7", "tutorial/cakes_8":
			if PuzzleState.level_performance.pieces >= CurrentLevel.settings.finish_condition.value \
					or hud.skill_tally_item("CakeBox").value >= hud.skill_tally_item("CakeBox").max_value:
				_advance_level()


func _on_Playfield_box_built(_rect: Rect2, color: int) -> void:
	if Foods.is_cake_box(color):
		_did_build_cake = true
		_cakes_built += 1
		hud.skill_tally_item("CakeBox").increment()


func _on_PieceManager_piece_spawned() -> void:
	_did_build_cake = false


func _on_PuzzleState_after_game_prepared() -> void:
	hud.show_skill_tally_items()
	hud.skill_tally_item("SnackBox").visible = false
	hud.skill_tally_item("CakeBox").visible = false
	prepare_tutorial_level()


func _on_PuzzleState_game_ended() -> void:
	if not PuzzleState.level_performance.lost and CurrentLevel.settings.id == "tutorial/cakes_9":
		# show end-of-tutorial message
		if _cakes_built == 0:
			hud.set_message(tr("Ahhh... you didn't make any cakes!\n\nWell, cake boxes can be tricky. Keep practicing!"))
		elif _cakes_built == 1:
			hud.set_message(tr("Ahhh... you only made one cake?\n\nWell, cake boxes can be tricky. Keep practicing!"))
		elif _cakes_built <= 4:
			hud.set_message(tr("Oh, you made %s cakes!\n\nAll that training paid off. Look at those happy customers!")
					% [StringUtils.english_number(_cakes_built)])
		elif _cakes_built <= 8:
			hud.set_message(tr("Wow, you made %s cakes? Maybe you should be training me!")
					% [StringUtils.english_number(_cakes_built)])
			hud.enqueue_message(tr("Just kidding, I should still be training you.\n\nBut you did really well! Wow!"))
		else:
			hud.set_message(tr("%s CAKES!? Okay, well that's just ridiculous!")
					% [StringUtils.english_number(_cakes_built).to_upper()])
			hud.enqueue_message(tr("I'll have to think of some harder tutorials for someone like you."
					+ "\n\nYou little troublemaker!"))
