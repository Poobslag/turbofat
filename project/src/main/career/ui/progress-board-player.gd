extends Control
## Draws the player's chalk graphics on the progress board.
##
## This includes two components: a player graphic and a 'steps remaining' label.

export (NodePath) var trail_path

var spots_travelled: float setget set_spots_travelled

onready var _label := $Label
onready var _player_animation_player := $PlayerSprite/AnimationPlayer
onready var _trail: ProgressBoardTrail = get_node(trail_path)

func _ready() -> void:
	refresh()


## Updates the player's position, sprite sheet frame and 'steps remaining' label.
func refresh() -> void:
	if not is_inside_tree():
		return
	
	rect_position = _trail.get_spot_position(spots_travelled)
	if PlayerData.career.current_region().has_flag(CareerRegion.FLAG_NO_SENSEI):
		_player_animation_player.play("alone")
	else:
		_player_animation_player.play("default")
	
	if PlayerData.career.show_progress == CareerData.ShowProgress.ANIMATED:
		_label.visible = true
	else:
		_label.visible = false


func set_spots_travelled(new_spots_travelled: float) -> void:
	spots_travelled = new_spots_travelled
	refresh()
