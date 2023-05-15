extends Node2D
## Spawns food crumbs near the customer's mouth when they eat.

export (NodePath) var restaurant_view_path: NodePath

## Cluster of crumbs which appears when the customer eats.
export (PackedScene) var CrumbClusterScene: PackedScene

onready var _restaurant_view: RestaurantView = get_node(restaurant_view_path)

## Crumb clusters are pooled for performance reasons. Spawning the first crumb cluster sometimes causes a performance
## hiccup, and it's better for this to happen on load rather than during gameplay.
var _crumb_cluster_pool := []

func _ready() -> void:
	for customer_obj in _restaurant_view.get_customers():
		var customer: Creature = customer_obj
		customer.connect("food_eaten", self, "_on_Creature_food_eaten", [customer])


func _process(_delta: float) -> void:
	if _crumb_cluster_pool.size() < 10:
		_crumb_cluster_pool.append(CrumbClusterScene.instance())


func _exit_tree() -> void:
	# empty the crumb cluster pool
	for crumb_cluster in _crumb_cluster_pool:
		crumb_cluster.free()


## When the customer eats, we spawn crumbs near their mouth.
func _on_Creature_food_eaten(food_type: int, customer: Creature) -> void:
	var target_pos := _restaurant_view.get_customer_mouth_position(customer)
	# calculate the position within the global viewport
	target_pos = get_global_transform_with_canvas().xform_inv(target_pos)
	
	var crumb_cluster: CrumbCluster
	if _crumb_cluster_pool:
		# obtain a pooled crumb cluster
		crumb_cluster = _crumb_cluster_pool.pop_back()
	else:
		# no more pooled crumb clusters; initialize a new crumb cluster
		crumb_cluster = CrumbClusterScene.instance()
	
	crumb_cluster.food_type = food_type
	crumb_cluster.position = target_pos
	add_child(crumb_cluster)
