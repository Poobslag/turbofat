extends LevelSelectButton
## Button on the level select screen which launches a hardcore level.
##
## Hardcore levels are special because the player only gets one life. They're decorated in a scary way.

const BUTTON_COLOR_HARDCORE := Color("280e14")

## Overrides the parent's colors with a special hardcore color scheme.
func refresh_style_color(_color: Color) -> void:
		_button_control.get("custom_styles/normal").bg_color = BUTTON_COLOR_HARDCORE
		_button_control.get("custom_styles/hover").bg_color = BUTTON_COLOR_HARDCORE
