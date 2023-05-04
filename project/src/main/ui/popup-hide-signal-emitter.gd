extends Node
## Provides a `Dialog.popup_hide` signal for a popup-like subwindow.
##
## This node can be added as a child of any dialog, and will emit a `popup_hide` signal when the parent dialog is
## hidden.
##
## Workaround for godot-proposals #7084 (https://github.com/godotengine/godot-proposals/issues/7084). The popup_hide
## signal existed in Godot 3 but was removed in Godot 4. Seemingly, the only way to listen for popups being hidden is
## to tediously maintain a reference every dialog which could potentially be hidden, and react to visibility_changed
## signals while checking if the corresponding signal corresponded to a dialog disappearing or not. This script
## encapsulates this horror into a disgusting little package where it can be discarded if/when sanity is restored to
## the Godot dialog API.

## Emitted when the parent popup is hidden.
signal popup_hide

func _ready() -> void:
	get_parent().visibility_changed.connect(_on_Dialog_visibility_changed)


func _on_Dialog_visibility_changed() -> void:
	if not get_parent().visible:
		emit_signal("popup_hide")
