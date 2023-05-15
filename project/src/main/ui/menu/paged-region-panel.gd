extends Panel
## Region select panel which shows buttons and region info. Used in the practice menu.

## Emitted when the player finishes choosing a region to play.
signal region_chosen(region)

func _on_RegionButtons_region_chosen(region: Object) -> void:
	emit_signal("region_chosen", region)
