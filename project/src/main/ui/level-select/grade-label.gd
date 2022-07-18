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
			font_color = Color("fffbf0") # near-white
			outline_darkness = 0.1
		"SSS":
			font_color = Color("ffe38e") # bright yellow
			outline_darkness = 0.15
		"SS+", "SS": font_color = Color("ffd249") # yellow
		"S+", "S", "S-": font_color = Color("7dff49") # green
		"AA+", "AA": font_color = Color("4affdb") # cyan
		"A+", "A", "A-": font_color = Color("4a9fff") # blue
		"B+", "B", "B-": font_color = Color("a24aff") # purple
		"-": font_color = Color("999999") # grey
	set("custom_colors/font_color", font_color)
	
	# assign the font outline color based on the font color and outline_darkness
	var font: DynamicFont = get("custom_fonts/font")
	font.outline_color = font_color
	font.outline_color.s += outline_darkness
	font.outline_color.v -= outline_darkness * 2
	
