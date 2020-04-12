extends AnimationPlayer
"""
Script for AnimationPlayers which animate eyes.
"""

"""
Randomly advances the current animation up to 2.0 seconds. Used to ensure all customers don't blink synchronously.
"""
func advance_animation_randomly():
	advance(randf() * 2.0)
