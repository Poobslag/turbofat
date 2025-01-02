extends TutorialModule
## Tutorial module for the 'Meet Spins' tutorial.
##
## Shows messages and advances the player through the tutorial as they complete tasks.

enum PieceMovementType {
	NONE,
	ROTATE,
	FLIP,
	MOVE_X,
	MOVE_Y,
}

## player statistics for the current tutorial section
var _failure_count := 0

## how many times the player's flipped the piece to annoy fat sensei
var _annoying_flip_count := 0

## set of level IDs which the player has attempted during this tutorial
## key: (String) level id
## value: (bool) true
var _prepared_levels: Dictionary

## set of level IDs which the player has succeeded at during this tutorial
## key: (String) level id
## value: (bool) true
var _failed_levels: Dictionary

## Most recent way the piece moved, such as rotating, flipping or dropping. This determines whether the player
## performed a spin move, a flip move, or something else.
var _last_piece_movement: int = PieceMovementType.NONE

## Historical information about the piece's position and orientation. This is used to populate the
## _last_piece_movement field.
var _prev_piece: ActivePiece
var _prev_piece_orientation: int
var _prev_piece_pos: Vector2

func _ready() -> void:
	PuzzleState.connect("after_game_prepared", self, "_on_PuzzleState_after_game_prepared")
	PuzzleState.connect("after_piece_written", self, "_on_PuzzleState_after_piece_written")
	PuzzleState.connect("topped_out", self, "_on_PuzzleState_topped_out")
	
	hud.set_message(tr("Let's learn about spin moves!"
			+ "\n\nMaybe you already figured out how they work, but I'll try to teach you something new."))


func _physics_process(_delta: float) -> void:
	_refresh_last_piece_movement()


