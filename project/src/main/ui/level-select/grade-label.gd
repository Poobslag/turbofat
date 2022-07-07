class_name GradeLabel
extends Label
## Shows a grade label for the player's performance on a level, world or region.

## Updates the grade label's color and outline based on its text.
##
## Good grades like 'SSS' and 'M' are given bright colors like white and yellow. Bad grades like 'B+' and 'B-' are
## given deep colors like blue and purple.
func refresh_color_from_text() -> void:
	# assign the font color based on the label's text
	var font_color := Color("4eff49") # green
	var outline_darkness := 0.2
	match text:
		"M":
			font_color.h = 0.1250 # near-white
			font_color.s = 0.0600
			outline_darkness = 0.1
		"SSS":
			font_color.h = 0.1250 # bright yellow
			font_color.s = 0.4444
			outline_darkness = 0.15
		"SS+", "SS": font_color.h = 0.1250 # yellow
		"S+", "S", "S-": font_color.h = 0.2861 # green
		"AA+", "AA": font_color.h = 0.4667 # cyan
		"A+", "A", "A-": font_color.h = 0.5889 # blue
		"B+", "B", "B-": font_color.h = 0.7472 # purple
		"-": font_color.s = 0.0
	set("custom_colors/font_color", font_color)
	
	# assign the font outline color based on the font color and outline_darkness
	var font: DynamicFont = get("custom_fonts/font")
	font.outline_color = font_color
	font.outline_color.s += outline_darkness
	font.outline_color.v -= outline_darkness * 2
	
