extends GoopViewports
## Draws goop smears when globs collide with the four outer walls.

func _on_GoopGlobs_hit_wall(glob: GoopGlob) -> void:
	add_smear(glob)
