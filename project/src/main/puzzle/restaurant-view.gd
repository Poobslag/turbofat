class_name RestaurantView
extends Control
## Showing the chef character and active customer in a restaurant scene.
##
## As the player drops blocks and scores points, the characters animate and react.

## emitted when the customer changes, either because of a broken combo or because the level restarts
signal customer_changed

const MOUTH_POSITIONS_BY_ORIENTATION := {
	Creatures.SOUTHEAST: Vector2(18, -22),
	Creatures.SOUTHWEST: Vector2(-11, -22),
	Creatures.NORTHWEST: Vector2(-3, -26),
	Creatures.NORTHEAST: Vector2(28, -26),
}

const SWOOP_DURATION := 0.8

## virtual property; value is only exposed through getters/setters
var current_creature_index: int setget set_current_creature_index, get_current_creature_index

## bonus points scored for recent lines; used for determining when the chef should smile
var _recent_bonuses := []

## offscreen/onscreen positions for the customer and chef bubbles, used when swooping them in at the start of a level
var _customer_onscreen_rect_position: Vector2
var _customer_offscreen_rect_position: Vector2
var _chef_onscreen_rect_position: Vector2
var _chef_offscreen_rect_position: Vector2

onready var _chef := $Chef
onready var _chef_nametag_panel := $Chef/Nametag/Panel

onready var _customer := $Customer
onready var _customer_nametag_panel := $Customer/Nametag/Panel
onready var _customer_view_viewport := $Customer/View/Viewport
onready var _customer_view := $Customer/View

onready var _restaurant_viewport_scene := $RestaurantViewport/Scene
onready var _swoop_tween: Tween = $SwoopTween
onready var _hello_timer := $HelloTimer
onready var _summon_creature_timers := $SummonCreatureTimers

func _ready() -> void:
	# Godot doesn't like when ViewportContainers have a different size from their Viewport, so we can't set
	# these values in the editor. Otherwise it keeps changing the values back.
	_customer_view_viewport.size = _customer_view.rect_size * 4
	
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")
	PuzzleState.connect("combo_changed", self, "_on_PuzzleState_combo_changed")
	PuzzleState.connect("topped_out", self, "_on_PuzzleState_topped_out")
	PuzzleState.connect("added_line_score", self, "_on_PuzzleState_added_line_score")
	PuzzleState.connect("added_pickup_score", self, "_on_PuzzleState_added_pickup_score")
	
	get_chef().connect("creature_name_changed", self, "_on_Chef_creature_name_changed")
	for customer in get_customers():
		customer.connect("creature_name_changed", self, "_on_Customer_creature_name_changed")
		customer.connect("dna_loaded", self, "_on_Customer_dna_loaded", [customer])
	_refresh_chef_name()
	_refresh_customer_name()
	
	_reset_bubbles_offscreen()


## Moves the chef/customer bubbles offscreen, recording their position for later
##
## We record their current position and relocate them offscreen. The bubbles are tweened onscreen later by an
## AnimationPlayer.
func _reset_bubbles_offscreen() -> void:
	_chef_onscreen_rect_position = _chef.rect_position
	_chef_offscreen_rect_position = _chef_onscreen_rect_position + Vector2(2 * _chef.rect_size.x, 0)
	_chef.rect_position = _chef_offscreen_rect_position
	_chef.modulate = Color.transparent
	
	_customer_onscreen_rect_position = _customer.rect_position
	_customer_offscreen_rect_position = _customer_onscreen_rect_position - Vector2(1.5 * _customer.rect_size.x, 0)
	_customer.rect_position = _customer_offscreen_rect_position
	_customer.modulate = Color.transparent


func swoop_chef_bubble_onscreen() -> void:
	_swoop_bubble(_chef, true)


func swoop_customer_bubble_onscreen() -> void:
	_swoop_bubble(_customer, true)


func swoop_chef_bubble_offscreen() -> void:
	_swoop_bubble(_chef, false)


func swoop_customer_bubble_offscreen() -> void:
	_swoop_bubble(_customer, false)


