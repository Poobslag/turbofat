class_name MoleConfig
## Rules for moles on a specific level.
##
## This includes how many moles to add, where to add them, how long they stay and what they dig.

enum Home {
	ANY, # mole digs anywhere
	VEG, # mole will only dig on veggie blocks
	BOX, # mole will dig on snack/cake boxes
	CAKE, # mole will dig on cake boxes
	SURFACE, # mole will only dig if there is no block overhead
	HOLE, # mole will only dig if there is a block overhead
}

enum Reward {
	SEED, # the mole digs up a seed
	STAR, # the mole digs up a star
}

## how many moles appear during a single 'add moles' effect
var count := 1

## which type of terrain the moles appear on
var home: int = Home.ANY

## which rows the moles appear on
var lines: Array = []

## which columns the moles appear on
var columns: Array = []

## how many turns/seconds/cycles the moles dig for
var dig_duration: int = 3

## the reward the moles dig up
var reward: int = Reward.STAR
