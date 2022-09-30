class_name Foods
## Enums, constants and utilities for the food which gets fed to the customers.

## Different box varieties. Boxes have different graphics based on their ingredients.
enum BoxType {
	BROWN,
	PINK,
	BREAD,
	WHITE,
	CAKE_JJO,
	CAKE_JLO,
	CAKE_JTT,
	CAKE_LLO,
	CAKE_LTT,
	CAKE_PQV,
	CAKE_PUV,
	CAKE_QUV,
}

## Different food varieties.
##
## There are more food types than box types, because snack boxes of one color produce two different foods.
enum FoodType {
	BROWN_0,
	BROWN_1,
	PINK_0,
	PINK_1,
	BREAD_0,
	BREAD_1,
	WHITE_0,
	WHITE_1,
	CAKE_JJO,
	CAKE_JLO,
	CAKE_JTT,
	CAKE_LLO,
	CAKE_LTT,
	CAKE_PQV,
	CAKE_PUV,
	CAKE_QUV,
}

## Food colors for the food which gets hurled into the creature's mouth.
const COLOR_VEGETABLE := Color("335320")
const COLOR_BROWN := Color("a4470b")
const COLOR_PINK := Color("ff5d68")
const COLOR_BREAD := Color("ffa357")
const COLOR_WHITE := Color("fff6eb")
const COLORS_ALL := [COLOR_BROWN, COLOR_PINK, COLOR_BREAD, COLOR_WHITE ]

## key: (int) an enum from FoodType
## value: (int) an enum from BoxType for the corresponding box
const BOX_TYPE_BY_FOOD_TYPE := {
	FoodType.BROWN_0: BoxType.BROWN,
	FoodType.BROWN_1: BoxType.BROWN,
	FoodType.PINK_0: BoxType.PINK,
	FoodType.PINK_1: BoxType.PINK,
	FoodType.BREAD_0: BoxType.BREAD,
	FoodType.BREAD_1: BoxType.BREAD,
	FoodType.WHITE_0: BoxType.WHITE,
	FoodType.WHITE_1: BoxType.WHITE,
	FoodType.CAKE_JJO: BoxType.CAKE_JJO,
	FoodType.CAKE_JLO: BoxType.CAKE_JLO,
	FoodType.CAKE_JTT: BoxType.CAKE_JTT,
	FoodType.CAKE_LLO: BoxType.CAKE_LLO,
	FoodType.CAKE_LTT: BoxType.CAKE_LTT,
	FoodType.CAKE_PQV: BoxType.CAKE_PQV,
	FoodType.CAKE_PUV: BoxType.CAKE_PUV,
	FoodType.CAKE_QUV: BoxType.CAKE_QUV,
}

const COLORS_BY_FOOD_TYPE := {
	FoodType.BROWN_0: [COLOR_BROWN],
	FoodType.BROWN_1: [COLOR_BROWN],
	FoodType.PINK_0: [COLOR_PINK],
	FoodType.PINK_1: [COLOR_PINK],
	FoodType.BREAD_0: [COLOR_BREAD],
	FoodType.BREAD_1: [COLOR_BREAD],
	FoodType.WHITE_0: [COLOR_WHITE],
	FoodType.WHITE_1: [COLOR_WHITE],
	FoodType.CAKE_JJO: [COLOR_PINK, COLOR_PINK, COLOR_WHITE],
	FoodType.CAKE_JLO: [COLOR_PINK, COLOR_BROWN, COLOR_WHITE],
	FoodType.CAKE_JTT: [COLOR_PINK, COLOR_BREAD, COLOR_BREAD],
	FoodType.CAKE_LLO: [COLOR_BROWN, COLOR_BROWN, COLOR_WHITE],
	FoodType.CAKE_LTT: [COLOR_BROWN, COLOR_BREAD, COLOR_BREAD],
	FoodType.CAKE_PQV: [COLOR_PINK, COLOR_BROWN, COLOR_WHITE],
	FoodType.CAKE_PUV: [COLOR_PINK, COLOR_BREAD, COLOR_WHITE],
	FoodType.CAKE_QUV: [COLOR_BROWN, COLOR_BREAD, COLOR_WHITE],
}

## key: (int) an enum from BoxType
## value: (Array, int) array of enums from FoodType for the corresponding food items
const FOOD_TYPES_BY_BOX_TYPES := {
	BoxType.BROWN: [FoodType.BROWN_0, FoodType.BROWN_1],
	BoxType.PINK: [FoodType.PINK_0, FoodType.PINK_1],
	BoxType.BREAD: [FoodType.BREAD_0, FoodType.BREAD_1],
	BoxType.WHITE: [FoodType.WHITE_0, FoodType.WHITE_1],
	BoxType.CAKE_JJO: [FoodType.CAKE_JJO],
	BoxType.CAKE_JLO: [FoodType.CAKE_JLO],
	BoxType.CAKE_JTT: [FoodType.CAKE_JTT],
	BoxType.CAKE_LLO: [FoodType.CAKE_LLO],
	BoxType.CAKE_LTT: [FoodType.CAKE_LTT],
	BoxType.CAKE_PQV: [FoodType.CAKE_PQV],
	BoxType.CAKE_PUV: [FoodType.CAKE_PUV],
	BoxType.CAKE_QUV: [FoodType.CAKE_QUV],
}

## Returns 'true' if the specified box type corresponds to a snack box.
##
## There are four snack box colors; brown, pink, bread and white.
static func is_snack_box(box_type: int) -> bool:
	return box_type in [
		BoxType.BROWN,
		BoxType.PINK,
		BoxType.BREAD,
		BoxType.WHITE
	]


## Returns 'true' if the specified box type corresponds to a cake box.
##
## There are eight cake box colors; one for each combination of three pieces which forms a rectangle.
static func is_cake_box(box_type: int) -> bool:
	return box_type in [
		BoxType.CAKE_JJO,
		BoxType.CAKE_JLO,
		BoxType.CAKE_JTT,
		BoxType.CAKE_LLO,
		BoxType.CAKE_LTT,
		BoxType.CAKE_PQV,
		BoxType.CAKE_PUV,
		BoxType.CAKE_QUV,
	]


## Returns 'true' if the specified food type corresponds to a snack food.
##
## There are eight snack food types; two each of brown, pink, bread and white.
static func is_snack_food(food_type: int) -> bool:
	return food_type in [
		FoodType.BROWN_0,
		FoodType.BROWN_1,
		FoodType.PINK_0,
		FoodType.PINK_1,
		FoodType.BREAD_0,
		FoodType.BREAD_1,
		FoodType.WHITE_0,
		FoodType.WHITE_1,
	]


## Returns 'true' if the specified food type corresponds to a cake food.
##
## There are eight cake box colors; one for each combination of three pieces which forms a rectangle.
static func is_cake_food(food_type: int) -> bool:
	return food_type in [
		FoodType.CAKE_JJO,
		FoodType.CAKE_JLO,
		FoodType.CAKE_JTT,
		FoodType.CAKE_LLO,
		FoodType.CAKE_LTT,
		FoodType.CAKE_PQV,
		FoodType.CAKE_PUV,
		FoodType.CAKE_QUV,
	]