func prepare_tutorial_level() -> void:
	.prepare_tutorial_level()
	_last_piece_movement = PieceMovementType.NONE
	
	match CurrentLevel.settings.id:
		"tutorial/spins_0":
			_prepare_box_tally_item()
			if _failure_count >= 2:
				# third, fourth attempt, they failed following the explanation
				hud.set_message(tr("Try again!\n\nMove the piece into position and rotate it."))
			elif _failure_count >= 1:
				# second attempt, following an explanation
				hud.set_message(tr("Now you try!\n\nMove the piece into position and rotate it."))
			else:
				# first attempt
				hud.set_message(tr("Can you make a cake box with this piece?\n\nIt doesn't quite fit, does it?"))
		"tutorial/spins_0_example":
			hud.set_message(tr("A spin move is where you rotate a piece, locking it in place like this."))
			if _failed_levels.has("tutorial/spins_0"):
				hud.enqueue_message(tr("See, it fits perfectly after I rotate it. Isn't that clever?"))
			hud.enqueue_message(tr("Customers won't tip extra for spin moves or anything like that!"
					+ "\n\n...But they're useful sometimes."))
		"tutorial/spins_1":
			_prepare_box_tally_item()
			if _failure_count >= 3 and not _prepared_levels.has("tutorial/spins_1_example"):
				hud.set_message(tr("This one's hard to figure out.\n\nGive it one last try! Then I'll show you."))
			elif _failure_count >= 1:
				hud.set_message(tr("Try again!\n\nMove the piece into position and rotate it."))
			else:
				hud.set_message(tr("Let's try another spin move.\n\nSee if you can make a box here."))
		"tutorial/spins_1_example":
			hud.set_message(tr("So if you rotate it left from here, it magically goes in.\n\nPop!"))
			hud.enqueue_message(tr("Sorry, I know it doesn't make much sense!\n\n...It's just how it works."))
		"tutorial/spins_1_fixed":
			_prepare_box_tally_item()
			if _failure_count >= 3 and not _prepared_levels.has("tutorial/spins_1_fixed_example"):
				hud.set_message(tr("This one's hard to figure out.\n\nGive it one last try! Then I'll show you."))
			elif _failure_count >= 1:
				hud.set_message(tr("Try again!\n\nMove the piece into position and rotate it."))
			else:
				hud.set_message(tr("Here, now your squish move won't work."
						+ "\n\nSee if you can do it by spinning this time."))
		"tutorial/spins_1_fixed_example":
			hud.set_message(tr("So if you rotate it left from here, it magically goes in.\n\nPop!"))
			hud.enqueue_message(tr("Sorry, I know it doesn't make much sense!\n\n...It's just how it works."))
		"tutorial/spins_2":
			_prepare_box_tally_item()
			if _failure_count >= 3 and not _prepared_levels.has("tutorial/spins_2_example"):
				hud.set_message(tr("This one's hard to figure out.\n\nGive it one last try! Then I'll show you."))
			elif _failure_count >= 1:
				hud.set_message(tr("Try again!\n\nMove the piece into position and rotate it."))
			else:
				hud.set_message(tr("How about with a U-Block, can you spin here?"))
		"tutorial/spins_2_example":
			hud.set_message(tr("So if you rotate it right from here, it magically goes in.\n\nPop!"))
			hud.enqueue_message(tr("Sorry, I know it doesn't make much sense!\n\n...It's just how it works."))
		"tutorial/spins_3":
			_prepare_box_tally_item()
			if _failure_count >= 3 and not _prepared_levels.has("tutorial/spins_3_example"):
				hud.set_message(tr("This one's hard to figure out.\n\nGive it one last try! Then I'll show you."))
			elif _failure_count >= 1:
				hud.set_message(tr("Try again!\n\nMove the piece into position and rotate it."))
			else:
				hud.set_message(tr("Oh! It's getting a little cramped.\n\nCan you still spin here?"))
		"tutorial/spins_3_example":
			hud.set_message(tr("So if you rotate it left from here, it magically goes in.\n\nPop!"))
			hud.enqueue_message(tr("Sorry, I know it doesn't make much sense!\n\n...It's just how it works."))
		"tutorial/spins_4":
			_prepare_box_tally_item()
			if _failure_count >= 1:
				# second, third attempt; they failed following the explanation
				hud.set_message(tr("Try again!\n\nPress both rotate buttons to flip the piece into place."))
			else:
				hud.set_message(tr("How about like this?\n\nCan you find a way to spin here?"))
		"tutorial/spins_4_example":
			_prepare_box_tally_item()
			hud.set_message(tr("If you press both rotate buttons, the piece flips!"))
			hud.enqueue_message(tr("Flipping a piece is helpful if you want to play very fast."
					+ "\n\n...But it's necessary for some spin moves, too."))
		"tutorial/spins_5":
			_prepare_box_tally_item()
			if _failure_count >= 3 and not _prepared_levels.has("tutorial/spins_5_example"):
				hud.set_message(tr("This one's hard to figure out.\n\nGive it one last try! Then I'll show you."))
			elif _failure_count >= 1:
				hud.set_message(tr("Try again!\n\nMove the piece into position and rotate it."))
			else:
				hud.set_message(tr("How about this T-Block? Can you spin this one too?"))
		"tutorial/spins_5_example":
			hud.set_message(tr("So if you rotate it right from here, it magically goes in.\n\nPop!"))
			hud.enqueue_message(tr("Sorry, I know it doesn't make much sense!\n\n...It's just how it works."))
		"tutorial/spins_6":
			_prepare_box_tally_item()
			hud.set_message(tr("What do you think about this? Can you spin this piece in?"))
		"tutorial/spins_7":
			_prepare_box_tally_item()
			if _failure_count >= 3 and not _prepared_levels.has("tutorial/spins_7_example"):
				hud.set_message(tr("This one's hard to figure out.\n\nGive it one last try! Then I'll show you."))
			elif _failure_count >= 1:
				hud.set_message(tr("Try again!\n\nDon't forget you can use squish moves, too."))
			else:
				hud.set_message(tr("Here's something a little more sensible.\n\nCan you find a way to spin here?"))
		"tutorial/spins_7_example":
			hud.set_message(tr("So if you rotate it right from here, you can squish it in.\n\nPop!"))
			hud.enqueue_message(tr("Sorry, I know it doesn't make much sense!\n\n...It's just how it works."))
		"tutorial/spins_secret":
			_prepare_box_tally_item()
			if _failure_count == 0:
				hud.set_message(tr("Okay there Flippy Longstocking, why don't you try this one?"))
			else:
				match _failure_count % 7:
					1, 3, 6:
						hud.set_message(tr("Try again!\n\nMove the piece into position and rotate it."))
					2, 4:
						hud.set_message(tr("Try again!\n\nDon't forget you can use squish moves, too."))
					5:
						hud.set_message(tr("Try again!\n\nPress both rotate buttons to flip the piece into place."))
		"tutorial/spins_8":
			dismiss_sensei([tr("Well done!\n\nTry showing off your new spin moves in front of these customers.")])
	
	_prepared_levels[CurrentLevel.settings.id] = true


