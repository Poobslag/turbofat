extends HBoxContainer
## Chalkboard title shown when the player finishes career mode.

## Affirming titles shown when the player does well, travelling many steps during a career session.
##
## These messages are shown very frequently, so they should have a sense of understatement to them.
var _great_titles := [
	tr("CONGRATULATIONS"),
	tr("WE DID IT"),
	tr("HOORAY"),
	tr("FANTASTIC"),
	tr("YAHOO FOR US"),
	tr("LOOK WHAT WE DID"),
	tr("GOSH! WE'RE SO COOL"),
	tr("WELL HOORAY"),
	tr("AMAZING"),
]

## Neutral titles shown when the player does poorly, travelling only a few steps during a career session.
var _good_titles := [
	tr("OH! WHAT A DAY"),
	tr("THAT'S FINE"),
	tr("LET'S GO HOME"),
]

## Negative titles shown when the player fails, travelling zero steps during a career session.
var _bad_titles := [
	tr("OH DEAR WHAT HAPPENED"),
	tr("OH! NO! GO ON TRYING"),
	tr("GOSH THAT'S NOT GOOD"),
]

## Icons shown alongside the title at the top. One of these is selected randomly each time.
##
## Each item in this array is a subarray containing two nested items: a left icon and a right icon.
var _title_icon_resources := [
	[
		preload("res://assets/main/career/ui/chalkboard-title-0a.png"),
		preload("res://assets/main/career/ui/chalkboard-title-0b.png")
	],
	[
		preload("res://assets/main/career/ui/chalkboard-title-1a.png"),
		preload("res://assets/main/career/ui/chalkboard-title-1b.png")
	],
	[
		preload("res://assets/main/career/ui/chalkboard-title-2a.png"),
		preload("res://assets/main/career/ui/chalkboard-title-2b.png")
	],
	[
		preload("res://assets/main/career/ui/chalkboard-title-3a.png"),
		preload("res://assets/main/career/ui/chalkboard-title-3b.png")
	],
]

## Labels which show the current day's information
onready var _title := $Label

## Icons which change randomly each time
onready var _left_title_icon := $Control1/TextureRect
onready var _right_title_icon := $Control2/TextureRect

func _ready() -> void:
	if PlayerData.career.steps >= 25:
		_title.text = Utils.rand_value(_great_titles)
	elif PlayerData.career.steps >= 8:
		_title.text = Utils.rand_value(_good_titles)
	else:
		_title.text = Utils.rand_value(_bad_titles)
	
	# Select a random set of icons to show alongside the title at the top
	var title_icon_resources: Array = Utils.rand_value(_title_icon_resources)
	_left_title_icon.texture = title_icon_resources[0]
	_right_title_icon.texture = title_icon_resources[1]
