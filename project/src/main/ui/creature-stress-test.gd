extends Node
"""
Shows the impact of creatures on FPS.

As of February 2021, adding more creatures results in a massive performance performance degradation. This stress test
lets us objectively measure how far performance degrades with each new creature, to quantify bottlenecks and potential
performance improvements.
"""

const INITIAL_CREATURE_COUNT := 5

# We use a predictable set of creature IDs so that unusual creatures will not impact the results
const CREATURE_IDS := [
	"alexander", "beats", "dingold", "goris", "logana", "pipedro",
	"rhinosaur", "snorz", "squawkapus", "stunker", "terpion", "vile",
]

export (PackedScene) var CreatureScene: PackedScene

func _ready() -> void:
	# We use a predictable fatness value so that the player's performance in the game will not impact the results
	PlayerData.creature_library.forced_fatness = 1.0
	
	_add_creatures(INITIAL_CREATURE_COUNT)
	_refresh_creature_count()


"""
Adds creatures to the scene.

The creatures are selected sequentially using a predetermined set of creature IDs.

Parameters:
	'count': The number of creatures to add.
"""
func _add_creatures(count: int) -> void:
	for _i in range(0, count):
		var creature: Creature = CreatureScene.instance()
		
		var creature_index := $Creatures.get_child_count()
		creature.creature_id = CREATURE_IDS[creature_index % CREATURE_IDS.size()]
		creature.orientation = Utils.rand_value([Creatures.SOUTHWEST, Creatures.SOUTHEAST])
		
		var target_rect := Rect2(0, 0, 1024, 768).grow(-100)
		creature.position.x = rand_range(target_rect.position.x, target_rect.end.x)
		creature.position.y = rand_range(target_rect.position.y, target_rect.end.y)
		
		$Creatures.add_child(creature)
		_refresh_creature_count()


"""
Removes creatures from the scene.

The creatures are removed in FILO order.

Parameters:
	'count': The number of creatures to add.
"""
func _remove_creatures(count: int) -> void:
	for _i in range(0, count):
		if $Creatures.get_child_count() == 0:
			break
		
		var creature: Creature = $Creatures.get_children().back()
		creature.queue_free()
		$Creatures.remove_child(creature)
		_refresh_creature_count()


"""
Updates the 'creature count' label.
"""
func _refresh_creature_count() -> void:
	$Ui/Control/CreatureCount.text = str($Creatures.get_child_count())


"""
When the player presses a button, we add or remove creatures from the scene.

Parameters:
	'creature_delta': The number of creatures to add if positive, or to remove if negative.
"""
func _on_CreatureButton_pressed(creature_delta: int) -> void:
	if creature_delta > 0:
		_add_creatures(creature_delta)
	elif creature_delta < 0:
		_remove_creatures(-creature_delta)


func _on_QuitButton_pressed() -> void:
	# Restore 'forced_fatness' to its original value
	PlayerData.creature_library.forced_fatness = 0.0
	SceneTransition.pop_trail()
