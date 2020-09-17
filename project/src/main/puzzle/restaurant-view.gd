extends Control
"""
Showing the player's chef character and active customer in a restaurant scene.

As the player drops blocks and scores points, the characters animate and react.
"""

# virtual property; value is only exposed through getters/setters
var current_creature_index: int setget set_current_creature_index, get_current_creature_index

# bonus points scored for recent lines; used for determining when the chef should smile
var _recent_bonuses := []

func _ready() -> void:
	# Godot doesn't like when ViewportContainers have a different size from their Viewport, so we can't set
	# these values in the editor. Otherwise it keeps changing the values back.
	$CustomerView/Viewport.size = $CustomerView.rect_size * 4
	$ChefView/Viewport.size = $ChefView.rect_size * 4
	
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("combo_ended", self, "_on_PuzzleScore_combo_ended")
	PuzzleScore.connect("topped_out", self, "_on_PuzzleScore_topped_out")
	PuzzleScore.connect("added_line_score", self, "_on_PuzzleScore_added_line_score")


"""
Pans the camera to a new creature. This also changes which creature will be fed.
"""
func set_current_creature_index(new_index: int) -> void:
	$RestaurantViewport/Scene.current_creature_index = new_index


func get_current_creature_index() -> int:
	return $RestaurantViewport/Scene.current_creature_index


func get_customer(creature_index: int = -1) -> Creature:
	return $RestaurantViewport/Scene.get_customer(creature_index)


"""
Recolors the creature according to the specified creature definition. This involves updating shaders and sprite
properties.
"""
func summon_creature(creature_index: int = -1) -> void:
	var dna: Dictionary
	if Global.creature_queue_index < Global.creature_queue.size():
		dna = Global.creature_queue[Global.creature_queue_index]
		Global.creature_queue_index += 1
	else:
		dna = CreatureLoader.random_def()
	$RestaurantViewport/Scene.summon_creature(dna, creature_index)


"""
Scroll to a new creature and replace the old creature.
"""
func scroll_to_new_creature(new_creature_index: int = -1) -> void:
	var old_creature_index: int = get_current_creature_index()
	if new_creature_index == -1:
		new_creature_index = (old_creature_index + randi() % 2 + 1) % 3
	set_current_creature_index(new_creature_index)
	$RestaurantViewport/Scene.get_customer().restart_idle_timer()
	yield(get_tree().create_timer(0.5), "timeout")
	summon_creature(old_creature_index)


"""
Temporarily suppresses 'hello' and 'door chime' sounds.
"""
func start_suppress_sfx_timer() -> void:
	for i in range(3):
		get_customer(i).start_suppress_sfx_timer()
	$RestaurantViewport/Scene.start_suppress_sfx_timer()


"""
If they ended the previous game while serving a creature, we scroll to a new one
"""
func _on_PuzzleScore_game_prepared() -> void:
	if get_customer().feed_count > 0:
		scroll_to_new_creature()


func _on_PuzzleScore_combo_ended() -> void:
	if PuzzleScore.no_more_customers:
		pass
	elif PuzzleScore.game_active:
		get_customer().play_goodbye_voice()
		scroll_to_new_creature()
	
	# losing your combo doesn't erase the 'recent bonus' value, but decreases it a lot
	_recent_bonuses = _recent_bonuses.slice(3, _recent_bonuses.size() - 1)
	if PuzzleScore.game_active:
		$RestaurantViewport/Scene.get_player().play_mood(ChatEvent.Mood.DEFAULT)


func _on_PuzzleScore_topped_out() -> void:
	$RestaurantViewport/Scene.get_player().play_mood(ChatEvent.Mood.CRY0)


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
		$RestaurantViewport/Scene.get_player().play_mood(ChatEvent.Mood.SMILE0)


"""
When the game ends, the chef smiles/cries/rages based on how they did.
"""
func _on_PuzzleScore_game_ended() -> void:
	var mood: int = ChatEvent.Mood.NONE
	match PuzzleScore.end_result():
		PuzzleScore.LOST:
			mood = Utils.rand_value([ChatEvent.Mood.RAGE0, ChatEvent.Mood.RAGE1,
					ChatEvent.Mood.CRY1, ChatEvent.Mood.THINK1])
		PuzzleScore.FINISHED:
			mood = ChatEvent.Mood.SMILE0
		PuzzleScore.WON:
			mood = ChatEvent.Mood.LAUGH1
	if mood != ChatEvent.Mood.NONE:
		$RestaurantViewport/Scene.get_player().play_mood(mood)
		_recent_bonuses = []
