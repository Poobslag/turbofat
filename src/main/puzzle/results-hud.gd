extends Control
"""
Results screen shown after the player finishes a scenario.
"""

# Hints displayed after the player finishes
const HINTS = [
	"Make a snack box by arranging a pentomino and a quadromino into a square!",
	"Make a rainbow cake by arranging 3 pentominos into a rectangle!",
	"Make a rainbow cake by arranging 3 quadrominos into a rectangle!",
	"A snack box scores 5 points per line, a rainbow cake scores 10. Make lots of cakes!",
	"Combos can give you 20 bonus points for completing a line. Make lots of combos!",
	"Build a big combo by making boxes and clearing lines!",
	"When a piece locks, hold left or right to quickly move the next piece!",
	"When a piece locks, hold a rotate key to quickly rotate the next piece!",
	"When a piece locks, hold both rotate keys to quickly flip the next piece!",
	"When a piece locks, hold up to quickly hard-drop the next piece!",
	"After a hard drop, tap 'down' to delay the piece from locking!",
	"Sometimes, pressing 'down' can cheat pieces through other pieces!"
]

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")


func hide_results_message() -> void:
	$ResultsLabel.hide_text()
	$MoneyLabelTween.hide_money()


"""
Prepares a game over message to show to the player.

The message is littered with lull characters, '/', which are hidden from the player but result in a brief pause when
displayed.
"""
func show_results_message(rank_result: RankResult, customer_scores: Array, finish_condition_type: int) -> void:
	# Generate post-game message with stats, grades, and a gameplay hint
	var text := "//////////"
	
	# Append customer scores
	for i in range(customer_scores.size()):
		var customer_score: int = customer_scores[i]
		if customer_score == 0:
			# last entry in customer_score is always 0; ignore it
			continue
		var left := "Customer #%s " % StringUtils.comma_sep(i + 1)
		var right := "¥%s/\n" % StringUtils.comma_sep(customer_score)
		var middle := ""
		var period_count := 50 - _period_count(left + right)
		for _p in range(period_count):
			middle += "."
		text += left + middle + right
	text += "Total: ¥%s\n" % StringUtils.comma_sep(rank_result.score)
	
	# Append grade information
	text += "/////\n"
	if finish_condition_type == ScenarioSettings.SCORE:
		text += "Speed: %d (%s)\n" % [round(rank_result.speed * 200 / 60), Global.grade(rank_result.speed_rank)]
	else:
		text += "Lines: %d (%s)\n" % [rank_result.lines, Global.grade(rank_result.lines_rank)]
		
	text += "/////Boxes: %d (%s)\n" % [round(rank_result.box_score_per_line * 10),
			Global.grade(rank_result.box_score_per_line_rank)]
	
	text += "/////Combos: %d (%s)\n" % [round(rank_result.combo_score_per_line * 10),
			Global.grade(rank_result.combo_score_per_line_rank)]
	
	text += "/////\nOverall: "
	text += "//////////"
	if finish_condition_type == ScenarioSettings.SCORE:
		var seconds := ceil(rank_result.seconds)
		text += "%01d:%02d (%s)\n" % [int(seconds) / 60, int(seconds) % 60,
				Global.grade(rank_result.seconds_rank)]
	else:
		text += "(%s)\n" % Global.grade(rank_result.score_rank)
	
	text += "//////////\n"
	text += "Hint: %s\n" % HINTS[randi() % HINTS.size()]
	
	$ShowResultsSound.play()
	$ResultsLabel.show_text(text)
	$MoneyLabelTween.show_money()
	$MoneyLabel.set_shown_money(PlayerData.money - rank_result.score)


"""
Returns the string width as measured by period characters.

We use this when right-justifying the dollar amounts.
"""
func _period_count(s: String) -> int:
	var result := 0
	for c in s:
		if c in [',', '.', ' ']:
			result += 1
		else:
			result += 2
	return result


func _on_PuzzleScore_game_prepared() -> void:
	hide_results_message()


func _on_Puzzle_after_game_ended() -> void:
	var rank_result: RankResult = PlayerData.get_last_scenario_result(Global.scenario_settings.name)
	var customer_scores: Array = PuzzleScore.customer_scores
	var finish_condition_type := Global.scenario_settings.get_winish_condition().type
	
	show_results_message(rank_result, customer_scores, finish_condition_type)


func _on_ResultsLabel_text_shown(new_text: String) -> void:
	if new_text.begins_with("Customer #"):
		var amount := int(StringUtils.substring_after_last(new_text, "¥").replace(",", ""))
		$MoneyLabel.set_shown_money($MoneyLabel.shown_money + amount)