## Pans the camera to a new creature. This also changes which creature will be fed.
func set_current_creature_index(new_index: int) -> void:
	_restaurant_viewport_scene.current_creature_index = new_index
	emit_signal("customer_changed")


func get_current_creature_index() -> int:
	return _restaurant_viewport_scene.current_creature_index


func get_customer(creature_index: int = -1) -> Creature:
	return _restaurant_viewport_scene.get_customer(creature_index)


func get_chef() -> Creature:
	return _restaurant_viewport_scene.get_chef()


## Returns an array of Creature objects representing customers in the scene.
func get_customers() -> Array:
	return _restaurant_viewport_scene.get_customers()


## Returns the position of a customer's mouth within the customer viewport texture.
func get_customer_mouth_position(customer: Creature) -> Vector2:
	var target_pos: Vector2
	# calculate the position within the restaurant scene
	var mouth_position: Vector2 = MOUTH_POSITIONS_BY_ORIENTATION[customer.get_orientation()]
	target_pos = customer.body_pos_from_head_pos(mouth_position)
	# calculate the position within the customer viewport
	target_pos = _customer_view_viewport.canvas_transform.xform(target_pos)
	# calculate the position within the customer viewport texture
	target_pos = _customer_view.get_global_transform_with_canvas().xform(target_pos / _customer_view.stretch_shrink)
	return target_pos


func find_creature_index_with_id(creature_id: String) -> int:
	var creature_index := -1
	var customers := get_customers()
	
	for i in range(customers.size()):
		if customers[i].creature_def.creature_id == creature_id:
			creature_index = i
			break
	
	return creature_index


## Recolors the creature according to the specified creature definition. This involves updating shaders and sprite
## properties.
func summon_customer(creature_index: int = -1) -> void:
	var creature_def := CreatureDef.new()
	if PlayerData.customer_queue.has_priority_customer():
		creature_def = PlayerData.customer_queue.pop_priority_customer()
	else:
		creature_def = PlayerData.random_customer_def(true)
	_restaurant_viewport_scene.summon_customer(creature_def, creature_index)
	if creature_index == -1 or creature_index == get_current_creature_index():
		emit_signal("customer_changed")


## Scroll to a new creature and replace the old creature.
func scroll_to_new_creature(new_creature_index: int = -1) -> void:
	var old_creature_index: int = get_current_creature_index()
	if new_creature_index == -1:
		new_creature_index = next_creature_index()
	set_current_creature_index(new_creature_index)
	_restaurant_viewport_scene.get_customer().restart_idle_timer()
	
	var summon_creature_timer := Timer.new()
	summon_creature_timer.autostart = true
	summon_creature_timer.one_shot = true
	summon_creature_timer.wait_time = 0.5
	summon_creature_timer.connect("timeout", self, "_on_Timer_timeout_summon_customer", [old_creature_index])
	summon_creature_timer.connect("timeout", self, "_on_Timer_timeout_queue_free", [summon_creature_timer])
	_summon_creature_timers.add_child(summon_creature_timer)


## Returns a random creature index different from the current creature index.
func next_creature_index() -> int:
	var customer_count := get_customers().size()
	return (get_current_creature_index() + randi() % (customer_count - 1) + 1) % customer_count


## Temporarily suppresses 'hello' and 'door chime' sounds.
func briefly_suppress_sfx(duration: float = 1.0) -> void:
	for customer in get_customers():
		customer.briefly_suppress_sfx(duration)
	_restaurant_viewport_scene.briefly_suppress_sfx(duration)


func _swoop_bubble(bubble: Control, onscreen: bool) -> void:
	_swoop_tween.remove(bubble, "modulate")
	_swoop_tween.remove(bubble, "rect_position")
	
	var target_pos: Vector2
	if bubble == _chef:
		target_pos = _chef_onscreen_rect_position if onscreen else _chef_offscreen_rect_position
	elif bubble == _customer:
		target_pos = _customer_onscreen_rect_position if onscreen else _customer_offscreen_rect_position
	var target_opacity := Color.white if onscreen else Color.transparent
	
	_swoop_tween.interpolate_property(bubble, "modulate", bubble.modulate, target_opacity,
			SWOOP_DURATION)
	_swoop_tween.interpolate_property(bubble, "rect_position", bubble.rect_position, target_pos,
			SWOOP_DURATION, Tween.TRANS_CIRC, Tween.EASE_OUT)
	_swoop_tween.start()


