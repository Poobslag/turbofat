class_name RestaurantView
extends Control
"""
Showing the chef character and active customer in a restaurant scene.

As the player drops blocks and scores points, the characters animate and react.
"""

const MOUTH_POSITIONS_BY_ORIENTATION := {
	Creature.SOUTHEAST: Vector2(18, -22),
	Creature.SOUTHWEST: Vector2(-11, -22),
	Creature.NORTHWEST: Vector2(-3, -26),
	Creature.NORTHEAST: Vector2(28, -26),
}

# emitted when the customer changes, either because of a broken combo or because the level restarts
signal customer_changed

# virtual property; value is only exposed through getters/setters
var current_creature_index: int setget set_current_creature_index, get_current_creature_index

# bonus points scored for recent lines; used for determining when the chef should smile
var _recent_bonuses := []

onready var _customer_nametag_panel := $CustomerNametag/Panel
onready var _customer_view_viewport := $CustomerView/Viewport
onready var _customer_view := $CustomerView
onready var _restaurant_nametag_panel := $RestaurantNametag/Panel
onready var _restaurant_viewport_scene := $RestaurantViewport/Scene

func _ready() -> void:
	# Godot doesn't like when ViewportContainers have a different size from their Viewport, so we can't set
	# these values in the editor. Otherwise it keeps changing the values back.
	_customer_view_viewport.size = _customer_view.rect_size * 4
	
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	PuzzleScore.connect("combo_changed", self, "_on_PuzzleScore_combo_changed")
	PuzzleScore.connect("topped_out", self, "_on_PuzzleScore_topped_out")
	PuzzleScore.connect("added_line_score", self, "_on_PuzzleScore_added_line_score")
	
	get_chef().connect("creature_name_changed", self, "_on_Chef_creature_name_changed")
	for customer in get_customers():
		customer.connect("creature_name_changed", self, "_on_Customer_creature_name_changed")
	_refresh_chef_name()
	_refresh_customer_name()


"""
Pans the camera to a new creature. This also changes which creature will be fed.
"""
func set_current_creature_index(new_index: int) -> void:
	_restaurant_viewport_scene.current_creature_index = new_index
	emit_signal("customer_changed")


func get_current_creature_index() -> int:
	return _restaurant_viewport_scene.current_creature_index


func get_customer(creature_index: int = -1) -> Creature:
	return _restaurant_viewport_scene.get_customer(creature_index)


func get_chef() -> Creature:
	return _restaurant_viewport_scene.get_chef()


"""
Returns an array of Creature objects representing customers in the scene.
"""
func get_customers() -> Array:
	return _restaurant_viewport_scene.get_customers()


"""
Returns the position of a customer's mouth within the customer viewport texture.
"""
func get_customer_mouth_position(customer: Creature) -> Vector2:
	var target_pos: Vector2
	# calculate the position within the restaurant scene
	var mouth_position: Vector2 = MOUTH_POSITIONS_BY_ORIENTATION[customer.get_orientation()]
	target_pos = customer.get_node("ChatIconHook").get_global_transform_with_canvas() \
			.xform(mouth_position * customer.creature_visuals.scale.y)
	# calculate the position within the customer viewport
	target_pos = _customer_view_viewport.canvas_transform.xform(target_pos)
	# calculate the position within the customer viewport texture
	target_pos = _customer_view.get_global_transform_with_canvas().xform(target_pos / _customer_view.stretch_shrink)
	return target_pos


"""
Returns the creature index for the specified creature id.

This is useful for determining if a creature is seated at a table, and if so, which table they're seated at. Returns
-1 if the specified creature is not a customer in the restaurant.
"""
func find_creature_index_with_id(creature_id: String) -> int:
	var creature_index := -1
	var customers := get_customers()
	
	for i in range(customers.size()):
		if customers[i].creature_def.creature_id == creature_id:
			creature_index = i
			break
	
	return creature_index


