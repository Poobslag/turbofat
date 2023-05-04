class_name SharkClouds
extends Node2D
## Generates 'shark clouds', dust clouds which appear over the shark's mouth while they eat.

## Number of animation variants in the sprite sheet. We cycle between random variants.
const CLOUD_VARIANT_COUNT := 3

@export var CloudPartScene: PackedScene

## Tile map for the pieces the shark is eating.
var tile_map: PuzzleTileMap: set = set_tile_map

func set_tile_map(new_tile_map: PuzzleTileMap) -> void:
	tile_map = new_tile_map
	
	refresh()


## Randomizes the cloud's appearance.
##
## Cycles to a randomly selected animation frame and randomly flips it horizontally.
func shuffle() -> void:
	if get_child_count() == 0:
		return
	
	var old_frame: int = get_child(0).frame % CLOUD_VARIANT_COUNT
	var new_frame: int = (old_frame + Utils.randi_range(1, CLOUD_VARIANT_COUNT - 1)) % CLOUD_VARIANT_COUNT
	var new_flip_h: bool = randf() > 0.5
	
	for i in range(get_child_count()):
		var cloud_part := get_child(i)
		cloud_part.flip_h = new_flip_h
		
		var frame_offset := 0
		if i == 0 and i == get_child_count() - 1:
			# cloud part is not connected
			frame_offset = 0
		elif (i == get_child_count() - 1 and not new_flip_h) or (i == 0 and new_flip_h):
			# cloud part is connected on left side
			frame_offset = 3
		elif (i == 0 and not new_flip_h) or (i == get_child_count() - 1 and new_flip_h):
			# cloud part is connected on right side
			frame_offset = 6
		else:
			# cloud part is connected on both sides
			frame_offset = 9
		
		cloud_part.frame = new_frame + frame_offset


## Updates the cloud's shape based on the pieces the shark is eating.
##
## Depending on the shape of the eaten pieces, the dust cloud might be narrow, wide, or lopsided.
func refresh() -> void:
	if not tile_map:
		return
	
	for child in get_children():
		child.queue_free()
		remove_child(child)
	
	var used_rect := tile_map.get_used_rect()
	
	if not used_rect.has_area():
		# have a small cloud, even if nothing is being eaten
		used_rect = Rect2i(0, 0, 1, 1)
	
	var start_cell_x := used_rect.position.x
	var end_cell_x := used_rect.end.x
	
	for cell_x in range(start_cell_x, end_cell_x):
		var new_cloud_part: Sprite2D = CloudPartScene.instantiate()
		new_cloud_part.position.x = tile_map.cell_size.x * cell_x
		add_child(new_cloud_part)
	
	shuffle()
