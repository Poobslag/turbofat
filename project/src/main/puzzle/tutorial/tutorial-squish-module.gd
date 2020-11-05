extends TutorialModule
"""
Tutorial module for the 'Basic Techniques' tutorial.

Shows messages and advances the player through the tutorial as they complete tasks.
"""

# tracks what the player has done during the current tutorial section
var _squish_moves := 0
var _boxes_built := 0

# tracks what the player did with the most recent piece
var _did_squish_move := false
var _did_build_box := false

# The number of times the diagram has been shown. We cycle through different diagrams and chat choices.
var _show_diagram_count := 0

# set of level IDs which the player has attempted during this tutorial
# key: level id
# value: true
var _prepared_levels: Dictionary

var _squish_diagram_0 := preload("res://assets/main/puzzle/tutorial/squish-diagram-0.png")
var _squish_diagram_1 := preload("res://assets/main/puzzle/tutorial/squish-diagram-1.png")

# 'true' if the player is retrying a failed tutorial section. We display different messages the second time.
var _failed_section := false

func _ready() -> void:
	PuzzleScore.connect("after_game_prepared", self, "_on_PuzzleScore_after_game_prepared")
	PuzzleScore.connect("after_piece_written", self, "_on_PuzzleScore_after_piece_written")
	
	playfield.connect("box_built", self, "_on_Playfield_box_built")
	piece_manager.connect("squish_moved", self, "_on_PieceManager_squish_moved")
	piece_manager.connect("piece_spawned", self, "_on_PieceManager_piece_spawned")
	hud.get_tutorial_diagram().connect("ok_chosen", self, "_on_TutorialDiagram_ok_chosen")
	hud.get_tutorial_diagram().connect("help_chosen", self, "_on_TutorialDiagram_help_chosen")
	
	# display a welcome message before the game starts
	hud.set_message("Today we'll cover some advanced squish move techniques!"
			+ "\n\nBut first,/ let's make sure you remember the basics.")


func prepare_tutorial_level() -> void:
	.prepare_tutorial_level()
	_failed_section = _prepared_levels.has(Level.settings.id)
	
	match(Level.settings.id):
		"tutorial_squish_0":
			hud.skill_tally_item("SquishMove").visible = true
			hud.set_message("Hold soft drop to squish pieces through this gap.")
		"tutorial_squish_1":
			_show_next_diagram()
		"tutorial_squish_2":
			hud.skill_tally_item("SnackBox").visible = true
			hud.set_message("So, which of these snack boxes can be completed with a squish move?")
		"tutorial_squish_3":
			hud.skill_tally_item("SnackBox").visible = true
			hud.set_message("How about now,/ can you find a way to squish here?")
		"tutorial_squish_4":
			hud.skill_tally_item("SnackBox").visible = true
			hud.set_message("What do you think about this one?/ Is it possible to make a snack box here?")
		"tutorial_squish_5":
			hud.skill_tally_item("LineClear").visible = true
			hud.skill_tally_item("LineClear").reset()
			PuzzleScore.level_performance.lines = 0
			PuzzleScore.level_performance.pieces = 0
			if _failed_section:
				hud.set_message("Here,/ let me help you with that.")
			else:
				hud.set_message("Of course, squish moves aren't always about being very,"
							+ " very clever. ...Sometimes we make mistakes, too.")
		"tutorial_squish_6":
			hud.skill_tally_item("LineClear").visible = true
			hud.skill_tally_item("LineClear").reset()
			PuzzleScore.level_performance.lines = 0
			PuzzleScore.level_performance.pieces = 0
			if _failed_section:
				hud.set_message("Should I make it worse this time?\n\nNo,/ that would be mean.")
			else:
				hud.set_message("Hmmm.../ What are you up to this time?")
		"tutorial_squish_7":
			# reset timer, scores
			PuzzleScore.reset()
			puzzle.scroll_to_new_creature()

			# the sixth tutorial section ends with a long message, so we enqueue these messages
			hud.enqueue_message("Your training is complete!\n\nBut don't let it go to your head,"
					+ "/ we still have some customers to take care of.")
			hud.enqueue_pop_out()
	
	_prepared_levels[Level.settings.id] = true


"""
Advance to the next level in the tutorial.
"""
func _advance_level() -> void:
	_failed_section = false
	var delay_between_levels := PuzzleScore.DELAY_SHORT
	match(Level.settings.id):
		"tutorial_squish_1":
			# no delay for the non-interactive segment where we show the player a diagram
			delay_between_levels = PuzzleScore.DELAY_NONE
		"tutorial_squish_2":
			hud.set_message("Yes, that's right.")
		"tutorial_squish_3":
			hud.set_message("That's right! Hmm, how about something tricky...")
		"tutorial_squish_4":
			hud.set_message("Wow, okay! ...I need to think of some harder puzzles.")
			delay_between_levels = PuzzleScore.DELAY_LONG
		"tutorial_squish_5":
			if PuzzleScore.level_performance.lines >= 3:
				hud.set_message("Good job!")
			else:
				_failed_section = true
				hud.set_message("Oops!/ ...Let's try that again.")
		"tutorial_squish_6":
			if PuzzleScore.level_performance.lines >= 3:
				hud.set_message("Wow!/ ...I had a few more of these planned,/ but it looks like you get the idea.")
				delay_between_levels = PuzzleScore.DELAY_LONG
				start_customer_countdown()
			else:
				_failed_section = true
				hud.set_message("Oops!/ ...Let's try that again.")
		_:
			hud.set_message("Good job!")
	var level_ids := [
		"tutorial_squish_0", "tutorial_squish_1", "tutorial_squish_2", "tutorial_squish_3",
		"tutorial_squish_4", "tutorial_squish_5", "tutorial_squish_6", "tutorial_squish_7"
	]
	var new_level_id: String
	if _failed_section:
		new_level_id = Level.settings.id
	else:
		new_level_id = level_ids[level_ids.find(Level.settings.id) + 1]
	PuzzleScore.change_level(new_level_id, delay_between_levels)