"""
Recolors the creature according to the specified creature definition. This involves updating shaders and sprite
properties.
"""
func summon_creature(creature_index: int = -1) -> void:
	var creature_def := CreatureDef.new()
	if PlayerData.creature_queue.has_primary_creature():
		creature_def = PlayerData.creature_queue.pop_primary_creature()
	else:
		creature_def = CreatureLoader.random_def()
	_restaurant_viewport_scene.summon_creature(creature_def, creature_index)
	if creature_index == -1 or creature_index == current_creature_index:
		emit_signal("customer_changed")


"""
Scroll to a new creature and replace the old creature.
"""
func scroll_to_new_creature(new_creature_index: int = -1) -> void:
	var old_creature_index: int = get_current_creature_index()
	if new_creature_index == -1:
		new_creature_index = next_creature_index()
	set_current_creature_index(new_creature_index)
	_restaurant_viewport_scene.get_customer().restart_idle_timer()
	yield(get_tree().create_timer(0.5), "timeout")
	summon_creature(old_creature_index)


"""
Returns a random creature index different from the current creature index.
"""
func next_creature_index() -> int:
	return (get_current_creature_index() + randi() % 2 + 1) % 3


"""
Temporarily suppresses 'hello' and 'door chime' sounds.
"""
func start_suppress_sfx_timer() -> void:
	for customer in get_customers():
		customer.start_suppress_sfx_timer()
	_restaurant_viewport_scene.start_suppress_sfx_timer()


func _refresh_customer_name() -> void:
	_customer_nametag_panel.refresh_creature(get_customer())


func _refresh_chef_name() -> void:
	_restaurant_nametag_panel.refresh_creature(get_chef())


func _on_Chef_creature_name_changed() -> void:
	_refresh_chef_name()


"""
Cycle out the customer when the combo resets to 0.
"""
func _on_PuzzleScore_combo_changed(value: int) -> void:
	if value > 0:
		# if the combo is not resetting, we ignore the change
		return
	
	if PuzzleScore.no_more_customers:
		pass
	elif PuzzleScore.game_active:
		get_customer().play_goodbye_voice()
		scroll_to_new_creature()
	
	# losing your combo doesn't erase the 'recent bonus' value, but decreases it a lot
	_recent_bonuses = _recent_bonuses.slice(3, _recent_bonuses.size() - 1)
	if PuzzleScore.game_active:
		get_chef().play_mood(ChatEvent.Mood.DEFAULT)


func _on_PuzzleScore_topped_out() -> void:
	get_chef().play_mood(ChatEvent.Mood.CRY0)


"""
When clearing lines, the chef smiles if they're scoring a lot of bonuses.
"""
func _on_PuzzleScore_added_line_score(combo_score: int, box_score: int) -> void:
	_recent_bonuses.append(combo_score + box_score)
	if _recent_bonuses.size() >= 6:
		_recent_bonuses = _recent_bonuses.slice(_recent_bonuses.size() - 6, _recent_bonuses.size() - 1)
	var total_bonus := 0
	for bonus in _recent_bonuses:
		total_bonus += bonus
	
	if total_bonus >= 15 * 6:
		get_chef().play_mood(ChatEvent.Mood.SMILE0)


"""
When the game ends, the chef smiles/cries/rages based on how they did.
"""
func _on_PuzzleScore_game_ended() -> void:
	var mood: int = ChatEvent.Mood.NONE
	match PuzzleScore.end_result():
		PuzzleScore.Result.NONE:
			pass
		PuzzleScore.Result.LOST:
			mood = Utils.rand_value([ChatEvent.Mood.RAGE1, ChatEvent.Mood.RAGE2,
					ChatEvent.Mood.CRY1, ChatEvent.Mood.THINK1])
		PuzzleScore.Result.FINISHED:
			mood = ChatEvent.Mood.SMILE0
		PuzzleScore.Result.WON:
			mood = ChatEvent.Mood.LAUGH1
	if mood != ChatEvent.Mood.NONE:
		get_chef().play_mood(mood)
		_recent_bonuses = []


func _on_Customer_creature_name_changed() -> void:
	_refresh_customer_name()


func _on_RestaurantScene_current_creature_index_changed(_value: int) -> void:
	_refresh_customer_name()
