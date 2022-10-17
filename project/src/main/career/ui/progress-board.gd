extends CanvasLayer
## A screen which shows the player's progress through career mode.
##
## This includes a chalkboard map showing the player's position, and a clock at the top showing the time.

signal progress_board_shown

signal progress_board_hidden

## Backdrop which darkens parts of the scene behind the progress board.
onready var _backdrop := $Backdrop

## The analog clock and digital text which appear above the progress board.
onready var _clock := $Clock

## A timer which hides the progress board.
onready var _hide_timer := $HideTimer

## Spots and lines drawn to show a trail across the progress board.
onready var _trail := $ChalkboardRegion/Trail

## The title at the top of the progress board.
onready var _title := $ChalkboardRegion/Title

## The player's chalk graphics on the progress board.
onready var _player := $ChalkboardRegion/Player

## Animation player which makes the progress board 'pop in' and 'pop out' animations.
onready var _animation_player := $AnimationPlayer

func _ready() -> void:
	show_progress()


## Shows/animates the progress board based on the current 'CareerData.show_progress' value.
##
## Depending on the value of the CareerData.show_progress value, this method might show the progress board, animate the
## progress board, or not show it at all.
func show_progress() -> void:
	match PlayerData.career.show_progress:
		CareerData.ShowProgress.NONE:
			visible = false
		_:
			visible = true
			_animation_player.play("show")
			refresh()


## Update the progress board's graphics based on the player's career progress.
func refresh() -> void:
	var region := PlayerData.career.current_region()
	_title.set_text(region.name)
	var icon_type := Utils.enum_from_snake_case(ProgressBoardTitle.IconType, region.icon_name, ProgressBoardTitle.NONE)
	_title.set_icon_type(icon_type)
	
	var new_spot_count := region.length
	var new_spots_travelled := PlayerData.career.distance_travelled - region.start
	var new_spots_truncated := false
	
	new_spots_travelled = int(clamp(new_spots_travelled, 0, new_spot_count))
	if region.length == CareerData.MAX_DISTANCE_TRAVELLED:
		new_spot_count = 35
		if new_spots_travelled > 30:
			new_spots_travelled = 30
			new_spots_truncated = true
	
	_trail.spots_truncated = new_spots_truncated
	_trail.spot_count = new_spot_count
	_player.spots_travelled = new_spots_travelled
	
	_clock.set_hours_passed(PlayerData.career.hours_passed)


## Animate the progress board based on how far the player just travelled.
func _animate() -> void:
	_clock.advance()


## When the AnimationPlayer toggles the backdrop visibility, we emit signals so other parts of the UI can refresh.
func _on_Backdrop_visibility_changed() -> void:
	if _backdrop.visible:
		emit_signal("progress_board_shown")
	else:
		emit_signal("progress_board_hidden")


## When the AnimationPlayer's 'show' animation finishes, we schedule the 'hide' animation to play afterward.
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "show":
		_hide_timer.start()


## When the HideTimer times out, we hide the progress board.
func _on_HideTimer_timeout() -> void:
	_animation_player.play("hide")
	PlayerData.career.show_progress = CareerData.ShowProgress.NONE
