extends TutorialModule
## Tutorial module for the 'Basic Techniques' tutorial.
##
## Shows messages and advances the player through the tutorial as they complete tasks.

## tracks what the player has done during the current tutorial section
var _squish_moves := 0
var _boxes_built := 0

## tracks what the player did with the most recent piece
var _did_squish_move := false
var _did_build_box := false

## Number of times the diagram has been shown. We cycle through different diagrams and chat choices.
var _show_diagram_count := 0

## set of level IDs which the player has attempted during this tutorial
## key: (String) level id
## value: (int) number of attempts, initialized to '1' during the player's first attempt
var _level_attempt_count: Dictionary

var _squish_diagram_0 := preload("res://assets/main/puzzle/tutorial/squish-diagram-0.png")
var _squish_diagram_1 := preload("res://assets/main/puzzle/tutorial/squish-diagram-1.png")

func _ready() -> void:
	super()
	PuzzleState.after_game_prepared.connect(_on_PuzzleState_after_game_prepared)
	PuzzleState.after_piece_written.connect(_on_PuzzleState_after_piece_written)
	
	playfield.box_built.connect(_on_Playfield_box_built)
	piece_manager.squish_moved.connect(_on_PieceManager_squish_moved)
	piece_manager.piece_spawned.connect(_on_PieceManager_piece_spawned)
	hud.diagram.ok_chosen.connect(_on_TutorialDiagram_ok_chosen)
	hud.diagram.help_chosen.connect(_on_TutorialDiagram_help_chosen)
	
	# display a welcome message before the game starts
	hud.set_message(tr("Today we'll cover some advanced squish move techniques!"
			+ "\n\nBut first, let's make sure you remember the basics."))


func prepare_tutorial_level() -> void:
	super.prepare_tutorial_level()
	## 'true' if the player is retrying a failed tutorial section. We display different messages the second time.
	var failed_section: bool = _level_attempt_count.get(CurrentLevel.settings.id, 0) >= 1
	
	match CurrentLevel.settings.id:
		"tutorial/squish_0":
			hud.skill_tally_item("SquishMove").visible = true
			hud.set_message(tr("Hold soft drop to squish pieces through this gap."))
		"tutorial/squish_1":
			_show_next_diagram()
		"tutorial/squish_2":
			hud.skill_tally_item("SnackBox").visible = true
			hud.set_message(tr("So, which of these snack boxes can be completed with a squish move?"))
		"tutorial/squish_3":
			hud.skill_tally_item("SnackBox").visible = true
			hud.set_message(tr("How about now, can you find a way to squish here?"))
		"tutorial/squish_4":
			hud.skill_tally_item("SnackBox").visible = true
			hud.set_message(tr("What do you think about this one? Is it possible to make a snack box here?"))
		"tutorial/squish_5":
			hud.skill_tally_item("LineClear").visible = true
			hud.skill_tally_item("LineClear").reset()
			PuzzleState.level_performance.lines = 0
			PuzzleState.level_performance.pieces = 0
			if failed_section:
				hud.set_message(tr("Here, let me help you with that."))
			else:
				hud.set_message(tr("Of course, squish moves aren't always about being very,"
							+ " very clever. ...Sometimes we make mistakes, too."))
		"tutorial/squish_6":
			hud.skill_tally_item("LineClear").visible = true
			hud.skill_tally_item("LineClear").reset()
			PuzzleState.level_performance.lines = 0
			PuzzleState.level_performance.pieces = 0
			if failed_section:
				hud.set_message(tr("Should I make it worse this time?\n\nNo, that would be mean."))
			else:
				hud.set_message(tr("Hmmm... What are you up to this time?"))
		"tutorial/squish_7":
			dismiss_sensei([tr("Your training is complete!\n\nBut don't let it go to your head,"
					+ " we still have some customers to take care of.")])
	
	var new_attempt_count: int = _level_attempt_count.get(CurrentLevel.settings.id, 0) + 1
	_level_attempt_count[CurrentLevel.settings.id] = new_attempt_count


## Advance to the next level in the tutorial.
func _advance_level() -> void:
	PuzzleState.level_performance.lost = false
	var delay_between_levels := Tutorials.DELAY_SHORT
	match CurrentLevel.settings.id:
		"tutorial/squish_1":
			# no delay for the non-interactive segment where we show the player a diagram
			delay_between_levels = Tutorials.DELAY_NONE
		"tutorial/squish_2":
			hud.set_message(tr("Yes, that's right."))
		"tutorial/squish_3":
			hud.set_message(tr("That's right! Hmm, how about something tricky..."))
		"tutorial/squish_4":
			hud.set_message(tr("Wow, okay! ...I need to think of some harder puzzles."))
		"tutorial/squish_5":
			if PuzzleState.level_performance.lines >= 3:
				hud.set_message(tr("Good job!"))
			else:
				PuzzleState.level_performance.lost = true
				hud.set_message(tr("Oops! ...Let's try that again."))
		"tutorial/squish_6":
			if PuzzleState.level_performance.lines >= 3:
				hud.set_message(tr("Wow! ...I had a few more of these planned, but it looks like you get the idea."))
				start_customer_countdown()
			else:
				PuzzleState.level_performance.lost = true
				hud.set_message(tr("Oops! ...Let's try that again."))
		_:
			hud.set_message(tr("Good job!"))
	var level_ids := [
		"tutorial/squish_0", "tutorial/squish_1", "tutorial/squish_2", "tutorial/squish_3",
		"tutorial/squish_4", "tutorial/squish_5", "tutorial/squish_6", "tutorial/squish_7"
	]
	var new_level_id: String
	if PuzzleState.level_performance.lost:
		new_level_id = CurrentLevel.settings.id
	else:
		new_level_id = level_ids[level_ids.find(CurrentLevel.settings.id) + 1]
	change_level(new_level_id, delay_between_levels)