## Updates the _last_piece_movement field, as well as historical information about the piece's position and
## orientation.
func _refresh_last_piece_movement() -> void:
	if piece_manager.piece == _prev_piece:
		if _prev_piece_orientation != _prev_piece.orientation:
			if piece_manager.physics.rotator.just_flipped:
				_last_piece_movement = PieceMovementType.FLIP
			else:
				_last_piece_movement = PieceMovementType.ROTATE
		elif _prev_piece_pos.x != _prev_piece.pos.x:
			## piece was moved horizontally
			_last_piece_movement = PieceMovementType.MOVE_X
		elif _prev_piece_pos.y != _prev_piece.pos.y:
			## piece was moved vertically -- hard dropped, soft dropped, squished or affected by gravity
			_last_piece_movement = PieceMovementType.MOVE_Y
	else:
		_prev_piece = piece_manager.piece
		if _prev_piece.type == PieceTypes.piece_null:
			## piece_manager.piece briefly becomes a null piece during line clears. this doesn't cause
			## _last_piece_movement to reset
			pass
		else:
			## when a new piece comes out, we reset _last_piece_movement
			_last_piece_movement = PieceMovementType.NONE
	
	_prev_piece_orientation = _prev_piece.orientation
	_prev_piece_pos = _prev_piece.pos


func _prepare_box_tally_item() -> void:
	hud.skill_tally_item("Box").visible = true
	hud.skill_tally_item("Box").reset()


