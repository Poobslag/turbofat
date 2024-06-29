class_name Operation
## Stores information about a unique function in the creature editor, such as saving.

enum GridAnchor {
	LEFT,
	RIGHT,
}

var id: String

## Enum from GridAnchor for the side of the Creature Editor where the operation button appears
var grid_anchor: int

## Cell position for the operation button, such as (1, 2)
var grid_position: Vector2

func from_json_dict(json: Dictionary) -> void:
	id = json.get("id", "")
	
	var grid: Array = json.get("grid", "").split(" ")
	if grid.size() >= 1:
		grid_anchor = Utils.enum_from_snake_case(GridAnchor, grid[0])
	if grid.size() >= 3:
		grid_position = Vector2(float(grid[1]), float(grid[2]))
