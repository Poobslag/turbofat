extends Node
## Shows the impact of creatures on FPS.
##
## As of February 2021, adding more creatures results in a massive performance performance degradation. This stress
## test lets us objectively measure how far performance degrades with each new creature, to quantify bottlenecks and
## potential performance improvements.

## We use a predictable set of creature IDs so that unusual creatures will not impact the results
const CREATURE_IDS := [
	"alexander", "beats", "dingold", "goris", "logana", "pipedro",
	"rhinosaur", "snorz", "squawkapus", "stunker", "terpion", "vile",
]

## how long we're willing to block a thread to add more sprites
const CHUNK_SECONDS := 0.01

export (PackedScene) var CreatureScene: PackedScene

## the desired number of creatures to show
var _target_creature_count := 5

## the desired fat to override each creature to (applied upon _target_fat_set being false)
var _target_fat_amount: float = 1

## Set to true for _target_fat_amount to apply to all creatures; will be set to false upon application
var _target_fat_set := true

onready var _creature_container := $CreatureContainer
onready var _creature_count := $Ui/Control/CreatureCount

func _ready() -> void:
	# We use a predictable fatness value so that the player's performance in the game will not impact the results
	PlayerData.creature_library.forced_fatness = 1.0


func _physics_process(_delta: float) -> void:
	var start_msec := Time.get_ticks_msec()
	while _creature_container.get_child_count() != _target_creature_count \
			and Time.get_ticks_msec() < start_msec + 1000 * CHUNK_SECONDS:
		if _creature_container.get_child_count() < _target_creature_count:
			_add_creature()
		elif _creature_container.get_child_count() > _target_creature_count:
			_remove_creature()
	_creature_count.text = StringUtils.comma_sep(_creature_container.get_child_count())

	if not _target_fat_set:
		for i in _creature_container.get_children():
			i.set_fatness(_target_fat_amount)
		_target_fat_set = true


## Adds a creature to the scene.
##
## The creatures are selected sequentially using a predetermined set of creature IDs.
func _add_creature() -> void:
	var creature: Creature = CreatureScene.instance()
	
	var creature_index := _creature_container.get_child_count()
	creature.creature_id = CREATURE_IDS[creature_index % CREATURE_IDS.size()]
	creature.orientation = Utils.rand_value([Creatures.SOUTHWEST, Creatures.SOUTHEAST])
	
	var target_rect := Rect2(0, 0, 1024, 768).grow(-100)
	creature.position.x = rand_range(target_rect.position.x, target_rect.end.x)
	creature.position.y = rand_range(target_rect.position.y, target_rect.end.y)
	
	_creature_container.add_child(creature)


## Removes a creature from the scene.
##
## The creatures are removed in FILO order.
func _remove_creature() -> void:
	if _creature_container.get_child_count() == 0:
		return
	
	var creature: Creature = _creature_container.get_children().back()
	creature.queue_free()
	_creature_container.remove_child(creature)


## When the player presses a button, we add or remove creatures from the scene.
##
## Parameters:
## 	'creature_delta': The number of creatures to add if positive, or to remove if negative.
func _on_CreatureButton_pressed(creature_delta: int) -> void:
	_target_creature_count += creature_delta


func _on_FattenButton_pressed(fat_delta : float) -> void:
	_target_fat_amount += fat_delta
	_target_fat_set = false


func _on_QuitButton_pressed() -> void:
	# Restore 'forced_fatness' to its original value
	PlayerData.creature_library.forced_fatness = 0.0
	SceneTransition.pop_trail()
