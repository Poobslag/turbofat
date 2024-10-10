class_name ResultsHud
extends Control
## Results screen shown after the player finishes a level.

## Emitted when the 'show_results_message' method is called, and the receipt pops out.
signal receipt_shown

## Emitted when Fat Sensei stamps the player's grade on the receipt.
signal stamped

## Receipt paper position when it is hidden
const POSITION_HIDDEN := Vector2(765, 800)

## Receipt paper position when it is shown
const POSITION_SHOWN := Vector2(765, 4)

onready var _sfx_receipt_show := $Sfx/ReceiptShow
onready var _sfx_receipt_hide := $Sfx/ReceiptHide

onready var _receipt_paper := $ReceiptPaper
onready var _header := $ReceiptPaper/Header
onready var _table := $ReceiptPaper/Table
onready var _bar_graph := $ReceiptPaper/BarGraph
onready var _stamp := $ReceiptPaper/Stamp
onready var _medal := $ReceiptPaper/Medal

## Directs the long animation of showing the receipt, building up a bar graph, and showing the player's grade.
onready var _tween: SceneTreeTween

## Briefly animates the receipt when it is stamped.
onready var _shake_tween: SceneTreeTween

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	PuzzleState.connect("after_game_ended", self, "_on_PuzzleState_after_game_ended")
	_receipt_paper.visible = false


## Animates the receipt when it is stamped, shaking it slightly.
func stamp() -> void:
	_shake_tween = Utils.recreate_tween(self, _shake_tween)
	_shake_tween.tween_property(_receipt_paper, "rect_position:x", POSITION_SHOWN.x + 5, 0.04)
	_shake_tween.tween_property(_receipt_paper, "rect_position:x", POSITION_SHOWN.x - 3, 0.04)
	_shake_tween.tween_property(_receipt_paper, "rect_position:x", POSITION_SHOWN.x + 2, 0.04)
	_shake_tween.tween_property(_receipt_paper, "rect_position:x", POSITION_SHOWN.x - 1, 0.04)
	_shake_tween.tween_property(_receipt_paper, "rect_position:x", POSITION_SHOWN.x, 0.04)
	emit_signal("stamped")


func is_results_message_shown() -> bool:
	return _receipt_paper.visible


## Animates hiding the receipt, swooshing it offscreen.
func hide_results_message() -> void:
	if _receipt_paper.visible == false:
		# already hidden
		return
	
	var blueprint := ResultsHudBlueprint.new()
	
	_tween = Utils.recreate_tween(self, _tween)
	
	_sfx_receipt_hide.play()
	_tween.tween_property(_receipt_paper, "rect_position:y", POSITION_HIDDEN.y, 0.2) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_interval(0.2)
	_tween.tween_callback(_receipt_paper, "set", ["visible", false])
	_tween.tween_callback(_bar_graph, "reset", [blueprint])
	_tween.tween_callback(_header, "reset", [blueprint])
	_tween.tween_callback(_table, "reset", [blueprint])
	_tween.tween_callback(_stamp, "reset", [blueprint])
	_tween.tween_callback(_medal, "reset", [blueprint])


## Animates showing the receipt, building up a bar graph, and showing the player's grade.
func show_results_message() -> void:
	if _receipt_paper.visible == true:
		# already shown
		return
	
	var blueprint := ResultsHudBlueprint.new()
	
	_sfx_receipt_show.play()
	_tween = Utils.recreate_tween(self, _tween)
	
	_receipt_paper.rect_position.y = POSITION_HIDDEN.y
	_tween.tween_property(_receipt_paper, "rect_position:y", POSITION_SHOWN.y, 0.2) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	_receipt_paper.visible = true
	_receipt_paper.modulate = Color.transparent
	_tween.parallel().tween_property(_receipt_paper, "modulate", Color.white, 0.1)
	
	_tween.tween_interval(0.4)
	
	_header.reset(blueprint)
	_tween.tween_callback(_header, "play", [blueprint])
	
	_tween.tween_interval(0.4)
	
	_table.reset(blueprint)
	_tween.tween_callback(_table, "play", [blueprint])
	_bar_graph.reset(blueprint)
	_tween.parallel().tween_callback(_bar_graph, "play", [blueprint])
	
	_tween.tween_interval(blueprint.total_duration())
	
	_stamp.reset(blueprint)
	_tween.tween_callback(_stamp, "play", [blueprint])
	
	_medal.reset(blueprint)
	if blueprint.should_show_medal():
		_tween.tween_interval(0.8)
		_tween.tween_callback(_medal, "play", [blueprint])
	
	emit_signal("receipt_shown")


## Immediately hides the receipt, blinking it offscreen and resetting any animations.
func reset() -> void:
	_tween = Utils.kill_tween(_tween)
	_receipt_paper.visible = false
	_receipt_paper.rect_position = POSITION_HIDDEN


func _on_PuzzleState_game_prepared() -> void:
	hide_results_message()


func _on_PuzzleState_after_game_ended() -> void:
	var rank_result: RankResult = PlayerData.level_history.prev_result(CurrentLevel.settings.id)
	if not rank_result or CurrentLevel.settings.rank.skip_results:
		return
	
	show_results_message()
