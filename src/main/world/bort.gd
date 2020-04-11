extends Customer3D
"""
Script for showing a customer 'Bort' in the 3D overworld.
"""

"""
Bort is light blue with a tentacle mouth.
"""
func get_customer_definition() -> Dictionary:
	return {
		"line_rgb": "6c4331", "body_rgb": "6f83db", "eye_rgb": "374265 eaf2f4", "horn_rgb": "f1e398",
		"ear": "2", "horn": "1", "mouth": "1", "eye": "0"
	}
