extends KinematicBody
"""
Script which loads a customer 'Bort' into the 3D overworld.
"""

# Bort's appearance: Light blue with tentacle mouth
const BORT_DEFINITION := {
	"line_rgb": "6c4331", "body_rgb": "6f83db", "eye_rgb": "374265 eaf2f4", "horn_rgb": "f1e398",
	"ear": "2", "horn": "1", "mouth": "1", "eye": "0"
	}

# Turbo cannot land on Bort easily, but it is possible
var foothold_radius := 4.0

func _ready():
	$CollisionShape.disabled = true
	$ShadowMesh.visible = false
	$Viewport/Customer.summon(BORT_DEFINITION)


func _on_Customer_customer_arrived():
	$CollisionShape.disabled = false
	$ShadowMesh.visible = true
