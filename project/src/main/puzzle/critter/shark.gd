class_name Shark
extends Node2D
## A shark, a puzzle critter which eats pieces.
##
## Sharks wait on the playfield until bumped by a piece. Depending on the size of the shark, they may take a small bite
## from the piece, a big bite from the piece, or eat the entire piece.

## States the shark goes through when eating a piece.
enum States {
	NONE,
	WAITING,
	DANCING,
	DANCING_END,
	EATING,
	FED,
	SQUISHED,
}

## Default duration in seconds the shark takes to eat.
const DEFAULT_EAT_DURATION := 0.8

## The shark has not appeared yet, or has disappeared.
const NONE := States.NONE

## The shark will appear soon.
const WAITING := States.WAITING

## The shark is dancing, waiting to be fed.
const DANCING := States.DANCING

## The shark is dancing, but will stop dancing very soon.
const DANCING_END := States.DANCING_END

## The shark is eating a piece.
const EATING := States.EATING

## The shark has been fed, and looks happy.
const FED := States.FED

## The shark has been squished by a piece.
const SQUISHED := States.SQUISHED

## Shorter sharks need the tooth cloud moved lower so it will line up with their mouth. This constant stores the tooth
## cloud height for different shark types.
##
## key: (int) an enum from SharkConfig.SharkSize
## value: (float) the y coordinate for the tooth cloud for the specified shark size.
const TOOTH_CLOUD_Y_BY_SHARK_SIZE := {
	SharkConfig.SharkSize.SMALL: -12.0,
	SharkConfig.SharkSize.MEDIUM: -30.0,
	SharkConfig.SharkSize.LARGE: -36.0,
}

## key: (int) an enum from SharkConfig.SharkSize
## value: (float) the pitch scale for the specified shark size
const PITCH_SCALE_BY_SHARK_SIZE := {
	SharkConfig.SharkSize.SMALL: 1.55,
	SharkConfig.SharkSize.MEDIUM: 1.15,
	SharkConfig.SharkSize.LARGE: 0.95,
}

## An enum from SharkConfig.SharkSize for the size of the shark sprite.
var shark_size: int = SharkConfig.SharkSize.MEDIUM setget set_shark_size

## Duration in seconds the shark takes to eat.
var eat_duration: float = DEFAULT_EAT_DURATION setget set_eat_duration

## An enum from States for the shark's current animation state.
var state: int = NONE setget set_state

## 'true' if the shark will be queued for deletion after the 'poof' animation completes.
var _free_after_poof := false

## Queue of enums from States for the shark's upcoming animation states.
var _next_states := []

## 'true' if a state has already been popped from the _next_states queue this frame. We track this to avoid
## accidentally popping two states from the queue when the shark first spawns.
var _already_popped_state := false

onready var animation_player: AnimationPlayer = $AnimationPlayer

## The shark sprite
onready var shark := $Shark

## Eating effects including the cyclone of teeth and dust cloud which appear while a shark is eating.
onready var tooth_cloud := $ToothCloud

## A 'poof cloud' which covers the shark when they appear or disappear
onready var poof: CritterPoof = $Poof

## A speech bubble which appears in the shark's place when the shark is waiting to appear
onready var wait_low := $WaitLow

## A speech bubble which appears over the shark's head when they're about to vanish
onready var wait_high := $WaitHigh

onready var sfx := $SharkSfx

## key: (int) An enum from States
## value: (Node) A State node from the _states StateMachine
onready var _state_nodes_by_enum := {
	NONE: $States/None,
	WAITING: $States/Waiting,
	DANCING: $States/Dancing,
	DANCING_END: $States/DancingEnd,
	EATING: $States/Eating,
	FED: $States/Fed,
	SQUISHED: $States/Squished,
}

onready var _states: StateMachine = $States

func _ready() -> void:
	# The state machine defaults to the 'none' state and not the 'null' state to avoid edge cases
	_states.set_state(_state_nodes_by_enum[NONE])
	
	_refresh_shark_size()
	_refresh_state()


func _enter_tree() -> void:
	_states = $States


func _process(_delta: float) -> void:
	_already_popped_state = false


func set_shark_size(new_shark_size: int) -> void:
	shark_size = new_shark_size
	_refresh_shark_size()


## Enqueues an enums from States to the shark's upcoming animation states.
##
## Parameters:
## 	'next_state': An enum from States
##
## 	'count': (Optional) The number of instances of the state to enqueue.
func append_next_state(next_state: int, count: int = 1) -> void:
	for _i in range(count):
		_next_states.append(next_state)


## Returns 'true' if there are states remaining in the shark's queue of upcoming animation states.
func has_next_state() -> bool:
	return not _next_states.empty()


## Dequeues the next state from the shark's queue of upcoming animation states.
##
## If the shark is currently visible, this updates the shark's animation and returns the dequeued state.
##
## If the shark is currently hidden, they remain invisible. But this still updates their hidden state and returns the
## dequeued state.
##
## Parameters:
## 	'force': If 'true', the shark will be updated again even if it was already updated this frame.
##
## Returns:
## 	An enum from States for the shark's new state.
func pop_next_state(force: bool = false) -> int:
	if not _next_states:
		return NONE
	
	if _already_popped_state and not force:
		pass
	else:
		var next_state: int = _next_states.pop_front()
		set_state(next_state)
		_already_popped_state = true
	
	return state


## Assigns all eaten tiles to a new color.
##
## Parameters:
## 	'tile': tile index in the PuzzleTileMap's tileset which is currently being eaten (piece, box, vegetable...)
##
## 	'autotile_y': autotile_y for the flavor of pieces being eaten (chocolate, fruit, bread...)
func set_eaten_color(tile: int, autotile_y: int) -> void:
	tooth_cloud.set_eaten_color(tile, autotile_y)


