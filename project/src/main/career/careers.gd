class_name Careers
## Enums, constants and utilities for career mode.

## Whether the career map should show the player's progress.
enum ShowProgress {
	NONE, # Skip the progress board
	STATIC, # Display the progress board to show where the player is
	ANIMATED, # Animate the progress board to show the player advancing
}

## Chat key root for non-region-specific cutscenes
const GENERAL_CHAT_KEY_ROOT := "chat/career/general"

## Number of days worth of records which are stored.
const MAX_DAILY_HISTORY := 40

## Maximum number of days the player can progress.
const MAX_DAY := 999999

## Maximum distance the player can travel.
const MAX_DISTANCE_TRAVELLED := 999999

## Maximum number of consecutive levels the player can play in one career session.
const HOURS_PER_CAREER_DAY := 6

## Array of dictionaries containing milestone metadata, including the necessary rank, the distance the player will
## travel, and the UI color.
const RANK_MILESTONES := [
	{"rank": 64.0, "distance": 1, "color": Color("48b968")},
	{"rank": 36.0, "distance": 2, "color": Color("48b968")},
	{"rank": 24.0, "distance": 3, "color": Color("48b968")},
	{"rank": 20.0, "distance": 4, "color": Color("78b948")},
	{"rank": 16.0, "distance": 5, "color": Color("b9b948")},
	{"rank": 10.0, "distance": 10, "color": Color("b95c48")},
	{"rank": 4.0, "distance": 15, "color": Color("b94878")},
	{"rank": 0.0, "distance": 25, "color": Color("b948b9")},
]

## Rank milestone to display when the player fails a boss level.
const RANK_MILESTONE_FAIL := {"rank": 64.0, "distance": 0, "color": Color("bababa")}

## Daily step thresholds to trigger positive feedback.
const DAILY_STEPS_GOOD := 25
const DAILY_STEPS_OK := 8
