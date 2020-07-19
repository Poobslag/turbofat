extends Timer
"""
Launches idle animations periodically.

Idle animations are launched if the creature remains in the 'ambient' state for awhile.
"""

signal start_idle_animation(anim_name)

# the average amount of seconds to wait before launching an idle animation
const IDLE_FREQUENCY := 24.0

# list of idle animation names to launch
const IDLE_ANIMS := [
	"idle-look-over-shoulder0",
	"idle-look-over-shoulder1",
	"idle-yawn0",
	"idle-yawn1",
	"idle-close-eyes0",
	"idle-close-eyes1",
]

# animationplayer which is monitored to see if the creature is in the 'ambient' state
export (NodePath) var emote_anims_path: NodePath

onready var _emote_anims: AnimationPlayer = get_node(emote_anims_path)

func _ready() -> void:
	_emote_anims.connect("animation_started", self, "_on_EmoteAnims_animation_started")
	_emote_anims.connect("animation_changed", self, "_on_EmoteAnims_animation_changed")
	_emote_anims.connect("animation_finished", self, "_on_EmoteAnims_animation_finished")
	connect("timeout", self, "_on_timeout")
	
	_update_state(true)


func restart() -> void:
	_update_state(true)


"""
Updates our state based on the current animation.

If the current animation is 'ambient', the timer counts down to launch idle animations.

If the current animation is not 'ambient' state, the timer pauses and does not launch idle animations.
"""
func _update_state(start: bool = false) -> void:
	if start:
		start(rand_range(IDLE_FREQUENCY * 0.5, IDLE_FREQUENCY * 1.5))
	paused = _emote_anims.current_animation != "ambient"


func _on_EmoteAnims_animation_started(_anim_name: String) -> void:
	_update_state()


func _on_EmoteAnims_animation_changed(_old_name: String, _new_name: String) -> void:
	_update_state()


func _on_EmoteAnims_animation_finished(_anim_name: String) -> void:
	_update_state()


"""
Launches an idle animation and restarts the timer.
"""
func _on_timeout() -> void:
	var idle_anim: String = IDLE_ANIMS[randi() % IDLE_ANIMS.size()]
	if idle_anim:
		emit_signal("start_idle_animation", idle_anim)
	_update_state(true)


"""
Restarts the idle timer when a new creature shows up.
"""
func _on_CreatureVisuals_creature_arrived() -> void:
	_update_state(true)
