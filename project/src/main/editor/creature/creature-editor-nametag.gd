extends NametagPanel
## Shows the player's name in the creature editor.

export (NodePath) var overworld_environment_path: NodePath

onready var _overworld_environment: OverworldEnvironment = get_node(overworld_environment_path)

func _ready() -> void:
	_player().connect("creature_name_changed", self, "_on_Creature_creature_name_changed")
	_player().connect("dna_loaded", self, "_on_Creature_dna_loaded")
	_refresh()


## Refreshes the text and panel color based on the player's name and chat theme.
func _refresh() -> void:
	refresh_creature(_player())


func _player() -> Creature:
	return _overworld_environment.player


func _on_Creature_creature_name_changed() -> void:
	_refresh()


func _on_Creature_dna_loaded() -> void:
	_refresh()
