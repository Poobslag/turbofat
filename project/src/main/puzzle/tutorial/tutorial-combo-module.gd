extends TutorialModule
## Tutorial module for the 'Build Combos' tutorial.
##
## Shows messages and advances the player through the tutorial as they complete tasks.

## how many cakes the player has made during the current tutorial section
var _cakes_built := 0

## whether the player ended the combo with their most recent piece
var _did_end_combo := false

## The number of times the diagram has been shown. We cycle through different explanations and chat choices.
var _show_diagram_count := 0

## At the end of the tutorial, we show a message based on whether the player got a good combo. We only show this
## message once.
var _showed_end_of_level_message := false

## set of level IDs which the player has attempted during this tutorial
## key: (String) level id
## value: (bool) true
var _prepared_levels: Dictionary

var _combo_diagram := preload("res://assets/main/puzzle/tutorial/combo-diagram.png")

func _ready() -> void:
	PuzzleState.connect("after_game_prepared", self, "_on_PuzzleState_after_game_prepared")
	PuzzleState.connect("after_piece_written", self, "_on_PuzzleState_after_piece_written")
	PuzzleState.connect("combo_ended", self, "_on_PuzzleState_combo_ended")
	
	playfield.connect("line_cleared", self, "_on_Playfield_line_cleared")
	playfield.connect("box_built", self, "_on_Playfield_box_built")
	piece_manager.connect("piece_spawned", self, "_on_PieceManager_piece_spawned")
	hud.diagram.connect("ok_chosen", self, "_on_TutorialDiagram_ok_chosen")
	hud.diagram.connect("help_chosen", self, "_on_TutorialDiagram_help_chosen")
	
	hud.set_message(tr("Today we'll go over combos."
			+ "\n\nCombos are easy, you might have already done them on accident!"))


func prepare_tutorial_level() -> void:
	.prepare_tutorial_level()
	var failed_section := _prepared_levels.has(CurrentLevel.settings.id)
	
	match CurrentLevel.settings.id:
		"tutorial/combo_0":
			_set_combo_state(0, 5)
			hud.skill_tally_item("Combo").visible = true
			if failed_section:
				hud.set_message(tr("Try again! Try to clear five lines without stopping."
						+ "\n\nDropping one piece off to the side won't break your combo."))
			else:
				hud.set_message(tr("See if you can clear five lines without stopping."
						+ "\n\nWell, a short break is actually okay too."))
		"tutorial/combo_1":
			_show_next_diagram()
		"tutorial/combo_2":
			_set_combo_state(5, 12)
			hud.skill_tally_item("Combo").visible = true
			if failed_section:
				hud.set_message(tr("Try again! Try to extend this combo by seven lines."
						+ "\n\nMake boxes to keep your combo from breaking."))
			else:
				hud.set_message(tr("Let's use boxes to extend a combo!"
						+ "\n\nTry to clear seven more lines without letting your combo break."))
		"tutorial/combo_3":
			PuzzleState.level_performance.pieces = 0
			_set_combo_state(5)
			hud.set_message(tr("You can make a cake box with three pieces. Let me show you."))
			hud.enqueue_message(tr("Unfortunately, it's difficult to continue a combo with cake boxes."
					+ "\n\nThe first two pieces will break the combo."))
		"tutorial/combo_4":
			PuzzleState.level_performance.pieces = 0
			_set_combo_state(5)
			hud.set_message(tr("With a little foresight, you can clear some lines while building a cake box."
					+ "\n\nThen your combo won't break."))
		"tutorial/combo_5":
			_set_combo_state(5, 12)
			_cakes_built = 0
			hud.skill_tally_item("CakeBox").reset()
			hud.skill_tally_item("CakeBox").visible = true
			if failed_section:
				hud.set_message(tr("Try again! Try to make two cake boxes."
						+ "\n\nClear lines to keep your combo from breaking."))
			else:
				hud.set_message(tr("Now see if you can do it."
						+ "\n\nMake two cake boxes, but don't let your combo break."))
		"tutorial/combo_6":
			dismiss_sensei([tr("...Oh! Customers!\n\nTry to get ¥120 in one big combo."
					+ "\n\nIt might help to make some boxes first.")])
	
	_prepared_levels[CurrentLevel.settings.id] = true


## Initializes the combo and combo indicators to the specified values.
##
## Parameters:
## 	'start': The player's current combo
##
## 	'goal': (Optional) The combo needed to complete the tutorial section
func _set_combo_state(start: int, goal: int = 0) -> void:
	PuzzleState.set_combo(start)
	if goal:
		hud.skill_tally_item("Combo").value = start
		hud.skill_tally_item("Combo").max_value = goal
		hud.skill_tally_item("Combo").update_label()


