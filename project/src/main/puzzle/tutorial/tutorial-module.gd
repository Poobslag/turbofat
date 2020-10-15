class_name TutorialModule
extends Node
"""
Generic tutorial module for all tutorials.

Subclasses can show messages and advances the player through the tutorial as they complete tasks.
"""

export (NodePath) var _hud_path: NodePath

# generic nodes used by tutorial module subclasses
onready var hud: TutorialHud = get_node(_hud_path)
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
