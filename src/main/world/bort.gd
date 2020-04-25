extends Customer3D
"""
Script for showing a customer 'Bort' in the 3D overworld.
"""

func _ready() -> void:
	set_meta("chat_id", "bort")
	set_meta("chat_name", "Bort")
	set_meta("accent_def", {"accent_scale":1.3,"accent_swapped":false,"accent_texture":0,"color":"6f83db"})


"""
Bort is light blue with a tentacle mouth.
"""
func get_customer_definition() -> Dictionary:
	return {
		"line_rgb": "6c4331", "body_rgb": "6f83db", "eye_rgb": "374265 eaf2f4", "horn_rgb": "f1e398",
		"ear": "2", "horn": "1", "mouth": "1", "eye": "0"
	}