func _handle_squish_move_message() -> void:
	if _did_squish_move and _squish_moves == 1 and CurrentLevel.settings.id == "tutorial/squish_0":
		hud.set_message(tr("Good job!\n\nSquish moves help in all sorts of ways."))


## Shows a diagram explaining how squish moves work, with an accompanying sensei message.
func _show_next_diagram() -> void:
	var hud_messages := []
	if _show_diagram_count == 0:
		hud_messages.append(tr("For a piece to squish successfully,"
				+ " one part needs a straight gap down to the target."))
		hud_messages.append(tr("Here are some examples of good and bad squish moves."
				+ "\n\nDoes this make any sense? I know it's a little weird."))
	else:
		match _show_diagram_count % 4:
			0: hud_messages.append(tr("So basically, one part of the piece needs a"
					+ " straight gap down to the target or it won't squish."))
			1: hud_messages.append(tr("These examples on the right don't work,"
					+ " because the piece can't \"see\" where it's going."))
			2: hud_messages.append(tr("You can think of it like..."
					+ "\n\nIf the piece were split into tiny chunks, would each chunk be obstructed?"))
			3: hud_messages.append(tr("These examples on the left work,"
					+ " because one tiny chunk of the piece has a clear path.\n\nIt just needs one."))
	hud.set_messages(hud_messages)
	
	var hud_diagram: Texture2D
	match _show_diagram_count % 2:
		0: hud_diagram = _squish_diagram_0
		1: hud_diagram = _squish_diagram_1
	hud.diagram.show_diagram(hud_diagram, true)
	_show_diagram_count += 1


func _on_PieceManager_piece_spawned(_piece: ActivePiece) -> void:
	_did_squish_move = false
	_did_build_box = false


func _on_PieceManager_squish_moved(_piece: ActivePiece, _old_pos: Vector2i) -> void:
	_did_squish_move = true
	_squish_moves += 1


func _on_Playfield_box_built(_rect: Rect2i, _color: Foods.BoxType) -> void:
	_did_build_box = true
	_boxes_built += 1


## After a piece is written to the playfield, we check if the player should advance further in the tutorial.
##
## We also sometimes display messages from the sensei.
func _on_PuzzleState_after_piece_written() -> void:
	# print tutorial messages if the player did something noteworthy
	_handle_squish_move_message()
	
	match CurrentLevel.settings.id:
		"tutorial/squish_0":
			if not _did_squish_move:
				playfield.tile_map.restore_state()
			if _squish_moves >= 2:
				_advance_level()
		"tutorial/squish_2", "tutorial/squish_3", "tutorial/squish_4":
			if _did_build_box:
				_advance_level()
			else:
				playfield.tile_map.restore_state()
		"tutorial/squish_5":
			if PuzzleState.level_performance.pieces == 1:
				CurrentLevel.settings.input_replay.clear()
				var messages: Array
				if _level_attempt_count.get(CurrentLevel.settings.id, 0) >= 2:
					messages = [tr("Not again! ...Can you clean this up using squish moves?"
								+ "\n\nTry to clear three lines.")]
				else:
					messages = [tr("Oops! Look at the mess you made. ...Can you clean this up using squish moves?"
								+ "\n\nTry to clear three lines.")]
				start_timer_after_all_messages_shown(1.5)\
						.timeout.connect(_on_Timer_timeout_set_messages.bind(messages))
			
			if PuzzleState.level_performance.pieces >= CurrentLevel.settings.finish_condition.value \
					or PuzzleState.level_performance.lines >= 3:
				_advance_level()
		"tutorial/squish_6":
			if PuzzleState.level_performance.pieces == 1:
				CurrentLevel.settings.input_replay.clear()
				var messages: Array
				if _level_attempt_count.get(CurrentLevel.settings.id, 0) >= 2:
					messages = [tr("Oh no, it keeps happening! Well, try to clear three lines."
							+ "\n\nRemember your squish moves!")]
				else:
					messages = [tr("Oh no! Now you've done it.\n\nLook at how clumsy you are!"),
						tr("That's okay.\n\nI'm sure you'll think of a clever way to clean this up, too.")]
				start_timer_after_all_messages_shown(1.5)\
						.timeout.connect(_on_Timer_timeout_set_messages.bind(messages))
			
			if PuzzleState.level_performance.pieces >= CurrentLevel.settings.finish_condition.value \
					or PuzzleState.level_performance.lines >= 3:
				_advance_level()


func _on_PuzzleState_after_game_prepared() -> void:
	hud.show_skill_tally_items()
	hud.skill_tally_item("SquishMove").visible = false
	hud.skill_tally_item("SnackBox").visible = false
	hud.skill_tally_item("LineClear").visible = false
	
	_level_attempt_count.clear()
	_squish_moves = 0
	_boxes_built = 0
	_show_diagram_count = 0
	
	prepare_tutorial_level()


func _on_Timer_timeout_set_messages(messages: Array) -> void:
	hud.set_messages(messages)


func _on_TutorialDiagram_ok_chosen() -> void:
	_advance_level()


func _on_TutorialDiagram_help_chosen() -> void:
	_show_next_diagram()
