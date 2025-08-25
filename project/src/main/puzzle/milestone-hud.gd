class_name MilestoneHud
extends Control
## Shows the player's level performance as a progress bar.
##
## the progress bar fills up as they approach the next level up milestone. If there are no more speedups, it fills as
## they approach the level's win/finish condition.
##
## A label overlaid on the progress bar shows them how much further they need to progress to reach the level's
## win/finish condition.

## Colors used to render the level number. Easy levels are green, and hard levels are red/purple.
const LEVEL_COLOR_0 := Color("48b968")
const LEVEL_COLOR_1 := Color("78b948")
const LEVEL_COLOR_2 := Color("b9b948")
const LEVEL_COLOR_3 := Color("b95c48")
const LEVEL_COLOR_4 := Color("b94878")
const LEVEL_COLOR_5 := Color("b948b9")

onready var _progress_bar: ProgressBar = $ZHolder/ProgressBar
onready var _desc: Label = $Desc
onready var _value: FontFitLabel = $ZHolder/Value
onready var _progress_bar_particles: Control = $ZHolder/ProgressBarParticles

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	PuzzleState.connect("speed_index_changed", self, "_on_PuzzleState_speed_index_changed")
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")
	match CurrentLevel.settings.finish_condition.type:
		Milestone.CUSTOMERS:
			_desc.text = tr("Customers")
		Milestone.LINES:
			_desc.text = tr("Lines")
		Milestone.PIECES:
			_desc.text = tr("Pieces")
		Milestone.SCORE:
			_desc.text = tr("Money")
		Milestone.TIME_OVER:
			_desc.text = tr("Time")
	init_milebar()


func _process(_delta: float) -> void:
	update_milebar()


## Updates the milestone progress bar's value and boundaries.
func update_milebar_values() -> void:
	_progress_bar.min_value = MilestoneManager.prev_milestone().value
	var next_milestone := MilestoneManager.next_milestone()
	if next_milestone.value == _progress_bar.min_value:
		# avoid 'cannot get ratio' errors in sandbox mode
		_progress_bar.max_value = _progress_bar.min_value + 1.0
	else:
		_progress_bar.max_value = next_milestone.value
	_progress_bar.value = MilestoneManager.progress_value(next_milestone)


## Updates the milestone progress bar text.
func update_milebar_text() -> void:
	var milestone := CurrentLevel.settings.finish_condition
	var remaining: int = max(0, ceil(milestone.value - MilestoneManager.progress_value(milestone)))
	match milestone.type:
		Milestone.NONE:
			_value.text = "-"
		Milestone.CUSTOMERS, Milestone.LINES, Milestone.PIECES:
			_value.text = StringUtils.comma_sep(remaining)
		Milestone.SCORE:
			_value.text = StringUtils.format_money(remaining)
		Milestone.TIME_OVER:
			_value.text = StringUtils.format_duration(remaining)


## Updates the milestone progress bar color.
##
## Color changes from green to red to purple as difficulty increases.
func update_milebar_color() -> void:
	var level_color: Color
	if PieceSpeeds.current_speed.gravity >= 20 * PieceSpeeds.G and PieceSpeeds.current_speed.lock_delay < 20:
		level_color = LEVEL_COLOR_5
	elif PieceSpeeds.current_speed.gravity >= 20 * PieceSpeeds.G:
		level_color = LEVEL_COLOR_4
	elif PieceSpeeds.current_speed.gravity >= 1 * PieceSpeeds.G:
		level_color = LEVEL_COLOR_3
	elif PieceSpeeds.current_speed.gravity >= 128:
		level_color = LEVEL_COLOR_2
	elif PieceSpeeds.current_speed.gravity >= 32:
		level_color = LEVEL_COLOR_1
	else:
		level_color = LEVEL_COLOR_0
	_progress_bar.get("custom_styles/fg").set_bg_color(Utils.to_transparent(level_color, 0.333))


## Initializes the milestone progress bar's value and boundaries, and locks in the font size.
##
## It would be distracting if the font got bigger as the player progressed, so the font size is only assigned at the
## start of each level when the text should be at its longest value.
func init_milebar() -> void:
	update_milebar()
	_value.pick_largest_font()


## Update the milestone hud's content during a game.
func update_milebar() -> void:
	update_milebar_values()
	update_milebar_text()
	update_milebar_color()


## Update the particle colors to match the progress bar.
##
## All of the Particles2D share the same GradientTexture so we only need to modify one.
func _update_particle_colors() -> void:
	var particles_material: ParticlesMaterial = _progress_bar_particles.get_child(0).process_material
	var progress_bar_color: Color = _progress_bar.get("custom_styles/fg").bg_color
	particles_material.color_ramp.gradient.colors[0] = Utils.to_transparent(progress_bar_color, 1.0)
	particles_material.color_ramp.gradient.colors[1] = Utils.to_transparent(progress_bar_color, 0.0)


func _on_PuzzleState_game_prepared() -> void:
	init_milebar()


## Emits particles when the player levels up.
##
## This provides visual feedback for people playing without sound.
func _on_PuzzleState_speed_index_changed(value: int) -> void:
	if value == 0:
		# initializing the level; don't emit any particles
		return
	
	_update_particle_colors()
	_progress_bar_particles.emit()


func _on_Level_settings_changed() -> void:
	init_milebar()
