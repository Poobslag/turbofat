class_name TutorialModule
extends Node
## Generic tutorial module for all tutorials.
##
## Subclasses can show messages and advances the player through the tutorial as they complete tasks.

## generic nodes used by tutorial module subclasses
var hud: TutorialHud
var puzzle: Puzzle
var playfield: Playfield
var piece_manager: PieceManager

func _ready() -> void:
	puzzle = hud.puzzle
	playfield = puzzle.get_playfield()
	piece_manager = puzzle.get_piece_manager()
	
	PuzzleState.connect("after_level_changed", self, "_on_PuzzleState_after_level_changed")
	
	for skill_tally_item in $SkillTallyItems.get_children():
		if skill_tally_item is SkillTallyItem:
			var new_item: SkillTallyItem = skill_tally_item.duplicate()
			new_item.puzzle = hud.puzzle
			hud.add_skill_tally_item(new_item)


## Starts a countdown and switches from tutorial music to regular music.
##
## This is used at the end of each tutorial when customers come in.
func start_customer_countdown() -> void:
	yield(PuzzleState, "after_level_changed")
	MusicPlayer.play_upbeat_bgm(false)
	PuzzleState.game_active = true
	puzzle.start_level_countdown()


## Resets the timer and scores and dismisses the sensei, so the player can serve some real customers.
##
## Parameters:
## 	'messages': Array of string messages to be shown when the sensei is dismissed.
func dismiss_sensei(messages: Array) -> void:
	PuzzleState.reset()
	puzzle.scroll_to_new_creature()
	hud.set_messages(messages)
	hud.enqueue_pop_out()


## Prepares the next section of the tutorial.
##
## This includes resetting the combo and hiding all completed skill tally items. Subclasses can override this method to
## prepare other aspects of the level as well.
func prepare_tutorial_level() -> void:
	# Reset the player's combo between puzzle sections. Each tutorial section should have a fresh start; We don't want
	# them to receive a discouraging 'you broke your combo' fanfare at the start of a section.
	PuzzleState.set_combo(0)
	
	# Hide all completed skill tally items.
	for skill_tally_item_obj in hud.skill_tally_items():
		var skill_tally_item: SkillTallyItem = skill_tally_item_obj
		if skill_tally_item.is_complete():
			skill_tally_item.visible = false


## Changes a level after all tutorial messages are shown.
##
## Copy/pasted from PuzzleState.change_level with an extra yield statement added.
func change_level(level_id: String, delay_between_levels: float = PuzzleState.DELAY_SHORT) -> void:
	PuzzleState.emit_signal("before_level_changed", level_id)
	
	if not hud.messages.is_all_messages_visible():
		yield(hud.messages, "all_messages_shown")
	if delay_between_levels:
		yield(get_tree().create_timer(delay_between_levels), "timeout")
	
	var settings := LevelSettings.new()
	settings.load_from_resource(level_id)
	CurrentLevel.switch_level(settings)
	# initialize input_frame to allow for recording/replaying inputs
	PuzzleState.input_frame = 0
	PuzzleState.emit_signal("after_level_changed")


func _on_PuzzleState_after_level_changed() -> void:
	prepare_tutorial_level()
