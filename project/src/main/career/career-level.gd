class_name CareerLevel
## Stores career-mode-specific information about a level.

## Unique customer ID assigned to levels with no quirky chefs or customers.
const NONQUIRKY_CUSTOMER := "#nonquirky_customer#"

var level_id: String

## Some levels involve specific chefs, customers or observers.
var chef_id: String
var customer_ids: Array
var observer_id: String

## Boolean condition which enables this level, such as 'chat_finished chat/career/marsh/30_c_end'
var available_if: String

func from_json_dict(json: Dictionary) -> void:
	level_id = json.get("id", "")
	chef_id = StringUtils.hashwrap_constants(json.get("chef_id", ""))
	customer_ids = json.get("customer_ids", [])
	for i in range(customer_ids.size()):
		customer_ids[i] = StringUtils.hashwrap_constants(customer_ids[i])
	observer_id = StringUtils.hashwrap_constants(json.get("observer_id", ""))
	available_if = json.get("available_if", "")