## Advance to the next level in the tutorial.
func _advance_level() -> void:
	PuzzleState.level_performance.lost = false
	var delay_between_levels := Tutorials.DELAY_SHORT
	match CurrentLevel.settings.id:
		"tutorial/combo_0", "tutorial/combo_2":
			if hud.skill_tally_item("Combo").is_complete():
				hud.set_message(tr("Good job!"))
			else:
				hud.set_message(tr("Oops! ...You needed to clear a line with that last piece."))
				delay_between_levels = Tutorials.DELAY_LONG
				PuzzleState.level_performance.lost = true
		"tutorial/combo_1":
			# no delay for the non-interactive segment where we show the player a diagram
			delay_between_levels = Tutorials.DELAY_NONE
		"tutorial/combo_3", "tutorial/combo_4":
			# no delay for the non-interactive segment where we demo for the player
			delay_between_levels = Tutorials.DELAY_NONE
		"tutorial/combo_5":
			if hud.skill_tally_item("CakeBox").is_complete():
				hud.set_message(tr("Impressive!\n\nHmm... Was there anything else?"))
				start_customer_countdown()
			else:
				hud.set_message(tr("Oh! ...You needed to clear a line that time."))
				delay_between_levels = Tutorials.DELAY_LONG
				PuzzleState.level_performance.lost = true
	
	var level_ids := [
		"tutorial/combo_0", "tutorial/combo_1", "tutorial/combo_2", "tutorial/combo_3",
		"tutorial/combo_4", "tutorial/combo_5", "tutorial/combo_6",
	]
	var new_level_id: String
	if PuzzleState.level_performance.lost:
		new_level_id = CurrentLevel.settings.id
	else:
		new_level_id = level_ids[level_ids.find(CurrentLevel.settings.id) + 1]
	change_level(new_level_id, delay_between_levels)


## Shows a diagram explaining how combos moves work, with an accompanying sensei message.
func _show_next_diagram() -> void:
	var hud_messages := []
	if _show_diagram_count == 0:
		hud_messages.append(tr("Combos earn you extra money! You can build combos by making boxes and clearing lines."
				+ "\n\nOtherwise, dropping two pieces will reset your combo."))
		hud_messages.append(tr("In other words,"
				+ " you get two chances to make a box or clear a line before you lose your combo."
				+ "\n\nDoes that make sense?"))
	else:
		match _show_diagram_count % 4:
			0: hud_messages.append(tr("In other words,"
					+ "you get two chances to make a box or clear a line before you lose your combo."))
			1: hud_messages.append(tr("Arranging two or more pieces into a rectangle will make a box."
					+ "\n\nThat's one easy way to keep your combo alive! Just place two pieces to make a square."))
			2: hud_messages.append(tr("Clearing a line will also continue your combo."
					+ " But, you don't have to clear a line with every piece!"
					+ "\n\nYou can drop one piece without breaking your combo."))
			3: hud_messages.append(tr("Your combo's only interrupted if you drop two pieces without doing something."
					+ "\n\nSo, you're allowed to make one mistake! Or, to use one piece to plan ahead."))
	hud.set_messages(hud_messages)
	
	hud.diagram.show_diagram(_combo_diagram, true)
	_show_diagram_count += 1


func _on_PieceManager_piece_spawned(_piece: ActivePiece) -> void:
	_did_end_combo = false


## After a piece is written to the playfield, we check if the player should advance further in the tutorial.
##
## We also sometimes display messages from the sensei.
func _on_PuzzleState_after_piece_written() -> void:
	match CurrentLevel.settings.id:
		"tutorial/combo_0", "tutorial/combo_2":
			if hud.skill_tally_item("Combo").is_complete():
				_advance_level()
			elif _did_end_combo:
				_advance_level()
		"tutorial/combo_3":
			if PuzzleState.level_performance.pieces == 2:
				var message := tr("Oops! I can still make the cake box, but my combo already broke.")
				start_timer_after_all_messages_shown(3.0) \
						.connect("timeout", self, "_on_Timer_timeout_set_message", [message])
			if PuzzleState.level_performance.pieces >= 3:
				PuzzleState.start_timer(3.0) \
						.connect("timeout", self, "_on_Timer_timeout_advance_level")
		"tutorial/combo_4":
			if PuzzleState.level_performance.pieces >= 4:
				hud.set_message(tr("There, I did it!\n\nThat was tricky."))
				start_timer_after_all_messages_shown(3.0) \
						.connect("timeout", self, "_on_Timer_timeout_advance_level")
		"tutorial/combo_5":
			if hud.skill_tally_item("CakeBox").is_complete():
				_advance_level()
			elif _did_end_combo:
				_advance_level()
		"tutorial/combo_6":
			if not _showed_end_of_level_message:
				var first_customer_score: int = PuzzleState.customer_scores[0]
				if _did_end_combo or first_customer_score >= 120:
					if first_customer_score >= 120:
						hud.set_message(tr("Wow, I didn't expect that! Great job.\n\nYou're already a combo master!"))
						hud.enqueue_pop_out()
					else:
						hud.set_message(tr("Oh no, you broke your combo without reaching ¥120!"
								+ "\n\nWell, don't worry about that."))
						hud.enqueue_message(tr("¥120 is just a number I pulled out of my, um. ...Out of thin air."
								+ ("\n\n%s is good too!" % [StringUtils.format_money(first_customer_score)])))
						hud.enqueue_pop_out()
					_showed_end_of_level_message = true


func _on_Playfield_line_cleared(_y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	hud.skill_tally_item("Combo").increment()


func _on_Playfield_box_built(_rect: Rect2, color: int) -> void:
	if Foods.is_cake_box(color):
		_cakes_built += 1
		hud.skill_tally_item("CakeBox").increment()


func _on_PuzzleState_combo_ended() -> void:
	_did_end_combo = true


func _on_PuzzleState_after_game_prepared() -> void:
	hud.show_skill_tally_items()
	hud.skill_tally_item("Combo").visible = false
	hud.skill_tally_item("CakeBox").visible = false
	
	_prepared_levels.clear()
	_cakes_built = 0
	_show_diagram_count = 0
	
	prepare_tutorial_level()


func _on_Timer_timeout_set_message(message: String) -> void:
	hud.set_message(message)


func _on_Timer_timeout_advance_level() -> void:
	_advance_level()


func _on_TutorialDiagram_ok_chosen() -> void:
	_advance_level()


func _on_TutorialDiagram_help_chosen() -> void:
	_show_next_diagram()
