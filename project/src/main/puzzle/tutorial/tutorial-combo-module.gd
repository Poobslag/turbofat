extends TutorialModule
"""
Tutorial module for the 'Build Combos' tutorial.

Shows messages and advances the player through the tutorial as they complete tasks.
"""

# how many cakes the player has made during the current tutorial section
var _cakes_built := 0

# whether the player ended the combo with their most recent piece
var _did_end_combo := false

# The number of times the diagram has been shown. We cycle through different explanations and chat choices.
var _show_diagram_count := 0

# At the end of the tutorial, we show a message based on whether the player got a good combo. We only show this message
# once.
var _showed_end_of_level_message := false

# set of level IDs which the player has attempted during this tutorial
# key: level id
# value: true
var _prepared_levels: Dictionary

var _combo_diagram := preload("res://assets/main/puzzle/tutorial/combo-diagram.png")

func _ready() -> void:
	PuzzleScore.connect("after_game_prepared", self, "_on_PuzzleScore_after_game_prepared")
	PuzzleScore.connect("after_piece_written", self, "_on_PuzzleScore_after_piece_written")
	PuzzleScore.connect("combo_ended", self, "_on_PuzzleScore_combo_ended")
	
	playfield.connect("line_cleared", self, "_on_Playfield_line_cleared")
	playfield.connect("box_built", self, "_on_Playfield_box_built")
	piece_manager.connect("piece_spawned", self, "_on_PieceManager_piece_spawned")
	hud.get_tutorial_diagram().connect("ok_chosen", self, "_on_TutorialDiagram_ok_chosen")
	hud.get_tutorial_diagram().connect("help_chosen", self, "_on_TutorialDiagram_help_chosen")
	
	hud.set_message("Today we'll go over combos."
			+ "\n\nCombos are easy, you might have already done them on accident!")


func prepare_tutorial_level() -> void:
	.prepare_tutorial_level()
	var failed_section := _prepared_levels.has(Level.settings.id)
	
	match(Level.settings.id):
		"tutorial/combo_0":
			_set_combo_state(0, 5)
			hud.skill_tally_item("Combo").visible = true
			if failed_section:
				hud.set_message("Try again!/ Try to clear five lines without stopping."
						+ "\n\nDropping one piece off to the side won't break your combo.")
			else:
				hud.set_message("See if you can clear five lines without stopping."
						+ "\n\nWell,/ a short break is actually okay too.")
		"tutorial/combo_1":
			_show_next_diagram()
		"tutorial/combo_2":
			_set_combo_state(5, 12)
			hud.skill_tally_item("Combo").visible = true
			if failed_section:
				hud.set_message("Try again!/ Try to extend this combo by seven lines."
						+ "\n\nMake boxes to keep your combo from breaking.")
			else:
				hud.set_message("Let's use boxes to extend a combo!"
						+ "\n\nTry to clear seven more lines without letting your combo break.")
		"tutorial/combo_3":
			PuzzleScore.level_performance.pieces = 0
			_set_combo_state(5)
			hud.set_message("You can make a cake box with three pieces./ Let me show you.")
			hud.enqueue_message("Unfortunately,/ it's difficult to continue a combo with cake boxes."
					+ "\n\nThe first two pieces will break the combo.")
		"tutorial/combo_4":
			PuzzleScore.level_performance.pieces = 0
			_set_combo_state(5)
			hud.set_message("With a little foresight,/ you can clear some lines while building a cake box."
					+ "\n\nThen your combo won't break.")
		"tutorial/combo_5":
			_set_combo_state(5, 12)
			_cakes_built = 0
			hud.skill_tally_item("CakeBox").reset()
			hud.skill_tally_item("CakeBox").visible = true
			if failed_section:
				hud.set_message("Try again!/ Try to make two cake boxes."
						+ "\n\nClear lines to keep your combo from breaking.")
			else:
				hud.set_message("Now see if you can do it.\n\nMake two cake boxes,/ but don't let your combo break.")
		"tutorial/combo_6":
			# reset timer, scores
			PuzzleScore.reset()
			puzzle.scroll_to_new_creature()
			
			hud.set_message("...Oh!/ Customers!/\n\nTry to get ¥120 in one big combo."
					+ "\n\nIt might help to make some boxes first.")
			hud.enqueue_pop_out()
	
	_prepared_levels[Level.settings.id] = true


"""
Initializes the combo and combo indicators to the specified values.

Parameters:
	'start': The player's current combo
	
	'goal': (Optional) The combo needed to complete the tutorial section
"""
func _set_combo_state(start: int, goal: int = 0) -> void:
	PuzzleScore.set_combo(start)
	if goal:
		hud.skill_tally_item("Combo").value = start
		hud.skill_tally_item("Combo").max_value = goal
		hud.skill_tally_item("Combo").update_label()


