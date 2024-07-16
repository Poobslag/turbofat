extends MarginContainer

## Icons shown alongside the 'Served' value. One of these is selected randomly each time.
const CUSTOMER_ICON_RESOURCES := [
	preload("res://assets/main/career/ui/chalkboard-customer-0.png"),
	preload("res://assets/main/career/ui/chalkboard-customer-1.png"),
	preload("res://assets/main/career/ui/chalkboard-customer-2.png"),
	preload("res://assets/main/career/ui/chalkboard-customer-3.png"),
]

onready var _customer_icon := $HBoxContainer/Control/TextureRect
onready var _value_label := $HBoxContainer/Label3

func _ready() -> void:
	# Select a random customer icon to show alongside the 'Served' value
	var customer_icon_resource: Texture = Utils.rand_value(CUSTOMER_ICON_RESOURCES)
	_customer_icon.texture = customer_icon_resource
	
	_value_label.text = StringUtils.comma_sep(min(PlayerData.career.customers, 99999))
