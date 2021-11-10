extends Control
## Scene which lets the player launch tutorials.

func _ready() -> void:
	ResourceCache.substitute_singletons()
	MusicPlayer.play_chill_bgm()


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func _on_BackButton_pressed() -> void:
	SceneTransition.pop_trail()
