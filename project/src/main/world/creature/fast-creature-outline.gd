@tool
extends CreatureOutline
## Implementation of CreatureOutline which is optimized for performance, specifically on web and mobile targets.
##
## This implementation avoids using any ViewportTextures. The ViewportTexture utilized by ViewportCreatureOutline
## offers poor performance on mobile and web targets.

func _ready() -> void:
	creature_visuals = $Holder/Visuals
	$Holder.scale = Vector2(Global.CREATURE_SCALE, Global.CREATURE_SCALE)
	connect("elevation_changed", Callable(self, "_on_elevation_changed"))


func _on_elevation_changed(_new_elevation: float) -> void:
	$Holder.position.y = -elevation * Global.CREATURE_SCALE
