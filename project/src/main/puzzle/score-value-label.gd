extends Label
## Displays the player's score.

onready var _top_out_particles := $TopOutParticles

func _ready() -> void:
	PuzzleState.connect("score_changed", self, "_on_PuzzleState_score_changed")
	PuzzleState.connect("topped_out", self, "_on_PuzzleState_topped_out")
	text = StringUtils.format_money(0)
	
	# Workaround for Godot #40357 to force the label to shrink to its minimum size. Otherwise, the ScoreParticles
	# will be positioned incorrectly if the text ever shrinks.
	rect_size = Vector2(0, 0)


func _on_resized() -> void:
	if not _top_out_particles:
		return
	
	margin_left = -rect_size.x
	_top_out_particles.rect_position = rect_size * 0.5


func _on_PuzzleState_score_changed() -> void:
	text = StringUtils.format_money(PuzzleState.get_score())
	
	# Workaround for Godot #40357 to force the label to shrink to its minimum size. Otherwise, the ScoreParticles
	# will be positioned incorrectly if the text ever shrinks.
	rect_size = Vector2(0, 0)


func _on_PuzzleState_topped_out() -> void:
	for particles_2d_node in _top_out_particles.get_children():
		var particles_2d: Particles2D = particles_2d_node
		particles_2d.restart()
		particles_2d.emitting = true
