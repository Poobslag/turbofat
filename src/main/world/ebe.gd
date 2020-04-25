extends Customer3D
"""
Script for showing a customer 'Ebe' in the 3D overworld.
"""

func _ready() -> void:
	set_meta("chat_id", "ebe")
	set_meta("chat_name", "Ebe")


"""
Ebe is brown with a beak mouth.
"""
func get_customer_definition() -> Dictionary:
	return {
		"line_rgb": "6c4331", "body_rgb": "b47922", "eye_rgb": "7d4c21 e5cd7d", "horn_rgb": "f1e398",
		"ear": "0", "horn": "2", "mouth": "0", "eye": "1"
	}
