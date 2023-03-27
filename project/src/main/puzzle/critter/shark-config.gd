class_name SharkConfig
## Rules for sharks on a specific level.

enum Home {
	ANY, # sharks appear anywhere
	VEG, # sharks only appear on veggie blocks
	BOX, # sharks only appear on snack/cake boxes
	CAKE, # sharks only appear on cake boxes
	SURFACE, # sharks only appear if there is no block overhead
	HOLE, # sharks only appear if there is a block overhead
}

enum SharkSize {
	SMALL,
	MEDIUM,
	LARGE,
}

## how many sharks appear during a single 'add sharks' effect
var count: int = 1

## which type of terrain the sharks appear on
var home: int = Home.ANY

## which rows the sharks appear on
var lines: Array = []

## which columns the sharks appear on
var columns: Array = []

## An enum from SharkSize for the shark's size
var size: int = SharkSize.MEDIUM

## how long the shark waits before disappearing
var patience: int = 0
