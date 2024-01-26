class_name Credits
## Enums, constants and utilities for the credits.

## Position of the scrolling part of the credits.
##
## TOP: The credits occupy the entire screen vertically. The header is hidden.
## BOTTOM: The credits occupy the bottom part of the screen. The header is visible.
enum CreditsPosition {
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
	CENTER_TOP,
	CENTER_BOTTOM,
}

## The distance a credits line will travel when fading in. If this is a big number, lines will fade in more gradually.
const FADE_RANGE := 10

## Returns 'true' if the specified CreditsPosition is a 'top' position.
##
## Parameters:
## 	'p': Enum from CreditsPosition
static func is_position_top(p: int) -> bool:
	return p in [CreditsPosition.TOP_LEFT, CreditsPosition.CENTER_TOP, CreditsPosition.TOP_RIGHT]


## Returns 'true' if the specified CreditsPosition is a 'left' position.
##
## Parameters:
## 	'p': Enum from CreditsPosition
static func is_position_left(p: int) -> bool:
	return p in [CreditsPosition.TOP_LEFT, CreditsPosition.BOTTOM_LEFT]


## Returns 'true' if the specified CreditsPosition is a 'center' position.
##
## Parameters:
## 	'p': Enum from CreditsPosition
static func is_position_center(p: int) -> bool:
	return p in [CreditsPosition.CENTER_TOP, CreditsPosition.CENTER_BOTTOM]


## Returns 'true' if the specified CreditsPosition is a 'right' position.
##
## Parameters:
## 	'p': Enum from CreditsPosition
static func is_position_right(p: int) -> bool:
	return p in [CreditsPosition.TOP_RIGHT, CreditsPosition.BOTTOM_RIGHT]
