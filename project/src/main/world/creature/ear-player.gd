#tool #uncomment to view creature in editor
extends AnimationPlayer
## An AnimationPlayer which animates ears.

export (NodePath) var creature_visuals_path: NodePath setget set_creature_visuals_path

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
	if not (is_inside_tree() and creature_visuals_path):
		return
	
	var idle_timer: IdleTimer
	
	if _creature_visuals:
		_creature_visuals.disconnect("orientation_changed", self, "_on_CreatureVisuals_orientation_changed")
		
		idle_timer = _creature_visuals.get_node("Animations/IdleTimer")
		idle_timer.disconnect("idle_animation_started", self, "_on_IdleTimer_idle_animation_started")
		idle_timer.disconnect("idle_animation_stopped", self, "_on_IdleTimer_idle_animation_stopped")
	
	root_node = creature_visuals_path
	_creature_visuals = get_node(creature_visuals_path)
	_creature_visuals.connect("orientation_changed", self, "_on_CreatureVisuals_orientation_changed")
	
	idle_timer = _creature_visuals.get_node("Animations/IdleTimer")
	idle_timer.connect("idle_animation_started", self, "_on_IdleTimer_idle_animation_started")
	idle_timer.connect("idle_animation_stopped", self, "_on_IdleTimer_idle_animation_stopped")


func _on_CreatureVisuals_orientation_changed(_old_orientation: int, new_orientation: int) -> void:
	if Creatures.oriented_north(new_orientation):
		stop()


func _on_IdleTimer_idle_animation_started(anim_name) -> void:
	if anim_name in get_animation_list():
		play(anim_name)


func _on_IdleTimer_idle_animation_stopped() -> void:
	if current_animation.begins_with("idle"):
		stop()