## Advance to the next level in the tutorial.
func _advance_level() -> void:
	PuzzleState.level_performance.lost = false
	var delay_between_levels := Tutorials.DELAY_SHORT
	var new_level_id: String
	
	match CurrentLevel.settings.id:
		"tutorial/spins_0":
			if _failure_count >= 1:
				# second try, after the spin tutorial
				if hud.skill_tally_item("Box").value >= 1:
					hud.set_message(tr("Good job!"))
					new_level_id = "tutorial/spins_1"
				else:
					hud.set_message(tr("Oops! Why don't we try that again."))
					PuzzleState.level_performance.lost = true
			else:
				# first try, before the spin tutorial
				if hud.skill_tally_item("Box").value >= 1:
					hud.set_message(tr("That's right! You understand spin moves already."))
				else:
					hud.set_message(tr("Oh, that's not right. Let me show you how spin moves work!"))
					new_level_id = "tutorial/spins_0_example"
					PuzzleState.level_performance.lost = true
		"tutorial/spins_0_example":
			if _failed_levels.has("tutorial/spins_0"):
				# need to retry the previous level
				new_level_id = "tutorial/spins_0"
		"tutorial/spins_1":
			if hud.skill_tally_item("Box").value >= 1:
				match _last_piece_movement:
					PieceMovementType.MOVE_Y:
						hud.set_message(tr("Ahha ha, yes! It's easier to perform a squish move here."
								+ "\n\n...This was sort of a trick question."))
						new_level_id = "tutorial/spins_1_fixed"
					PieceMovementType.FLIP:
						hud.set_message(tr("WHAT!? You're not supposed to know about that!"
								+ "\n\n...I'll just pretend you did something more sensible."))
						_annoying_flip_count += 1
					_:
						hud.set_message(tr("Good job! Although, it's probably better to squish here."))
			else:
				if _failure_count >= 3 and not _prepared_levels.has("tutorial/spins_1_example"):
					hud.set_message(tr("This one's really tricky! Let me show you."))
					new_level_id = "tutorial/spins_1_example"
				else:
					hud.set_message(tr("Oops that's not right. This one's a little tricky..."))
				PuzzleState.level_performance.lost = true
		"tutorial/spins_1_example":
			new_level_id = "tutorial/spins_1"
		"tutorial/spins_1_fixed":
			if hud.skill_tally_item("Box").value >= 1:
				match _last_piece_movement:
					PieceMovementType.FLIP:
						hud.set_message(tr("WHAT!? You're not supposed to know about that!"
								+ "\n\n...I'll just pretend you did something more sensible."))
						_annoying_flip_count += 1
					_:
						hud.set_message(tr("Good job! If you rotate it left, it goes right in."))
				new_level_id = "tutorial/spins_2"
			else:
				if _failure_count >= 3 and not _prepared_levels.has("tutorial/spins_1_fixed_example"):
					hud.set_message(tr("This one's really tricky! Let me show you."))
					new_level_id = "tutorial/spins_1_fixed_example"
				else:
					hud.set_message(tr("Oops that's not right. This one's a little tricky..."))
				PuzzleState.level_performance.lost = true
		"tutorial/spins_1_fixed_example":
			new_level_id = "tutorial/spins_1_fixed"
		"tutorial/spins_2":
			if hud.skill_tally_item("Box").value >= 1:
				hud.set_message(tr("Good job! It works here too, it's just a little different."))
			else:
				if _failure_count >= 3 and not _prepared_levels.has("tutorial/spins_2_example"):
					hud.set_message(tr("This one's really tricky! Let me show you."))
					new_level_id = "tutorial/spins_2_example"
				else:
					hud.set_message(tr("Oops! That didn't work..."))
				PuzzleState.level_performance.lost = true
		"tutorial/spins_2_example":
			new_level_id = "tutorial/spins_2"
		"tutorial/spins_3":
			if hud.skill_tally_item("Box").value >= 1:
				match _last_piece_movement:
					PieceMovementType.FLIP:
						match _annoying_flip_count:
							0: hud.set_message(tr("WHAT!? You're not supposed to know about that!"
									+ "\n\n...I'll just pretend you did something more sensible."))
							_: hud.set_message(tr("Stop flipping your piece like that, you big showboat!"
									+ "\n\nYou're ruining my tutorial."))
						_annoying_flip_count += 1
					_:
						hud.set_message(tr("That's right! Good job."))
			else:
				if _failure_count >= 3 and not _prepared_levels.has("tutorial/spins_3_example"):
					hud.set_message(tr("This one's really tricky! Let me show you."))
					new_level_id = "tutorial/spins_3_example"
				else:
					hud.set_message(tr("Oops! That didn't work..."))
				PuzzleState.level_performance.lost = true
		"tutorial/spins_3_example":
			new_level_id = "tutorial/spins_3"
		"tutorial/spins_4":
			if _failure_count >= 1:
				# second try, after the flip tutorial
				if hud.skill_tally_item("Box").value >= 1:
					hud.set_message(tr("Good job! I knew you could do it."))
					new_level_id = "tutorial/spins_5"
				else:
					hud.set_message(tr("Hmm, that's not quite it. Try pressing both rotate buttons."
							+ "\n\nYou need to squish first, too."))
					PuzzleState.level_performance.lost = true
			else:
				# first try, before the flip tutorial
				if hud.skill_tally_item("Box").value >= 1:
					match _last_piece_movement:
						PieceMovementType.FLIP:
							match _annoying_flip_count:
								0: hud.set_message(tr("WHAT!? You're not supposed to know about that!"
										+ "\n\n...I'll just pretend you did something more sensible."))
								1: hud.set_message(tr("Stop flipping your piece like that, you big showboat!"
										+ "\n\nYou're ruining my tutorial."))
								_: hud.set_message(tr("Hmph, I'll bet you think you're pretty clever..."))
							_annoying_flip_count += 1
						_:
							hud.set_message(tr("That's right! Good job."))
					new_level_id = "tutorial/spins_5" if _annoying_flip_count < 3 else "tutorial/spins_secret"
				else:
					hud.set_message(tr("Oh, that was a good try but this one's a little special!"
							+ "\n\nLet me show you something."))
					new_level_id = "tutorial/spins_4_example"
					PuzzleState.level_performance.lost = true
		"tutorial/spins_4_example":
			if _failed_levels.has("tutorial/spins_4"):
				# need to retry the previous level
				new_level_id = "tutorial/spins_4"
		"tutorial/spins_5":
			if hud.skill_tally_item("Box").value >= 1:
				match _last_piece_movement:
					PieceMovementType.MOVE_Y:
						hud.set_message(tr("That's right. You don't need a spin move here, you can just squish it."))
					PieceMovementType.FLIP:
						match _annoying_flip_count:
							0, 1:
								# now that the player has been taught about flip moves, it's not as annoying
								hud.set_message(tr("Ahha ha. Yes, very cute."))
							_:
								hud.set_message(tr("Hmph, I'll bet you think you're pretty clever..."))
								_annoying_flip_count += 1
						new_level_id = "tutorial/spins_6" if _annoying_flip_count < 3 else "tutorial/spins_secret"
					_:
						hud.set_message(tr("Good job!\n\nYou could just squish that in, too."
								+ " You don't always need spin moves."))
			else:
				if _failure_count >= 3 and not _prepared_levels.has("tutorial/spins_5_example"):
					hud.set_message(tr("This one's really tricky! Let me show you."))
					new_level_id = "tutorial/spins_5_example"
				else:
					hud.set_message(tr("Oops! That wasn't it."))
				PuzzleState.level_performance.lost = true
		"tutorial/spins_5_example":
			new_level_id = "tutorial/spins_5"
		"tutorial/spins_6":
			if hud.skill_tally_item("Box").value >= 1:
				hud.set_message(tr("What!? Pieces can't just rotate through walls! That's cheating."))
			else:
				hud.set_message(tr("Well of course you can't."
						+ "\n\nPieces can't just rotate through walls! That would be cheating."))
				PuzzleState.level_performance.lost = true
				new_level_id = "tutorial/spins_7"
		"tutorial/spins_7":
			if hud.skill_tally_item("Box").value >= 1:
				hud.set_message(tr("Good job!\n\nPieces can squish through walls, that doesn't count as cheating."))
				start_customer_countdown()
			else:
				if _failure_count >= 3 and not _prepared_levels.has("tutorial/spins_7_example"):
					hud.set_message(tr("This one's really tricky! Let me show you."))
					new_level_id = "tutorial/spins_7_example"
				else:
					hud.set_message(tr("Oops! That wasn't it."))
				PuzzleState.level_performance.lost = true
		"tutorial/spins_7_example":
			new_level_id = "tutorial/spins_7"
		"tutorial/spins_secret":
			if hud.skill_tally_item("Box").value >= 1:
				if _failure_count <= 1:
					# first or second try
					hud.set_message(tr("What is a person like you doing with tutorials anyways?"
							+ " Get out of here, you clown!"))
				else:
					# took a few tries
					hud.set_message(tr("Good job! I knew you could do it."))
				new_level_id = "tutorial/spins_8"
				start_customer_countdown()
			else:
				var failure_message: String
				match _failure_count % 10:
					0: failure_message = tr("Oops, don't forget to rotate!")
					1: failure_message = tr("Hmm, that wasn't it.")
					2: failure_message = tr("Oh no! That wasn't very good.")
					3: failure_message = tr("Oh! What happened to the clever person who was ruining my tutorial?"
							+ "\n\nDid they step away?")
					4: failure_message = tr("Oops! I know this can be tricky sometimes.")
					5: failure_message = tr("Hmm, try again. Remember to rotate the piece before it locks into place.")
					6: failure_message = tr("Did you forget how to rotate?"
							+ "\n\nI'm sure it's confusing, so many big buttons to press...")
					7: failure_message = tr("Oh no! that wasn't it.")
					8: failure_message = tr("Oops! That wasn't it, either.")
					8: failure_message = tr("Oh, don't just mash random buttons!\n\nYou're not Eddy Gordo...")
					9: failure_message = tr("Hmm, that's not quite it. Try pressing both rotate buttons."
							+ "\n\nYou need to squish first, too.")
				hud.set_message(failure_message)
				PuzzleState.level_performance.lost = true
	
	var level_ids := [
		"tutorial/spins_0", "tutorial/spins_0_example",
		"tutorial/spins_1", "tutorial/spins_2", "tutorial/spins_3",
		"tutorial/spins_4", "tutorial/spins_4_example",
		"tutorial/spins_5", "tutorial/spins_6", "tutorial/spins_7", "tutorial/spins_8",
	]
	
	if PuzzleState.level_performance.lost:
		_failed_levels[CurrentLevel.settings.id] = true
		if not new_level_id:
			# by default, retry the current tutorial section
			new_level_id = CurrentLevel.settings.id
			_failure_count += 1
	else:
		_failure_count = 1 if _failed_levels.has(new_level_id) else 0
		if not new_level_id:
			# by default, progress to the next tutorial section
			new_level_id = level_ids[level_ids.find(CurrentLevel.settings.id) + 1]
	
	change_level(new_level_id, delay_between_levels)