## Adds a cell to the eaten piece tilemap.
func set_eaten_cell(position: Vector2) -> void:
	tooth_cloud.set_eaten_cell(position)


## Clears the eaten piece tilemap.
func clear_eaten_cells() -> void:
	tooth_cloud.clear_eaten_cells()


func set_eat_duration(new_eat_duration: float) -> void:
	eat_duration = new_eat_duration
	tooth_cloud.eat_duration = new_eat_duration
	sfx.eat_duration = new_eat_duration


## Updates the tileset for the eaten piece tilemap.
##
## Parameters:
## 	'new_puzzle_tile_set_type': an enum from TileSetType referencing the tileset used to render blocks
func set_puzzle_tile_set_type(new_puzzle_tile_set_type: int) -> void:
	tooth_cloud.set_puzzle_tile_set_type(new_puzzle_tile_set_type)


## Parameters:
## 	'new_state': an enum from States for the shark's new animation state.
func set_state(new_state: int) -> void:
	if state == new_state:
		return
	
	state = new_state
	_refresh_state()


## Plays a 'poof' animation and queues the shark for deletion.
func poof_and_free() -> void:
	set_state(NONE)
	
	if poof.is_poof_animation_playing():
		_free_after_poof = true
	else:
		queue_free()


## Synchronizes this shark's dancing with another onscreen shark. All sharks dance in unison.
func sync_dance() -> void:
	var dancing_shark: Shark
	for next_shark in get_tree().get_nodes_in_group("sharks"):
		if next_shark != self and next_shark.state in [DANCING, DANCING_END]:
			dancing_shark = next_shark
			break
	
	if dancing_shark:
		animation_player.seek(dancing_shark.animation_player.current_animation_position, true)


## Squishes the shark.
##
## They stay squished for two cycles and then poof away.
func squish() -> void:
	_next_states = [SQUISHED, SQUISHED, NONE]
	pop_next_state(true)


## Makes the shark eat.
##
## Details about the piece being eaten should be assigned with set_puzzle_tile_set_type(), set_eaten_cell(),
## set_eaten_color() and set_duration().
func eat() -> void:
	_next_states = [EATING]
	pop_next_state(true)


## Plays the specified 'shark animation', such as 'dance' which corresponds to a longer animation name like
## 'dance-small'.
##
## Our AnimationPlayer contains different animations for different sharks. This method correlates a short animation
## name like 'dance' to a longer animation name like 'dance-small' based on the shark's current size.
##
## Parameters:
## 	'anim_prefix': A short animation name such as 'dance' which corresponds to a longer animation name in the animation
## 		player.
func play_shark_anim(anim_prefix: String) -> void:
	var old_animation := animation_player.current_animation
	var old_animation_position := 0.0
	if old_animation:
		old_animation_position = animation_player.current_animation_position
	
	animation_player.play(_shark_anim_name(anim_prefix, shark_size))
	
	# preserve old animation position when transitioning from 'dance' to 'dance-end' or vice-versa
	if old_animation.begins_with("dance-") and animation_player.current_animation.begins_with("dance-"):
		animation_player.seek(old_animation_position, true)


## Refreshes our appearance and behavior based on our current shark size.
##
## Also updates any playing animations to use our new animation frames.
func _refresh_shark_size() -> void:
	if not is_inside_tree():
		return
	
	tooth_cloud.position.y = TOOTH_CLOUD_Y_BY_SHARK_SIZE[shark_size]
	sfx.pitch_scale = PITCH_SCALE_BY_SHARK_SIZE[shark_size]
	
	# detect if a 'shark animation' is playing, and obtain its suffix
	var old_anim_suffix: String
	for next_shark_size in SharkConfig.SharkSize.values():
		var next_anim_suffix := _shark_anim_name("", next_shark_size)
		if animation_player.current_animation.ends_with(next_anim_suffix):
			old_anim_suffix = next_anim_suffix
			break
	
	# update the 'shark animation' to the new suffix
	if old_anim_suffix:
		var anim_prefix := StringUtils.substring_before_last(animation_player.current_animation, old_anim_suffix)
		var anim_name := _shark_anim_name(anim_prefix, shark_size)
		var old_animation_position := animation_player.current_animation_position
		animation_player.play(anim_name)
		animation_player.seek(old_animation_position, true)


## Updates the state machine's state to match the value of the 'state' enum.
func _refresh_state() -> void:
	if not is_inside_tree():
		return
	
	_states.set_state(_state_nodes_by_enum[state])


## When the 'poof' animation finishes, if poof_and_free() was called then we queue the shark for deletion.
func _on_Poof_animation_finished() -> void:
	if _free_after_poof:
		queue_free()


## When the 'eating' animation finishes, the shark advances to the 'fed' state and disappears.
func _on_ToothCloud_finished_eating() -> void:
	_next_states = [FED, FED, NONE]
	pop_next_state()


## Returns the specified 'shark animation name', such as 'dance-small'.
##
## Parameters:
## 	'anim_prefix': A short animation name such as 'dance' which corresponds to a longer animation name in the animation
## 		player.
##
## 	'in_shark_size': An enum from SharkConfig.SharkSize for the animation to return.
static func _shark_anim_name(anim_prefix: String, in_shark_size: int) -> String:
	return "%s-%s" % [anim_prefix, Utils.enum_to_snake_case(SharkConfig.SharkSize, in_shark_size)]
