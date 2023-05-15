class_name GradeLabel
extends Label
## Shows a grade label for the player's performance on a level, world or region.

const GRADE_COLOR_NEAR_WHITE := Color("fffbf0")
const GRADE_COLOR_LIGHT_YELLOW := Color("ffe38e")
const GRADE_COLOR_YELLOW := Color("ffd249")
const GRADE_COLOR_GREEN := Color("7dff49")
const GRADE_COLOR_CYAN := Color("4affdb")
const GRADE_COLOR_BLUE := Color("4a9fff")
const GRADE_COLOR_PURPLE := Color("a24aff")
const GRADE_COLOR_GREY := Color("999999")

## Updates the grade label's color and outline based on its text.
##
## Good grades like 'SSS' and 'M' are given bright colors like white and yellow. Bad grades like 'B+' and 'B-' are
## given deep colors like blue and purple.
func refresh_color_from_text() -> void:
	# assign the font color based on the label's text
	var font_color := GRADE_COLOR_GREEN
	var outline_darkness := 0.2
	match text:
		"M":
			font_color = GRADE_COLOR_NEAR_WHITE
			outline_darkness = 0.1
		"SSS":
			font_color = GRADE_COLOR_LIGHT_YELLOW
			outline_darkness = 0.15
		"SS+", "SS": font_color = GRADE_COLOR_YELLOW
		"S+", "S", "S-": font_color = GRADE_COLOR_GREEN
		"AA+", "AA": font_color = GRADE_COLOR_CYAN
		"A+", "A", "A-": font_color = GRADE_COLOR_BLUE
		"B+", "B", "B-": font_color = GRADE_COLOR_PURPLE
		"-": font_color = GRADE_COLOR_GREY
	set("theme_override_colors/font_color", font_color)
	
	# assign the font outline color based on the font color and outline_darkness
	var font: FontFile = get("theme_override_fonts/font")
	font.outline_color = font_color
	font.outline_color.s += outline_darkness
	font.outline_color.v -= outline_darkness * 2
