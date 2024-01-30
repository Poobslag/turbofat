class_name CreditsPieces
extends Node2D
## Launches and stores the puzzle pieces which appear in the credits.

export (NodePath) var header_path: NodePath
export (NodePath) var orb_path: NodePath
export (PackedScene) var piece_scene: PackedScene

## key: (int) index of a piece launched by the CreditsOrb
## value: (int) index of a letter in the text 'turbo fat' in CreditsHeader
var _target_letters_by_piece_index: Dictionary = {}

## index of the next unlaunched piece
var _next_piece_index := 0

onready var _orb: CreditsOrb = get_node(orb_path)
onready var _header: CreditsHeader = get_node(header_path)

func _ready() -> void:
	_orb.connect("frame_changed", self, "_on_Orb_frame_changed")


## Assigns a piece which, when launched by the CreditsOrb, will target a specific letter in CreditsHeader
##
## Parameters:
## 	'piece_index': index of a piece launched by the CreditsOrb
##
## 	'letter_index': index of a letter in the text 'turbo fat' in CreditsHeader
func set_target_header_letter_for_piece(piece_index: int, letter_index: int) -> void:
	_target_letters_by_piece_index[piece_index] = letter_index


## Initialize a CreditsPiece and adds it to the scene tree.
func _add_credits_piece(piece_index: int) -> void:
	var piece: CreditsPiece = piece_scene.instance()
	piece.initialize(_orb)
	if _target_letters_by_piece_index.has(piece_index):
		var target_position := _letter_target_position(_target_letters_by_piece_index[piece_index])
		piece.set_target_position(target_position)
	
	add_child(piece)


## Returns the target position for a HeaderLetter.
##
## CreditsHeader provides the positions of letters in its header, but these positions need to be translated to local
## coordinates.
func _letter_target_position(header_letter_index: int) -> Vector2:
	var header_letter_position := _header.get_visible_letter_position(header_letter_index)
	var translated_header_letter_position: Vector2 = \
			_header.get_global_transform().translated(header_letter_position).origin \
			- get_parent().get_global_transform().origin
	return translated_header_letter_position


## When the orb advances to the next frame, we launch a puzzle piece.
func _on_Orb_frame_changed() -> void:
	var piece_index := _next_piece_index
	_next_piece_index += 1
	
	# Avoid adding pieces when the orb is offscreen -- otherwise they fly onscreen even when the orb isn't visible.
	if not _orb.is_offscreen():
		_add_credits_piece(piece_index)
