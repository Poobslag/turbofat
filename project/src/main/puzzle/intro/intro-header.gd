extends TextureRect
## Shows a header image with a simple level summary like "25-Line Marathon"

const IMAGE_ULTRA := preload("res://assets/main/puzzle/intro/receipt-header-ultra.png")
const IMAGE_SANDBOX := preload("res://assets/main/puzzle/intro/receipt-header-sandbox.png")
const IMAGE_SPRINT := preload("res://assets/main/puzzle/intro/receipt-header-sprint.png")
const IMAGE_MARATHON := preload("res://assets/main/puzzle/intro/receipt-header-marathon.png")
const IMAGE_VIP := preload("res://assets/main/puzzle/intro/receipt-header-vip.png")

## Label containing the title text
onready var _title := $Title

func _ready() -> void:
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")
	
	_refresh()


## Updates the header image and title text
func _refresh() -> void:
	match CurrentLevel.settings.finish_condition.type:
		Milestone.CUSTOMERS:
			_prepare_vip_mode()
		Milestone.LINES, Milestone.PIECES:
			_prepare_marathon_mode()
		Milestone.SCORE:
			_prepare_ultra_mode()
		Milestone.TIME_OVER:
			_prepare_sprint_mode()
		Milestone.NONE:
			_prepare_sandbox_mode()
		_:
			push_warning("Unrecognized finish condition: %s" % \
					[CurrentLevel.settings.finish_condition.type])
			texture = IMAGE_SANDBOX
			_title.text = ""


## Shows a VIP header image and '5-Customer VIP' title text
func _prepare_vip_mode() -> void:
	texture = IMAGE_VIP
	_title.text = tr("%s-Customer\nVIP") % \
			[CurrentLevel.settings.finish_condition.value]


## Shows a Marathon header image and '25-Line Marathon' title text
func _prepare_marathon_mode() -> void:
	texture = IMAGE_MARATHON
	match CurrentLevel.settings.finish_condition.type:
		Milestone.LINES:
			_title.text = tr("%s-Line\nMarathon") % \
					[StringUtils.comma_sep(CurrentLevel.settings.finish_condition.value)]
		Milestone.PIECES:
			_title.text = tr("%s-Piece\nMarathon") % \
					[StringUtils.comma_sep(CurrentLevel.settings.finish_condition.value)]
		_:
			push_warning("Unrecognized marathon finish condition: %s" % \
					[CurrentLevel.settings.finish_condition.type])
			_title.text = ""


## Shows an Ultra header image and '¥200 Ultra' title text
func _prepare_ultra_mode() -> void:
	texture = IMAGE_ULTRA
	_title.text = "%s\n%s" % \
			[StringUtils.format_money(CurrentLevel.settings.finish_condition.value), tr("Ultra")]


## Shows an Sprint header image and '2:30 Sprint' title text
func _prepare_sprint_mode() -> void:
	texture = IMAGE_SPRINT
	if CurrentLevel.settings.finish_condition.value <= 100:
		_title.text = tr("%s-Second\nSprint") % \
				[CurrentLevel.settings.finish_condition.value]
	else:
		_title.text = "%s\n%s" % \
				[StringUtils.format_duration(CurrentLevel.settings.finish_condition.value), tr("Sprint")]


## Shows a Sandbox header image and 'Sandbox' title text
func _prepare_sandbox_mode() -> void:
	texture = IMAGE_SANDBOX
	_title.text = tr("Sandbox")


func _on_Level_settings_changed() -> void:
	_refresh()
