extends Node
## Demo which shows off smoke clusters.
##
## Keys:
## 	[space bar]: Emits a smoke cluster.

export (PackedScene) var SmokeClusterScene: PackedScene

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_SPACE:
			var smoke_cluster: SmokeCluster = SmokeClusterScene.instance()
			smoke_cluster.position = Global.window_size * 0.5
			smoke_cluster.velocity = Vector2(rand_range(-100, 100), rand_range(-100, 100))
			add_child(smoke_cluster)
