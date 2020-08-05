extends Node
"""
Manages nametags which label creatures in the creature editor.

Creates a nametag for each creature in the scene.
"""

# nametag colors for focused/unfocused creatures
const NAMETAG_HIGHLIGHT = Color("303060")
const NAMETAG_LOWLIGHT = Color.darkgray

export (PackedScene) var HookableNametagScene: PackedScene

# mapping from Creatures to NametagPanels
var _creature_to_nametag: Dictionary

func _ready() -> void:
	# create nametags for all creatures in the scene
	for creature_obj in get_tree().get_nodes_in_group("creatures"):
		var creature: Creature = creature_obj
		var hookable_nametag: Node2D = HookableNametagScene.instance()
		var nametag: Panel = hookable_nametag.get_node("Nametag")
		add_child(hookable_nametag)
		creature.get_node("NametagHook").remote_path = creature.get_node("NametagHook").get_path_to(hookable_nametag)
		creature.connect("creature_name_changed", self, "_on_Creature_creature_name_changed", [creature, nametag])
		_creature_to_nametag[creature] = nametag


"""
When a creature is renamed, the corresponding nametag changes its text and position.
"""
func _on_Creature_creature_name_changed(creature: Creature, nametag: Panel) -> void:
	nametag.set_nametag_text(creature.creature_name if creature.creature_name else "(unnamed)")
	nametag.rect_scale = Vector2(0.6, 0.6) if creature.has_meta("main_creature") else Vector2(0.4, 0.4)
	nametag.set_bg_color(NAMETAG_HIGHLIGHT if creature.has_meta("main_creature") else NAMETAG_LOWLIGHT)
	
	nametag.rect_position.x = -nametag.rect_size.x * nametag.rect_scale.x * 0.5
	nametag.rect_position.x += 30 if creature.has_meta("nametag_right") else -10
	nametag.rect_position.y = -nametag.rect_size.y * nametag.rect_scale.y + 20


"""
When a creature is hovered, the nametag colors change.
"""
func _on_CreatureSelector_hovered_creature_changed(value: Creature) -> void:
	if value:
		# creature is highlighted; their nametag is blue, others are gray
		for nametag in _creature_to_nametag.values():
			nametag.set_bg_color(NAMETAG_LOWLIGHT)
		_creature_to_nametag[value].set_bg_color(NAMETAG_HIGHLIGHT)
	else:
		# no creature is highlighted; main nametag is blue, others are gray
		for creature in _creature_to_nametag:
			var nametag: Panel = _creature_to_nametag[creature]
			nametag.set_bg_color(NAMETAG_HIGHLIGHT if creature.has_meta("main_creature") else NAMETAG_LOWLIGHT)
