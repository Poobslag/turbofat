extends Spatial
"""
A visual icon which appears next to something the player can interact with.
"""

enum BubbleType {
	SPEECH,
	THOUGHT
}

export (BubbleType) var bubble_type: int

# 'true' if this bubble should appear on the right side, 'false' if it's on the left side
export (bool) var right_side: bool = true

func _ready() -> void:
	if bubble_type == BubbleType.SPEECH:
		$ChatIconMesh.frame = randi() % 3
	elif bubble_type == BubbleType.THOUGHT:
		$ChatIconMesh.frame = randi() % 3 + 3
	
	if not right_side:
		$ChatIconMesh.translation.x *= -1
		$ChatIconMesh.translation.z *= -1
		$ChatIconMesh.flip_h = true
		
	InteractableManager.add_interactable(get_parent())
	InteractableManager.connect("focus_changed", self, "_on_InteractableManager_focus_changed")


func _on_InteractableManager_focus_changed() -> void:
	if not InteractableManager.is_focus_enabled():
		$ChatIconMesh.vanish()
	elif InteractableManager.is_focused(get_parent()):
		$ChatIconMesh.focus()
	else:
		$ChatIconMesh.unfocus()