## After a piece is written to the playfield, we check if the player should advance further in the tutorial.
##
## We also sometimes display messages from the sensei.
func _on_PuzzleState_after_piece_written() -> void:
	match CurrentLevel.settings.id:
		"tutorial/spins_0", "tutorial/spins_1", "tutorial/spins_1_fixed", "tutorial/spins_2", \
		"tutorial/spins_3", "tutorial/spins_4", "tutorial/spins_5", "tutorial/spins_6", \
		"tutorial/spins_7", "tutorial/spins_secret":
			if PuzzleState.level_performance.pieces >= CurrentLevel.settings.finish_condition.value:
				_advance_level()
		"tutorial/spins_0_example", \
		"tutorial/spins_1_example", \
		"tutorial/spins_1_fixed_example", \
		"tutorial/spins_2_example", \
		"tutorial/spins_3_example", \
		"tutorial/spins_4_example", \
		"tutorial/spins_5_example", \
		"tutorial/spins_7_example":
			_advance_level()
		"tutorial/spins_8":
			if PuzzleState.level_performance.pieces == 5:
				hud.set_message(tr("Oh, celery sticks!"
						+ "\n\nThe customers aren't paying any attention to us."))
				hud.enqueue_message(tr("...Well, just show off your new spin moves for me then. I'll watch."))
				hud.enqueue_pop_out()


func _on_PuzzleState_after_game_prepared() -> void:
	_prepared_levels.clear()
	_failed_levels.clear()
	_failure_count = 0
	_annoying_flip_count = 0
	_last_piece_movement = PieceMovementType.NONE
	
	hud.show_skill_tally_items()
	hud.skill_tally_item("Box").visible = false
	prepare_tutorial_level()


func _on_PuzzleState_topped_out() -> void:
	match CurrentLevel.settings.id:
		"tutorial/spins_0", "tutorial/spins_1", "tutorial/spins_1_fixed", "tutorial/spins_2", \
		"tutorial/spins_3", "tutorial/spins_4", "tutorial/spins_5", "tutorial/spins_6", \
		"tutorial/spins_7", "tutorial/spins_secret":
			_advance_level()
