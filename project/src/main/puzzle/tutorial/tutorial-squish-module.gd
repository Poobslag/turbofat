extends TutorialModule
"""
Tutorial module for the 'Basic Techniques' tutorial.

Shows messages and advances the player through the tutorial as they complete tasks.
"""

# tracks what the player has done during the current section of the tutorial
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

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("after_level_changed", self, "_on_PuzzleScore_after_level_changed")
	
	playfield.connect("box_built", self, "_on_Playfield_box_built")
	playfield.connect("after_piece_written", self, "_on_Playfield_after_piece_written")
	piece_manager.connect("squish_moved", self, "_on_PieceManager_squish_moved")
	piece_manager.connect("piece_spawned", self, "_on_PieceManager_piece_spawned")
	hud.get_tutorial_diagram().connect("ok_chosen", self, "_on_TutorialDiagram_ok_chosen")
	hud.get_tutorial_diagram().connect("help_chosen", self, "_on_TutorialDiagram_help_chosen")
	
	if Level.settings.other.skip_intro:
		puzzle.hide_buttons()
	else:
		# display a welcome message before the game starts
		hud.set_message("Today we'll cover some advanced squish move techniques!"
				+ "\n\nBut first,/ let's make sure you remember the basics.")


"""
Hide all completed skill tally items.

If the player only rotates in one direction or never hard drops a piece, that skill tally item remains visible for the
entire tutorial. This gives them a small hint that there's other stuff they haven't done yet, but it's not necessary to
progress.
"""
func _hide_completed_skill_tally_items() -> void:
	for skill_tally_item_obj in hud.skill_tally_items():
		var skill_tally_item: SkillTallyItem = skill_tally_item_obj
		if skill_tally_item.value >= skill_tally_item.max_value:
			skill_tally_item.visible = false


"""
Advance to the next level in the tutorial.
"""
func _advance_level() -> void:
	var failed_section := false
	var delay_between_levels := PuzzleScore.DELAY_SHORT
	match(Level.settings.id):
		"tutorial_squish_1":
			# no delay for the non-interactive player where we show the player a diagram
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
				failed_section = true
				hud.set_message("Oops!/ ...Let's try that again.")
		"tutorial_squish_6":
			if PuzzleScore.level_performance.lines >= 3:
				hud.set_message("Wow!/ ...I had a few more of these planned,/ but it looks like you get the idea.")
				delay_between_levels = PuzzleScore.DELAY_LONG
				start_customer_countdown()
			else:
				failed_section = true
				hud.set_message("Oops!/ ...Let's try that again.")
		_:
			hud.set_message("Good job!")
	_hide_completed_skill_tally_items()
	var level_ids := [
		"tutorial_squish_0", "tutorial_squish_1", "tutorial_squish_2", "tutorial_squish_3",
		"tutorial_squish_4", "tutorial_squish_5", "tutorial_squish_6", "tutorial_squish_7"
	]
	var new_level_id: String
	if failed_section:
		new_level_id = Level.settings.id
	else:
		new_level_id = level_ids[level_ids.find(Level.settings.id) + 1]
	PuzzleScore.change_level(new_level_id, delay_between_levels)


func _handle_squish_move_message() -> void:
	if _did_squish_move and _squish_moves == 1 and Level.settings.id == "tutorial_squish_0":
		hud.set_message("Good job!\n\nSquish moves help in all sorts of ways.")


func _prepare_tutorial_level() -> void:
	var failed_section := _prepared_levels.has(Level.settings.id)
	
	match(Level.settings.id):
		"tutorial_squish_0":
			hud.skill_tally_item("SquishMove").visible = true
			if Level.settings.other.skip_intro:
				hud.set_messages([
					"Today we'll cover some advanced squish move techniques!"
							+ "\n\nBut first,/ let's make sure you remember the basics.",
					"Hold soft drop to squish pieces through this gap."])
			else:
				hud.enqueue_message("Hold soft drop to squish pieces through this gap.")
		"tutorial_squish_1":
			_show_next_squish_diagram()
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
			if failed_section:
				hud.set_message("Can you clean this up using squish moves?\n\nTry to clear three lines.")
			else:
				hud.set_messages([
					"Of course, squish moves aren't always about being very,"
							+ " very clever. ...Sometimes we make mistakes, too.",
					"Oops! Look at the mess you made. ...Can you clean this up using squish moves?"
							+ "\n\nTry to clear three lines."
				])
		"tutorial_squish_6":
			hud.skill_tally_item("LineClear").visible = true
			hud.skill_tally_item("LineClear").reset()
			PuzzleScore.level_performance.lines = 0
			PuzzleScore.level_performance.pieces = 0
			if failed_section:
				hud.set_message("Try to clear three lines.\n\nRemember your squish moves!")
			else:
				hud.set_messages([
					"Oh no!/ Now you've done it.\n\nLook at how clumsy you are!",
					"That's okay.\n\nI'm sure you'll think of a clever way to clean this up,/ too."
				])
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
Shows a diagram explaining how squish moves work, with an accompanying instructor message.
"""
func _show_next_squish_diagram() -> void:
	var hud_messages := []
	if _show_diagram_count == 0:
		hud_messages.append("For a piece to squish successfully,/"
				+ " one of its blocks needs a clear path to the target.")
		hud_messages.append("Here are some examples of good and bad squish moves."
				+ "\n\nDoes this make any sense?/ I know it's a little weird.")
	else:
		match _show_diagram_count % 4:
			0: hud_messages.append("So basically,/ one part of the piece needs a"
					+ " clear path to the target or it won't squish.")
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
"""
func _on_Playfield_after_piece_written() -> void:
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
			if PuzzleScore.level_performance.pieces >= 4 or PuzzleScore.level_performance.lines >= 3:
				_advance_level()
		"tutorial_squish_6":
			if PuzzleScore.level_performance.pieces >= 4 or PuzzleScore.level_performance.lines >= 3:
				_advance_level()


func _on_PuzzleScore_game_prepared() -> void:
	hud.show_skill_tally_items()
	
	_squish_moves = 0
	_boxes_built = 0
	_show_diagram_count = 0
	
	_prepare_tutorial_level()


func _on_PuzzleScore_after_level_changed() -> void:
	_prepare_tutorial_level()


func _on_TutorialDiagram_ok_chosen() -> void:
	_advance_level()


func _on_TutorialDiagram_help_chosen() -> void:
	_show_next_squish_diagram()
