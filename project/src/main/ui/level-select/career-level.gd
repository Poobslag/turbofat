class_name CareerLevel
## Stores career-mode-specific information about a level.

## Unique customer ID assigned to levels with no named chefs or customers.
const ANONYMOUS_CUSTOMER := "#anonymous_customer#"

var level_id: String

## Some levels involve specific customers or a specific chef.
var customer_ids: Array
var chef_id: String

## A boolean condition which enables this level, such as 'chat_finished chat/career/marsh/30_c_end'
var available_if: String

func from_json_dict(json: Dictionary) -> void:
	level_id = json.get("id", "")
	chef_id = json.get("chef_id", "")
	customer_ids = json.get("customer_ids", [])
	available_if = json.get("available_if", "")