func _handle_squish_move_message() -> void:
	if _did_squish_move and _squish_moves == 1 and Level.settings.id == "tutorial_squish_0":
		hud.set_message("Good job!\n\nSquish moves help in all sorts of ways.")


"""
Shows a diagram explaining how squish moves work, with an accompanying instructor message.
"""
func _show_next_diagram() -> void:
	var hud_messages := []
	if _show_diagram_count == 0:
		hud_messages.append("For a piece to squish successfully,/"
				+ " one part needs a straight gap down to the target.")
		hud_messages.append("Here are some examples of good and bad squish moves."
				+ "\n\nDoes this make any sense?/ I know it's a little weird.")
	else:
		match _show_diagram_count % 4:
			0: hud_messages.append("So basically,/ one part of the piece needs a"
					+ " straight gap down to the target or it won't squish.")
			1: hud_messages.append("These examples on the right don't work,/"
					+ " because the piece can't \"see\" where it's going.")
			2: hud_messages.append("You can think of it like././."
					+ "\n\nIf the piece were split into tiny chunks,/ would each chunk be blocked?")
			3: hud_messages.append("These examples on the left work,/"
					+ " because one tiny chunk of the piece has a clear path.\n\nIt just needs one.")
	hud.set_messages(hud_messages)
	
	var hud_diagram: Texture
	match _show_diagram_count % 2:
		0: hud_diagram = _squish_diagram_0
		1: hud_diagram = _squish_diagram_1
	hud.get_tutorial_diagram().show_diagram(hud_diagram)
	_show_diagram_count += 1


func _on_PieceManager_piece_spawned() -> void:
	_did_squish_move = false
	_did_build_box = false


func _on_PieceManager_squish_moved(_piece: ActivePiece, _old_pos: Vector2) -> void:
	_did_squish_move = true
	_squish_moves += 1


func _on_Playfield_box_built(_rect: Rect2, _color: int) -> void:
	_did_build_box = true
	_boxes_built += 1


"""
After a piece is written to the playfield, we check if the player should advance further in the tutorial.

We also sometimes display messages from the instructor.
"""
func _on_PuzzleScore_after_piece_written() -> void:
	# print tutorial messages if the player did something noteworthy
	_handle_squish_move_message()
	
	match Level.settings.id:
		"tutorial_squish_0":
			if not _did_squish_move:
				playfield.tile_map.restore_state()
			if _squish_moves >= 2:
				_advance_level()
		"tutorial_squish_2", "tutorial_squish_3", "tutorial_squish_4":
			if _did_build_box:
				_advance_level()
			else:
				playfield.tile_map.restore_state()
		"tutorial_squish_5":
			if PuzzleScore.level_performance.pieces == 1:
				Level.settings.input_replay.clear()
				if not hud.get_tutorial_messages().is_all_messages_visible():
					yield(hud.get_tutorial_messages(), "all_messages_shown")
				yield(get_tree().create_timer(0.5), "timeout")
				if _failed_section:
					hud.set_message("Not again!/ ...Can you clean this up using squish moves?"
								+ "\n\nTry to clear three lines.")
				else:
					hud.set_message("Oops!/ Look at the mess you made./ ...Can you clean this up using squish moves?"
								+ "\n\nTry to clear three lines.")
			
			if PuzzleScore.level_performance.pieces >= Level.settings.finish_condition.value \
					or PuzzleScore.level_performance.lines >= 3:
				_advance_level()
		"tutorial_squish_6":
			if PuzzleScore.level_performance.pieces == 1:
				Level.settings.input_replay.clear()
				if not hud.get_tutorial_messages().is_all_messages_visible():
					yield(hud.get_tutorial_messages(), "all_messages_shown")
				yield(get_tree().create_timer(0.5), "timeout")
				if _failed_section:
					hud.set_message("Oh no,/ it keeps happening!/ Well, try to clear three lines."
							+ "\n\nRemember your squish moves!")
				else:
					hud.set_messages(["Oh no!/ Now you've done it.\n\nLook at how clumsy you are!",
						"That's okay.\n\nI'm sure you'll think of a clever way to clean this up,/ too."])
			
			if PuzzleScore.level_performance.pieces >= Level.settings.finish_condition.value \
					or PuzzleScore.level_performance.lines >= 3:
				_advance_level()


func _on_PuzzleScore_after_game_prepared() -> void:
	hud.show_skill_tally_items()
	hud.skill_tally_item("SquishMove").visible = false
	hud.skill_tally_item("SnackBox").visible = false
	hud.skill_tally_item("LineClear").visible = false
	
	_prepared_levels.clear()
	_squish_moves = 0
	_boxes_built = 0
	_show_diagram_count = 0
	
	prepare_tutorial_level()


func _on_TutorialDiagram_ok_chosen() -> void:
	_advance_level()


func _on_TutorialDiagram_help_chosen() -> void:
	_show_next_diagram()
