extends OverworldObstacle
## Turbo Fat restaurant which appears in the overworld.
##
## This script toggles the restaurant's appearance based on the player's story progression.

export (PackedScene) var SmokeClusterScene: PackedScene

## Disable cutscene sound effects. This is useful for environments which have multiple copies of the restaurant
export (bool) var sfx_disabled: bool = false

## A 'closed' sign used at the start of the game and during certain cutscenes.
onready var closed_sign: Sprite = $ClosedSign

## Regular restaurant sprite.
onready var _restaurant := $Restaurant

## Undecorated restaurant sprite, used at the start of the game.
onready var _undecorated_restaurant := $UndecoratedRestaurant

onready var _poof_in_sfx := $PoofInSfx

func _ready() -> void:
	if PlayerData.career.is_restaurant_decorated():
		_restaurant.visible = true
		_undecorated_restaurant.visible = false
		closed_sign.visible = false
	else:
		_restaurant.visible = false
		_undecorated_restaurant.visible = true
		closed_sign.visible = PlayerData.chat_history.is_chat_finished("chat/career/lemon_2/intro_level")

	
	if Global.get_overworld_ui():
		Global.get_overworld_ui().connect("chat_event_meta_played", self, "_on_OverworldUi_chat_event_meta_played")


func hide_closed_sign() -> void:
	_restaurant.visible = false
	_undecorated_restaurant.visible = true
	closed_sign.visible = false


func show_closed_sign() -> void:
	_restaurant.visible = false
	_undecorated_restaurant.visible = true
	closed_sign.visible = true
	
	_emit_smoke()
	_poof_in_sfx.play()


func _emit_smoke() -> void:
	for flip_x in [false, true]:
		for flip_y in [false, true]:
			var smoke_cluster: SmokeCluster = SmokeClusterScene.instance()
			smoke_cluster.scale = closed_sign.scale * 0.6
			smoke_cluster.position = closed_sign.position + Vector2(0, 5)
			smoke_cluster.velocity.x = -40 if flip_x else 40
			smoke_cluster.velocity.y = -20 if flip_y else 20
			smoke_cluster.position.x += -10 if flip_x else 10
			smoke_cluster.position.y += -5 if flip_y else 5
			add_child(smoke_cluster)


## Listen for 'turbofat_closed_sign' events and toggle the sign's visibility.
##
## If the closed sign is being manipulated, we also switch to the undecorated restaurant. This avoids edge cases where
## the sign is placed on the decorated restaurant in an ugly way.
func _on_OverworldUi_chat_event_meta_played(meta_item: String) -> void:
	match meta_item:
		"turbofat_closed_sign disappears":
			hide_closed_sign()
		"turbofat_closed_sign appears":
			show_closed_sign()