"""
Advance to the next level in the tutorial.
"""
func _advance_level() -> void:
	var delay_between_levels := PuzzleScore.DELAY_SHORT
	var failed_section := false
	match Level.settings.id:
		"tutorial/combo_0", "tutorial/combo_2":
			if hud.skill_tally_item("Combo").is_complete():
				hud.set_message("Good job!")
			else:
				hud.set_message("Oops!/ ...You needed to clear a line with that last piece.")
				delay_between_levels = PuzzleScore.DELAY_LONG
				failed_section = true
		"tutorial/combo_1":
			# no delay for the non-interactive segment where we show the player a diagram
			delay_between_levels = PuzzleScore.DELAY_NONE
		"tutorial/combo_3", "tutorial/combo_4":
			# no delay for the non-interactive segment where we demo for the player
			delay_between_levels = PuzzleScore.DELAY_NONE
		"tutorial/combo_5":
			if hud.skill_tally_item("CakeBox").is_complete():
				hud.set_message("Impressive!\n\nHmm... Was there anything else?")
				delay_between_levels = PuzzleScore.DELAY_LONG
				start_customer_countdown()
			else:
				hud.set_message("Oh!/ ...You needed to clear a line that time.")
				delay_between_levels = PuzzleScore.DELAY_LONG
				failed_section = true
	
	var level_ids := [
		"tutorial/combo_0", "tutorial/combo_1", "tutorial/combo_2", "tutorial/combo_3",
		"tutorial/combo_4", "tutorial/combo_5", "tutorial/combo_6",
	]
	var new_level_id: String
	if failed_section:
		new_level_id = Level.settings.id
	else:
		new_level_id = level_ids[level_ids.find(Level.settings.id) + 1]
	PuzzleScore.change_level(new_level_id, delay_between_levels)


"""
Shows a diagram explaining how combos moves work, with an accompanying instructor message.
"""
func _show_next_diagram() -> void:
	var hud_messages := []
	if _show_diagram_count == 0:
		hud_messages.append("Combos earn you extra money!/ You can build combos by making boxes and clearing lines."
				+ "\n\nOtherwise,/ dropping two pieces will reset your combo.")
		hud_messages.append("In other words,"
				+ "/ you get two chances to make a box or clear a line before you lose your combo."
				+ "\n\nDoes that make sense?")
	else:
		match _show_diagram_count % 4:
			0: hud_messages.append("In other words,/"
					+ "you get two chances to make a box or clear a line before you lose your combo.")
			1: hud_messages.append("Arranging two or more pieces into a rectangle will make a box."
					+ "\n\nThat's one easy way to keep your combo alive!/ Just place two pieces to make a square.")
			2: hud_messages.append("Clearing a line will also continue your combo."
					+ "/ But,/ you don't have to clear a line with every piece!"
					+ "\n\nYou can drop one piece without breaking your combo.")
			3: hud_messages.append("Your combo's only interrupted if you drop two pieces without doing something."
					+ "\n\nSo,/ you're allowed to make one mistake!/ Or,/ to use one piece to plan ahead.")
	hud.set_messages(hud_messages)
	
	hud.get_tutorial_diagram().show_diagram(_combo_diagram)
	_show_diagram_count += 1


func _on_PieceManager_piece_spawned() -> void:
	_did_end_combo = false


"""
After a piece is written to the playfield, we check if the player should advance further in the tutorial.

We also sometimes display messages from the instructor.
"""
func _on_PuzzleScore_after_piece_written() -> void:
	match Level.settings.id:
		"tutorial/combo_0", "tutorial/combo_2":
			if hud.skill_tally_item("Combo").is_complete():
				_advance_level()
			elif _did_end_combo:
				_advance_level()
		"tutorial/combo_3":
			if PuzzleScore.level_performance.pieces == 2:
				if not hud.get_tutorial_messages().is_all_messages_visible():
					yield(hud.get_tutorial_messages(), "all_messages_shown")
				yield(get_tree().create_timer(3.0), "timeout")
				hud.set_message("Oops!/ I can still make the cake box,/ but my combo already broke.")
			if PuzzleScore.level_performance.pieces >= 3:
				yield(get_tree().create_timer(3.0), "timeout")
				_advance_level()
		"tutorial/combo_4":
			if PuzzleScore.level_performance.pieces >= 4:
				hud.set_message("There,/ I did it!\n\nThat was tricky.")
				if not hud.get_tutorial_messages().is_all_messages_visible():
					yield(hud.get_tutorial_messages(), "all_messages_shown")
				yield(get_tree().create_timer(3.0), "timeout")
				_advance_level()
		"tutorial/combo_5":
			if hud.skill_tally_item("CakeBox").is_complete():
				_advance_level()
			elif _did_end_combo:
				_advance_level()
		"tutorial/combo_6":
			if not _showed_end_of_level_message:
				var first_creature_score: int = PuzzleScore.creature_scores[0]
				if (_did_end_combo or first_creature_score >= 120):
					if first_creature_score >= 120:
						hud.set_message("Wow,/ I didn't expect that!/ Great job.\n\nYou're already a combo master!")
						hud.enqueue_pop_out()
					else:
						hud.set_message("Oh no, you broke your combo without reaching ¥120!"
								+ "\n\nWell,/ don't worry about that.")
						hud.enqueue_message("¥120 is just a number I pulled out of my,/ um. ./././Out of thin air."
								+ ("\n\n¥%s is good too!" % [StringUtils.comma_sep(first_creature_score)]))
						hud.enqueue_pop_out()
					_showed_end_of_level_message = true


func _on_Playfield_line_cleared(_y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	hud.skill_tally_item("Combo").increment()


func _on_Playfield_box_built(_rect: Rect2, color: int) -> void:
	if PuzzleTileMap.is_cake_box(color):
		_cakes_built += 1
		hud.skill_tally_item("CakeBox").increment()


func _on_PuzzleScore_combo_ended() -> void:
	_did_end_combo = true


func _on_PuzzleScore_after_game_prepared() -> void:
	hud.show_skill_tally_items()
	hud.skill_tally_item("Combo").visible = false
	hud.skill_tally_item("CakeBox").visible = false
	
	_prepared_levels.clear()
	_cakes_built = 0
	_show_diagram_count = 0
	
	prepare_tutorial_level()


func _on_TutorialDiagram_ok_chosen() -> void:
	_advance_level()


func _on_TutorialDiagram_help_chosen() -> void:
	_show_next_diagram()
