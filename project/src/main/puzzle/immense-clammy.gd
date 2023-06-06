@tool
extends TileMap

@warning_ignore("unused_private_class_variable")
@export var _add_alternative: bool: set = add_alternative


func add_alternative(value: bool) -> void:
	if not value:
		return
	
	_init_tile(Color(randf(), randf(), randf()))

func _init_tile(color: Color) -> void:
	var original_tile_data: TileData = tile_set.get_source(1).get_tile_data(Vector2i(0, 0), 0)
	
	var alternative_id: int = tile_set.get_source(1).create_alternative_tile(Vector2i(0, 0))
	var alternative_tile_data: TileData = tile_set.get_source(1).get_tile_data(Vector2i(0, 0), alternative_id)
	alternative_tile_data.material = original_tile_data.material
	alternative_tile_data.modulate = color
	alternative_tile_data.texture_origin = original_tile_data.texture_origin		