func _refresh_customer_name() -> void:
	_customer_nametag_panel.refresh_creature(get_customer())


func _refresh_chef_name() -> void:
	_chef_nametag_panel.refresh_creature(get_chef())


## Update the chef's mood based on the current bonus score.
##
## If you get a lot of bonus points, the chef gets happy.
func _react_to_total_bonus() -> void:
	var total_bonus := 0
	for bonus in _recent_bonuses:
		total_bonus += bonus
	
	if total_bonus >= 15 * 6:
		get_chef().play_mood(Creatures.Mood.SMILE0)


func _on_Chef_creature_name_changed() -> void:
	_refresh_chef_name()


## Cycle out the customer when the combo resets to 0.
func _on_PuzzleState_combo_changed(value: int) -> void:
	if value > 0:
		# if the combo is not resetting, we ignore the change
		return
	
	if PuzzleState.no_more_customers:
		pass
	elif PuzzleState.game_active:
		_hello_timer.maybe_play_goodbye_voice(get_customer())
		scroll_to_new_creature()
	
	# losing your combo doesn't erase the 'recent bonus' value, but decreases it a lot
	_recent_bonuses = _recent_bonuses.slice(3, _recent_bonuses.size() - 1)
	if PuzzleState.game_active:
		get_chef().play_mood(Creatures.Mood.DEFAULT)


func _on_PuzzleState_topped_out() -> void:
	if PuzzleState.game_active:
		get_chef().play_mood(Creatures.Mood.CRY0)


## When clearing lines, the chef smiles if they're scoring a lot of bonus points.
func _on_PuzzleState_added_line_score(combo_score: int, box_score: int) -> void:
	_recent_bonuses.append(combo_score + box_score)
	if _recent_bonuses.size() >= 6:
		_recent_bonuses = _recent_bonuses.slice(_recent_bonuses.size() - 6, _recent_bonuses.size() - 1)
	_react_to_total_bonus()


## When collecting pickups, the chef smiles if they're scoring a lot of bonus points.
func _on_PuzzleState_added_pickup_score(pickup_score: int) -> void:
	if not _recent_bonuses:
		_recent_bonuses.append(0)
	_recent_bonuses[_recent_bonuses.size() - 1] += pickup_score
	_react_to_total_bonus()


## When the game ends, the chef smiles/cries/rages based on how they did.
func _on_PuzzleState_game_ended() -> void:
	var mood: int = Creatures.Mood.NONE
	match PuzzleState.end_result():
		Levels.Result.NONE:
			pass
		Levels.Result.LOST:
			mood = Utils.rand_value([Creatures.Mood.RAGE1, Creatures.Mood.RAGE2,
					Creatures.Mood.CRY1, Creatures.Mood.THINK1])
		Levels.Result.FINISHED:
			mood = Creatures.Mood.SMILE0
		Levels.Result.WON:
			mood = Creatures.Mood.LAUGH1
	if mood != Creatures.Mood.NONE:
		get_chef().play_mood(mood)
		_recent_bonuses = []


func _on_Customer_creature_name_changed() -> void:
	_refresh_customer_name()


func _on_RestaurantPuzzleScene_current_creature_index_changed(_value: int) -> void:
	_refresh_customer_name()


func _on_Customer_dna_loaded(customer: Creature) -> void:
	_hello_timer.maybe_play_hello_voice(customer)


func _on_Playfield_all_lines_cleared() -> void:
	if MilestoneManager.is_met(CurrentLevel.settings.finish_condition):
		# avoid conflicting chef moods at the end of a level
		return
	
	if PuzzleState.tutorial_section_finished:
		# avoid reporting 'all clear' at the end of a tutorial section
		return
	
	get_chef().play_mood(Creatures.Mood.LAUGH1)


func _on_Timer_timeout_summon_customer(creature_index: int) -> void:
	summon_customer(creature_index)


func _on_Timer_timeout_queue_free(timer: Timer) -> void:
	timer.queue_free()
