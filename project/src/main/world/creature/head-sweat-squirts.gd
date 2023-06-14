#@tool #uncomment to view creature in editor
extends GPUParticles2D
## Manages the sweat drops which leap from the creature's head.

@export var creature_visuals_path: NodePath: set = set_creature_visuals_path

var _creature_visuals: CreatureVisuals

func _ready() -> void:
	_refresh_creature_visuals_path()


func set_creature_visuals_path(new_creature_visuals_path: NodePath) -> void:
	creature_visuals_path = new_creature_visuals_path
	_refresh_creature_visuals_path()


func _refresh_creature_visuals_path() -> void:
	if not (is_inside_tree() and not creature_visuals_path.is_empty()):
		return
	
	if _creature_visuals:
		_creature_visuals.comfort_changed.disconnect(_on_CreatureVisuals_comfort_changed)
		_creature_visuals.dna_loaded.disconnect(_on_CreatureVisuals_dna_loaded)
	
	_creature_visuals = get_node(creature_visuals_path)
	
	if _creature_visuals:
		_creature_visuals.comfort_changed.connect(_on_CreatureVisuals_comfort_changed)
		_creature_visuals.dna_loaded.connect(_on_CreatureVisuals_dna_loaded)


func _on_CreatureVisuals_comfort_changed() -> void:
	emitting = _creature_visuals.comfort < -0.6
	if emitting:
		var sweat_amount: float = clamp(inverse_lerp(-0.6, -1.0, _creature_visuals.comfort), 0.0, 1.0)
		amount = lerp(3, 8, sweat_amount)


func _on_CreatureVisuals_dna_loaded() -> void:
	var particles_material: ParticleProcessMaterial = process_material
	particles_material.scale_max = _creature_visuals.scale.x * 1.7
	particles_material.scale_min = particles_material.scale_max
