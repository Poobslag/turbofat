class_name SharkTileMapPool
extends Node
## Object pool for Shark PuzzleTileMaps.
##
## Sharks use PuzzleTileMaps to render the eaten pieces. PuzzleTileMaps take about 40 ms to instance, so we instance
## them in a thread before the puzzle starts.

## Initial number of PuzzleTileMaps stored in the pool.
##
## At most, we need one shark tilemap for every shark that could be eating simultaneously. Five sharks could each be
## eating different parts of a pentomino.
const POOL_SIZE := 5

export (PackedScene) var PuzzleTileMapScene: PackedScene

## Thread which fills the pool
var _load_thread: Thread

## Pooled PuzzleTileMap instances which are available to borrow
var _tilemaps := []

func _ready() -> void:
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")


func _exit_tree() -> void:
	# empty the PuzzleTileMap pool
	for tilemap in _tilemaps:
		tilemap.free()
	
	# invoke 'wait_for_finish()' to avoid a console warning
	if _load_thread:
		_load_thread.wait_to_finish()


## Obtains a PuzzleTileMap from the pool, or instances one if the pool is empty.
func borrow_tilemap() -> PuzzleTileMap:
	var tilemap: PuzzleTileMap
	if _tilemaps:
		tilemap = _tilemaps.pop_front()
	else:
		tilemap = PuzzleTileMapScene.instance()
	tilemap.clear()
	return tilemap


## Returns a PuzzleTileMap to the pool, or frees it if the pool is full.
func return_tilemap(tilemap: PuzzleTileMap) -> void:
	if _tilemaps.size() < POOL_SIZE:
		_tilemaps.append(tilemap)
	else:
		tilemap.queue_free()


## Instances many PuzzleTileMaps until the pool is full.
##
## Instancing objects is expensive, so this should not be called from the main thread, and should not be called during
## gameplay.
func _fill_pool() -> void:
	while _tilemaps.size() < POOL_SIZE:
		var new_tile_map: PuzzleTileMap = PuzzleTileMapScene.instance()
		_tilemaps.append(new_tile_map)


## Fills the pool if the new level includes an 'add sharks' effect.
func _on_Level_settings_changed() -> void:
	if not CurrentLevel.settings.triggers.has_effect(LevelTriggerEffects.AddSharksEffect):
		# there is no 'add sharks' effect, don't fill the pool
		return
	
	if OS.has_feature("web"):
		# Godot issue #12699; threads not supported for HTML5
		_fill_pool()
	else:
		_load_thread = Thread.new()
		_load_thread.start(self, "_fill_pool")
