extends Label
## Displays the player's score.

@onready var _top_out_particles := $TopOutParticles

func _ready() -> void:
	PuzzleState.connect("score_changed", Callable(self, "_on_PuzzleState_score_changed"))
	PuzzleState.connect("topped_out", Callable(self, "_on_PuzzleState_topped_out"))
	text = StringUtils.format_money(0)
	
	# Workaround for Godot #40357 to force the label to shrink to its minimum size. Otherwise, the ScoreParticles
	# will be positioned incorrectly if the text ever shrinks.
	size = Vector2.ZERO


func _on_resized() -> void:
	if not _top_out_particles:
		return
	
	# Avoid a Stack Overflow where changing our margins triggers another _on_resized() event, see #1810
	disconnect("resized", Callable(self, "_on_resized"))
	offset_left = -size.x
	connect("resized", Callable(self, "_on_resized"))
	
	_top_out_particles.position = size * 0.5


func _on_PuzzleState_score_changed() -> void:
	text = StringUtils.format_money(PuzzleState.get_score())
	
	# Workaround for Godot #40357 to force the label to shrink to its minimum size. Otherwise, the ScoreParticles
	# will be positioned incorrectly if the text ever shrinks.
	size = Vector2.ZERO


func _on_PuzzleState_topped_out() -> void:
	for particles_2d_node in _top_out_particles.get_children():
		var particles_2d: GPUParticles2D = particles_2d_node
		particles_2d.restart()
		particles_2d.emitting = true
