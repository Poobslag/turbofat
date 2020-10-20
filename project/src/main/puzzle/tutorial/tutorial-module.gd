class_name TutorialModule
extends Node
"""
Generic tutorial module for all tutorials.

Subclasses can show messages and advances the player through the tutorial as they complete tasks.
"""

# generic nodes used by tutorial module subclasses
var hud: TutorialHud
var puzzle: Puzzle
var playfield: Playfield
var piece_manager: PieceManager

func _ready() -> void:
	puzzle = hud.puzzle
	playfield = puzzle.get_playfield()
	piece_manager = puzzle.get_piece_manager()
	
	for skill_tally_item in $SkillTallyItems.get_children():
		if skill_tally_item is SkillTallyItem:
			var new_item: SkillTallyItem = skill_tally_item.duplicate()
			new_item.puzzle = hud.puzzle
			hud.add_skill_tally_item(new_item)


"""
Starts a countdown and switches from tutorial music to regular music.

This is used at the end of each tutorial when customers come in.
"""
func start_customer_countdown() -> void:
	yield(PuzzleScore, "after_level_changed")
	MusicPlayer.play_upbeat_bgm()
	puzzle.start_level_countdown()
