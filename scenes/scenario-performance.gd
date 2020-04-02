class_name ScenarioPerformance
"""
Stores statistics for how well the player performed in their current game. This includes how long they survived, how
many lines they cleared, and their score.
"""

# number of seconds until the player won or lost
var seconds := 0.0

# raw number of cleared lines, not including bonus points
var lines := 0

# bonus points awarded for clearing boxes
var box_score := 0

# bonus points awarded for combos
var combo_score := 0

# overall score
var score := 0

# did the player die?
var died := false
