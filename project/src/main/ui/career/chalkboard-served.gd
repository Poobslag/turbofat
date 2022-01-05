extends MarginContainer

## Icons shown alongside the 'Served' value. One of these is selected randomly each time.
var _customer_icon_resources := [
	preload("res://assets/main/ui/career/chalkboard-customer-0.png"),
	preload("res://assets/main/ui/career/chalkboard-customer-1.png"),
	preload("res://assets/main/ui/career/chalkboard-customer-2.png"),
	preload("res://assets/main/ui/career/chalkboard-customer-3.png"),
]

onready var _customer_icon := $HBoxContainer/Control/TextureRect
onready var _value_label := $HBoxContainer/Label3

func _ready() -> void:
	# Select a random customer icon to show alongside the 'Served' value
	var customer_icon_resource: Texture = Utils.rand_value(_customer_icon_resources)
	_customer_icon.texture = customer_icon_resource
	
	_value_label.text = StringUtils.comma_sep(min(PlayerData.career.daily_customers, 99999))
