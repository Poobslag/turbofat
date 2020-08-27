extends Timer
"""
Launches idle animations periodically.

Idle animations are launched if the creature remains in the 'ambient' state for awhile.

This class does not play any animations itself. It sends signals to tell AnimationPlayers when they should start and
stop playing idle animations.
"""

# notifies AnimationPlayers that an idle animation should play.
signal idle_animation_started(anim_name)

# notifies AnimationPlayers that any current idle animation should be interrupted. this class has no concept of how
# long each animation takes or whether they're still playing, so it's possible this signal will be emitted when no
# idle animation is active.
signal idle_animation_stopped()

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
	"idle-ear-wiggle0",
	"idle-ear-wiggle1",
]

# animationplayer which is monitored to see if the creature is in the 'ambient' state
export (NodePath) var emote_player_path: NodePath

onready var _emote_player: AnimationPlayer = get_node(emote_player_path)

func _ready() -> void:
	_emote_player.connect("animation_started", self, "_on_EmotePlayer_animation_started")
	_emote_player.connect("animation_stopped", self, "_on_EmotePlayer_animation_stopped")
	_emote_player.connect("animation_changed", self, "_on_EmotePlayer_animation_changed")
	_emote_player.connect("animation_finished", self, "_on_EmotePlayer_animation_finished")
	connect("timeout", self, "_on_timeout")
	
	_update_state(true)


func play_idle_animation(idle_anim: String) -> void:
	emit_signal("idle_animation_started", idle_anim)
	_update_state(true)


func restart() -> void:
	_update_state(true)


"""
Stops the currently playing idle animation.

This class has no concept of how long an animation is or whether it's still playing, but it emits a signal which
animation players can listen for.
"""
func stop_idle_animation() -> void:
	emit_signal("idle_animation_stopped")


"""
Updates our state based on the current animation.

If the current animation is 'ambient', the timer counts down to launch idle animations.

If the current animation is not 'ambient' state, the timer pauses and does not launch idle animations.
"""
func _update_state(start: bool = false) -> void:
	if start:
		start(rand_range(IDLE_FREQUENCY * 0.5, IDLE_FREQUENCY * 1.5))
	paused = _emote_player.current_animation != "ambient"


func _on_EmotePlayer_animation_started(_anim_name: String) -> void:
	_update_state()


func _on_EmotePlayer_animation_stopped(_anim_name: String) -> void:
	_update_state()


func _on_EmotePlayer_animation_changed(_old_name: String, _new_name: String) -> void:
	_update_state()


func _on_EmotePlayer_animation_finished(_anim_name: String) -> void:
	_update_state()


"""
Launches an idle animation and restarts the timer.
"""
func _on_timeout() -> void:
	var idle_anim: String = Utils.rand_value(IDLE_ANIMS)
	if idle_anim:
		emit_signal("idle_animation_started", idle_anim)
	_update_state(true)


"""
Restarts the idle timer when a new creature shows up.
"""
func _on_CreatureVisuals_creature_arrived() -> void:
	_update_state(true)
