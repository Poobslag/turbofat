class_name OvalShadow
extends Sprite2D
## Script which updates the position of a shadow beneath a 'shadow caster'.

@export var shadow_caster_path: NodePath: set = set_shadow_caster_path

## Shadow caster this shadow is for
var _shadow_caster: Node2D

func _ready() -> void:
	visible = false
	_refresh_shadow_caster_path()


func _physics_process(_delta: float) -> void:
	visible = _shadow_caster.visible
	position = _shadow_caster.position
	modulate.a = _shadow_caster.modulate.a


func set_shadow_caster_path(new_shadow_caster_path: NodePath) -> void:
	shadow_caster_path = new_shadow_caster_path
	_refresh_shadow_caster_path()


## Connects the shadow to a new shadow caster and updates its position.
func _refresh_shadow_caster_path() -> void:
	if not (is_inside_tree() and not shadow_caster_path.is_empty()):
		return
	
	_shadow_caster = get_node(shadow_caster_path)
	position = _shadow_caster.position
	
	var shadow_scale: float = 1.0
	if _shadow_caster.has_meta("shadow_scale"):
		shadow_scale = _shadow_caster.get_meta("shadow_scale")
	scale = Vector2(0.17 * shadow_scale, 0.17 * shadow_scale)
