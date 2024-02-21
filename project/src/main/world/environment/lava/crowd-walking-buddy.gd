extends WalkingBuddy
## Creature who walks in a straight line alongside another creature, for a unique cutscene where the player and Fat
## Sensei walk through a cheering crowd.

func play_mood_think0() -> void:
	stop_walking()
	play_mood(Creatures.Mood.THINK0)


func play_mood_smile0() -> void:
	stop_walking()
	play_mood(Creatures.Mood.SMILE0)
