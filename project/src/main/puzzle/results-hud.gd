extends Control
"""
Results screen shown after the player finishes a scenario.
"""

# Hints displayed after the player finishes
const HINTS = [
	"Build a snack box by arranging a pentomino and a quadromino into a square!",
	"Build a cake box by arranging 3 pentominos into a rectangle!",
	"Build a cake box by arranging 3 quadrominos into a rectangle!",
	"A snack box scores 5 points per line, a cake box scores 10. Make lots of cakes!",
	"Combos can give you 20 bonus points for completing a line. Make lots of combos!",
	"Build a big combo by making boxes and clearing lines!",
	"Making boxes keeps your combo going. You can keep your combo going forever!",
	"Clear lines to keep your combo going. Combos get you lots of money!",
	"When a piece locks, hold left or right to quickly move the next piece!",
	"When a piece locks, hold a rotate key to quickly rotate the next piece!",
	"When a piece locks, hold both rotate keys to quickly flip the next piece!",
	"When a piece locks, hold up to quickly hard-drop the next piece!",
	"After a hard drop, tap 'down' to delay the piece from locking!",
	"Press 'down' to squish pieces past other pieces!",
]

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("after_game_ended", self, "_on_PuzzleScore_after_game_ended")


func hide_results_message() -> void:
	$ResultsLabel.hide_text()
	$MoneyLabelTween.hide_money()


"""
Prepares a game over message to show to the player.

The message is littered with lull characters, '/', which are hidden from the player but result in a brief pause when
displayed.
"""
func show_results_message(rank_result: RankResult, creature_scores: Array, finish_condition_type: int) -> void:
	# Generate post-game message with stats, grades, and a gameplay hint
	var text := "//////////"
	text = _append_creature_scores(rank_result, creature_scores, finish_condition_type, text)
	text = _append_grade_information(rank_result, creature_scores, finish_condition_type, text)
	text += "//////////\n"
	text += "Hint: %s\n" % HINTS[randi() % HINTS.size()]
	
	$ShowResultsSound.play()
	$ResultsLabel.show_text(text)
	$MoneyLabelTween.show_money()
	$MoneyLabel.set_shown_money(PlayerData.money - rank_result.score)


func _append_creature_scores(rank_result: RankResult, creature_scores: Array, \
		finish_condition_type: int, text: String) -> String:
	# Append creature scores
	for i in range(creature_scores.size()):
		var creature_score: int = creature_scores[i]
		if creature_score == 0:
			# last entry in creature_score is always 0; ignore it
			continue
		var left := "Customer #%s " % StringUtils.comma_sep(i + 1)
		var right := "¥%s/\n" % StringUtils.comma_sep(creature_score)
		var middle := ""
		var period_count := 50 - _period_count(left + right)
		for _p in range(period_count):
			middle += "."
		text += left + middle + right
	text += "Total: ¥%s\n" % StringUtils.comma_sep(rank_result.score)
	return text


func _append_grade_information(rank_result: RankResult, creature_scores: Array, \
		finish_condition_type: int, text: String) -> String:
	# We add a '?' to make the player aware if their rank is adjusted because they topped out or lost.
	var topped_out := ""
	if rank_result.topped_out() and Scenario.settings.rank.top_out_penalty > 0:
		topped_out = "?"
	
	text += "/////\n"
	if finish_condition_type == Milestone.SCORE:
		text += "Speed: %d" % round(rank_result.speed * 200 / 60)
		text += topped_out
		if not Scenario.settings.rank.unranked:
			text += " (%s)" % RankCalculator.grade(rank_result.speed_rank)
		text += "\n"
	else:
		text += "Lines: %d" % rank_result.lines
		text += topped_out
		if not Scenario.settings.rank.unranked:
			text += " (%s)" % RankCalculator.grade(rank_result.lines_rank)
		text += "\n"
		
	text += "/////Boxes: %d" % round(rank_result.box_score_per_line * 10)
	text += topped_out
	if not Scenario.settings.rank.unranked:
		text += " (%s)" % RankCalculator.grade(rank_result.box_score_per_line_rank)
	text += "\n"
	
	text += "/////Combos: %d" % round(rank_result.combo_score_per_line * 10)
	text += topped_out
	if not Scenario.settings.rank.unranked:
		text += " (%s)" % RankCalculator.grade(rank_result.combo_score_per_line_rank)
	text += "\n"
	
	if not Scenario.settings.rank.unranked:
		text += "/////\nOverall: "
		text += "//////////"
		if finish_condition_type == Milestone.SCORE:
			var duration := StringUtils.format_duration(rank_result.seconds)
			text += "%s%s (%s)\n" % [duration, topped_out, RankCalculator.grade(rank_result.seconds_rank)]
		else:
			text += "(%s)\n" % RankCalculator.grade(rank_result.score_rank)
	return text


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


func _on_PuzzleScore_after_game_ended() -> void:
	var rank_result: RankResult = PlayerData.scenario_history.prev_result(Scenario.settings.name)
	if not rank_result or Scenario.settings.rank.skip_results:
		return
	
	var creature_scores: Array = PuzzleScore.creature_scores
	var finish_condition_type := Scenario.settings.finish_condition.type
	
	show_results_message(rank_result, creature_scores, finish_condition_type)


func _on_ResultsLabel_text_shown(new_text: String) -> void:
	if new_text.begins_with("Customer #"):
		var amount := int(StringUtils.substring_after_last(new_text, "¥").replace(",", ""))
		$MoneyLabel.set_shown_money($MoneyLabel.shown_money + amount)
