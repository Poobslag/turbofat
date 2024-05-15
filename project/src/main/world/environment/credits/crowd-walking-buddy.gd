extends WalkingBuddy
## Creature who walks in a straight line alongside another creature, for a unique cutscene where the player and Fat
## Sensei walk through a cheering crowd.

## Keep the creatures stationary until the cutscene starts.
func _ready() -> void:
	stop_walking()


## Animates the creature's appearance according to the specified mood: happy, angry, etc...
##
## Parameters:
## 	'mood_name': A snake-case enum from Creatures.Mood such as 'think0'
func play_mood_by_name(mood_name: String) -> void:
	var mood := Utils.enum_from_snake_case(Creatures.Mood, mood_name)
	play_mood(mood)
