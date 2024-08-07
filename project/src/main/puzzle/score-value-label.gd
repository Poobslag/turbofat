extends Label
## Displays the player's score.

onready var _top_out_particles := $TopOutParticles

func _ready() -> void:
	PuzzleState.connect("score_changed", self, "_on_PuzzleState_score_changed")
	PuzzleState.connect("topped_out", self, "_on_PuzzleState_topped_out")
	text = StringUtils.format_money(0)
	
	# Workaround for Godot #40357 (https://github.com/godotengine/godot/issues/40357) to force the label to shrink to
	# its minimum size. Otherwise, the ScoreParticles will be positioned incorrectly if the text ever shrinks.
	rect_size = Vector2.ZERO


func _on_resized() -> void:
	if not _top_out_particles:
		return
	
	# Avoid a Stack Overflow where changing our margins triggers another _on_resized() event, see #1810
	disconnect("resized", self, "_on_resized")
	margin_left = -rect_size.x
	connect("resized", self, "_on_resized")
	
	_top_out_particles.rect_position = rect_size * 0.5


func _on_PuzzleState_score_changed() -> void:
	text = StringUtils.format_money(PuzzleState.get_score())
	
	# Workaround for Godot #40357 (https://github.com/godotengine/godot/issues/40357) to force the label to shrink to
	# its minimum size. Otherwise, the ScoreParticles will be positioned incorrectly if the text ever shrinks.
	rect_size = Vector2.ZERO


func _on_PuzzleState_topped_out() -> void:
	_top_out_particles.emit()
