extends Node
## Lets the player freely run around, talk to creatures and interact with objects.

func _ready() -> void:
	if Engine.editor_hint:
		return
	
	if not Breadcrumb.trail:
		# For developers accessing the FreeRoam scene directly, we initialize a default Breadcrumb trail.
		# For regular players the Breadcrumb trail will already be initialized by the menus.
		Breadcrumb.initialize_trail()
	
	MusicPlayer.play_chill_bgm()
