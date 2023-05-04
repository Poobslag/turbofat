#tool #uncomment to view creature in editor
extends AnimationPlayer
## AnimationPlayer which animates ears.

@export var creature_visuals_path: NodePath: set = set_creature_visuals_path

var _creature_visuals: CreatureVisuals

func _ready() -> void:
	_refresh_creature_visuals_path()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		# don't trigger animations in editor
		return
	
	if _creature_visuals.oriented_south() and not is_playing():
			play("ambient")
			advance(randf() * current_animation_length)


func set_creature_visuals_path(new_creature_visuals_path: NodePath) -> void:
	creature_visuals_path = new_creature_visuals_path
	_refresh_creature_visuals_path()


## Randomly advances the current animation up to 1.0 seconds. Used to ensure all creatures don't wiggle their ears
## synchronously.
func advance_animation_randomly() -> void:
	advance(min(randf(), randf()))


func _refresh_creature_visuals_path() -> void:
	if not (is_inside_tree() and not creature_visuals_path.is_empty()):
		return
	
	var idle_timer: IdleTimer
	
	if _creature_visuals:
		_creature_visuals.orientation_changed.disconnect(_on_CreatureVisuals_orientation_changed)
		
		idle_timer = _creature_visuals.get_node("Animations/IdleTimer")
		idle_timer.idle_animation_started.disconnect(_on_IdleTimer_idle_animation_started)
		idle_timer.idle_animation_stopped.disconnect(_on_IdleTimer_idle_animation_stopped)
	
	root_node = creature_visuals_path
	_creature_visuals = get_node(creature_visuals_path)
	_creature_visuals.orientation_changed.connect(_on_CreatureVisuals_orientation_changed)
	
	idle_timer = _creature_visuals.get_node("Animations/IdleTimer")
	idle_timer.idle_animation_started.connect(_on_IdleTimer_idle_animation_started)
	idle_timer.idle_animation_stopped.connect(_on_IdleTimer_idle_animation_stopped)


func _on_CreatureVisuals_orientation_changed(_old_orientation: Creatures.Orientation, new_orientation: Creatures.Orientation) -> void:
	if Creatures.oriented_north(new_orientation):
		stop()


func _on_IdleTimer_idle_animation_started(anim_name) -> void:
	if anim_name in get_animation_list():
		play(anim_name)


func _on_IdleTimer_idle_animation_stopped() -> void:
	if current_animation.begins_with("idle"):
		stop()
