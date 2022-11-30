class_name PuzzlePerformance
## Stores persistent statistics for how the did during a puzzle. This includes how long they survived, how many lines
## they cleared, and their score.

## number of seconds until the player won or lost
var seconds := 0.0

## raw number of cleared lines, not including bonus points
var lines := 0

## number of pieces spawned without topping out
var pieces := 0

## bonus points awarded for clearing boxes
var box_score := 0

## bonus points awarded for combos
var combo_score := 0

## bonus points awarded for pickups
var pickup_score := 0

## points awarded for lines left over at the end
var leftover_score := 0

## overall score
var score := 0

## how many times did the player top out?
var top_out_count := 0

## did the player lose?
var lost := false

## did the player succeed?
var success := false

func topped_out() -> bool:
	return top_out_count > 0
