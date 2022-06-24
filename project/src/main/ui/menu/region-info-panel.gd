extends Panel
## A panel on the region select screen which summarizes region details.
##
## This includes details about the player's progress and how they can progress further.

onready var _label := $MarginContainer/Label

var text: String setget set_text

func _ready() -> void:
	_refresh_text()


func set_text(new_text: String) -> void:
	text = new_text
	_refresh_text()


func _refresh_text() -> void:
	if _label:
		_label.text = text


## Updates the text box to show the region's information.
func _update_region_text(region: CareerRegion) -> void:
	if PlayerData.career.is_region_locked(region):
		set_text("")
		return
	
	var new_text := ""
	var region_completion := PlayerData.career.region_completion(region)
	if region_completion.completion_percent() == 1.0:
		# include grade details -- how the player can get a better grade
		var ranks := []
		for level_obj in region.levels:
			var level: CareerLevel = level_obj
			var best_result := PlayerData.level_history.best_result(level.level_id)
			var rank := best_result.overall_rank() if best_result else RankResult.WORST_RANK
			ranks.append(rank)
		
		# calculate the worst rank
		var worst_rank := 0.0
		for rank in ranks:
			worst_rank = max(worst_rank, rank)
		
		# count the total number of 'stars' for all of the levels
		var star_count := 0
		for rank in ranks:
			match RankCalculator.grade(rank):
				"S-": star_count += 1
				"S": star_count += 2
				"S+": star_count += 3
				"SS": star_count += 4
				"SS+": star_count += 5
				"SSS": star_count += 6
				"M": star_count += 7
		
		# calculate the percent of levels where the player's rank is already high enough to rank up
		var worst_rank_count := 0
		for rank in ranks:
			if RankCalculator.grade(worst_rank) == RankCalculator.grade(rank):
				worst_rank_count += 1
		var next_rank_pct := float(ranks.size() - worst_rank_count) / ranks.size()
		
		new_text += tr("Overall grade: %s") % [RankCalculator.grade(worst_rank)]
		if RankCalculator.grade(worst_rank) != RankCalculator.HIGHEST_GRADE:
			new_text += "\n" + tr("Promotion to %s: %.1f%%") % [
					RankCalculator.next_grade(RankCalculator.grade(worst_rank)), 100 * next_rank_pct]
		if star_count > 0:
			new_text += "\n" + tr("Total stars: %s") % [star_count]
	else:
		# include completion details -- how the player can get 100%
		new_text += tr("Completion: %.1f%%") % [100.0 * region_completion.completion_percent()]
		if region_completion.cutscene_completion_percent() < 1.0:
			new_text += "\n\n" + tr("Replay this chapter to continue your adventure!")
		else:
			new_text += "\n\n" + tr("Clear every level to get to 100%!")
	
	set_text(new_text)


func _on_RegionButtons_region_selected(region: CareerRegion) -> void:
	_update_region_text(region)
