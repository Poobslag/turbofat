extends Control
## Shows/hides the money label after a puzzle.

## Duration of the pop-in/pop-out animation
const TWEEN_DURATION := 0.1

## Path to the results hud which shows the total the player earned. The money label responds to this hud.
export (NodePath) var results_hud_path: NodePath

var _money_label_tween: SceneTreeTween

onready var _money_label := $MoneyLabel
onready var _results_hud: ResultsHud = get_node(results_hud_path)

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	
	_results_hud.connect("receipt_shown", self, "_on_ResultsHud_receipt_shown")
	_results_hud.connect("stamped", self, "_on_ResultsHud_stamped")


## Shows the money label, decrementing it so that it does not include money earned for the current level.
##
## The money label is later incremented in response to 'text_shown' signals, so that it increments as customers are
## shown.
func _show_money() -> void:
	_money_label.set_shown_money(PlayerData.money - PuzzleState.level_performance.score)
	_money_label_tween = Utils.recreate_tween(self, _money_label_tween)
	_money_label_tween.tween_property(_money_label, "rect_position:y", 0.0, TWEEN_DURATION)


## Hides the money label.
func _hide_money() -> void:
	_money_label_tween = Utils.recreate_tween(self, _money_label_tween)
	_money_label_tween.tween_property(_money_label, "rect_position:y", -32.0, TWEEN_DURATION)


func _on_PuzzleState_game_prepared() -> void:
	_hide_money()


func _on_ResultsHud_receipt_shown() -> void:
	_show_money()


## Refreshes the money label, incrementing it to include money earned for the current level.
func _on_ResultsHud_stamped() -> void:
	_money_label.set_shown_money(PlayerData.money)
