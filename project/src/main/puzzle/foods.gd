class_name Foods
## Enums, constants and utilities for the food which gets fed to the customers.

## Different box varieties. Boxes have different graphics based on their ingredients.
enum BoxType {
	BROWN,
	PINK,
	BREAD,
	WHITE,
	CHEESE,
	CAKE_JJO,
	CAKE_JLO,
	CAKE_JTT,
	CAKE_LLO,
	CAKE_LTT,
	CAKE_PQV,
	CAKE_PUV,
	CAKE_QUV,
	CAKE_CJU,
	CAKE_CLU,
	CAKE_CTU,
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
	CHEESE_0,
	CHEESE_1,
	CAKE_JJO,
	CAKE_JLO,
	CAKE_JTT,
	CAKE_LLO,
	CAKE_LTT,
	CAKE_PQV,
	CAKE_PUV,
	CAKE_QUV,
	CAKE_CJU,
	CAKE_CLU,
	CAKE_CTU,
}

## Food colors for food crumbs and goop.
const COLOR_VEGETABLE := Color("335320")
const COLOR_BROWN := Color("a4470b")
const COLOR_PINK := Color("ff5d68")
const COLOR_BREAD := Color("ffa357")
const COLOR_WHITE := Color("fff6eb")
const COLOR_CHEESE := Color("fbc457")
const COLORS_ALL := [COLOR_BROWN, COLOR_PINK, COLOR_BREAD, COLOR_WHITE, COLOR_CHEESE]

## Food colors for veggie crumbs and goop, for levels which use the 'veggie' tileset.
const COLOR_VEG_GREEN := Color("839f43")
const COLOR_VEG_RED := Color("a21d24")
const COLOR_VEG_BREAD := Color("af884d")
const COLOR_VEG_WHITE := Color("c1a57e")
const COLOR_VEG_CHEESE := Color("c1a57e")
const COLORS_VEG_ALL := [COLOR_VEG_GREEN, COLOR_VEG_RED, COLOR_VEG_BREAD, COLOR_VEG_WHITE, COLOR_VEG_CHEESE]


## key: (int) Enum from FoodType
## value: (BoxType) corresponding box
const BOX_TYPES_BY_FOOD_TYPE := {
	FoodType.BROWN_0: BoxType.BROWN,
	FoodType.BROWN_1: BoxType.BROWN,
	FoodType.PINK_0: BoxType.PINK,
	FoodType.PINK_1: BoxType.PINK,
	FoodType.BREAD_0: BoxType.BREAD,
	FoodType.BREAD_1: BoxType.BREAD,
	FoodType.WHITE_0: BoxType.WHITE,
	FoodType.WHITE_1: BoxType.WHITE,
	FoodType.CHEESE_0: BoxType.CHEESE,
	FoodType.CHEESE_1: BoxType.CHEESE,
	FoodType.CAKE_JJO: BoxType.CAKE_JJO,
	FoodType.CAKE_JLO: BoxType.CAKE_JLO,
	FoodType.CAKE_JTT: BoxType.CAKE_JTT,
	FoodType.CAKE_LLO: BoxType.CAKE_LLO,
	FoodType.CAKE_LTT: BoxType.CAKE_LTT,
	FoodType.CAKE_PQV: BoxType.CAKE_PQV,
	FoodType.CAKE_PUV: BoxType.CAKE_PUV,
	FoodType.CAKE_QUV: BoxType.CAKE_QUV,
	FoodType.CAKE_CJU: BoxType.CAKE_CJU,
	FoodType.CAKE_CLU: BoxType.CAKE_CLU,
	FoodType.CAKE_CTU: BoxType.CAKE_CTU,
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
	FoodType.CHEESE_0: [COLOR_CHEESE],
	FoodType.CHEESE_1: [COLOR_CHEESE],
	FoodType.CAKE_JJO: [COLOR_PINK, COLOR_PINK, COLOR_WHITE],
	FoodType.CAKE_JLO: [COLOR_PINK, COLOR_BROWN, COLOR_WHITE],
	FoodType.CAKE_JTT: [COLOR_PINK, COLOR_BREAD, COLOR_BREAD],
	FoodType.CAKE_LLO: [COLOR_BROWN, COLOR_BROWN, COLOR_WHITE],
	FoodType.CAKE_LTT: [COLOR_BROWN, COLOR_BREAD, COLOR_BREAD],
	FoodType.CAKE_PQV: [COLOR_PINK, COLOR_BROWN, COLOR_WHITE],
	FoodType.CAKE_PUV: [COLOR_PINK, COLOR_BREAD, COLOR_WHITE],
	FoodType.CAKE_QUV: [COLOR_BROWN, COLOR_BREAD, COLOR_WHITE],
	FoodType.CAKE_CJU: [COLOR_CHEESE, COLOR_PINK, COLOR_BREAD],
	FoodType.CAKE_CLU: [COLOR_CHEESE, COLOR_BROWN, COLOR_BREAD],
	FoodType.CAKE_CTU: [COLOR_CHEESE, COLOR_BREAD, COLOR_BREAD],
}

## key: (int) Enum from BoxType
## value: (Array, FoodType) FoodTypes for the corresponding food items
const FOOD_TYPES_BY_BOX_TYPE := {
	BoxType.BROWN: [FoodType.BROWN_0, FoodType.BROWN_1],
	BoxType.PINK: [FoodType.PINK_0, FoodType.PINK_1],
	BoxType.BREAD: [FoodType.BREAD_0, FoodType.BREAD_1],
	BoxType.WHITE: [FoodType.WHITE_0, FoodType.WHITE_1],
	BoxType.CHEESE: [FoodType.CHEESE_0, FoodType.CHEESE_1],
	BoxType.CAKE_JJO: [FoodType.CAKE_JJO],
	BoxType.CAKE_JLO: [FoodType.CAKE_JLO],
	BoxType.CAKE_JTT: [FoodType.CAKE_JTT],
	BoxType.CAKE_LLO: [FoodType.CAKE_LLO],
	BoxType.CAKE_LTT: [FoodType.CAKE_LTT],
	BoxType.CAKE_PQV: [FoodType.CAKE_PQV],
	BoxType.CAKE_PUV: [FoodType.CAKE_PUV],
	BoxType.CAKE_QUV: [FoodType.CAKE_QUV],
	BoxType.CAKE_CJU: [FoodType.CAKE_CJU],
	BoxType.CAKE_CLU: [FoodType.CAKE_CLU],
	BoxType.CAKE_CTU: [FoodType.CAKE_CTU],
}

## key: (int) Enum from BoxType
## value: (Array, Color) Food colors for the corresponding food items
const COLORS_BY_BOX_TYPE := {
	BoxType.BROWN: [COLOR_BROWN],
	BoxType.PINK: [COLOR_PINK],
	BoxType.BREAD: [COLOR_BREAD],
	BoxType.WHITE: [COLOR_WHITE],
	BoxType.CHEESE: [COLOR_CHEESE],
	BoxType.CAKE_JJO: [COLOR_PINK, COLOR_PINK, COLOR_WHITE],
	BoxType.CAKE_JLO: [COLOR_PINK, COLOR_BROWN, COLOR_WHITE],
	BoxType.CAKE_JTT: [COLOR_PINK, COLOR_BREAD, COLOR_BREAD],
	BoxType.CAKE_LLO: [COLOR_BROWN, COLOR_BROWN, COLOR_WHITE],
	BoxType.CAKE_LTT: [COLOR_BROWN, COLOR_BREAD, COLOR_BREAD],
	BoxType.CAKE_PQV: [COLOR_PINK, COLOR_BROWN, COLOR_WHITE],
	BoxType.CAKE_PUV: [COLOR_PINK, COLOR_BREAD, COLOR_WHITE],
	BoxType.CAKE_QUV: [COLOR_BROWN, COLOR_BREAD, COLOR_WHITE],
	BoxType.CAKE_CJU: [COLOR_CHEESE, COLOR_PINK, COLOR_BREAD],
	BoxType.CAKE_CLU: [COLOR_CHEESE, COLOR_BROWN, COLOR_BREAD],
	BoxType.CAKE_CTU: [COLOR_CHEESE, COLOR_BREAD, COLOR_BREAD],
}


## Returns 'true' if the specified box type corresponds to a snack box.
##
## There are four snack box colors; brown, pink, bread and white.
static func is_snack_box(box_type: int) -> bool:
	return box_type in [
		BoxType.BROWN,
		BoxType.PINK,
		BoxType.BREAD,
		BoxType.WHITE,
		BoxType.CHEESE,
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
		BoxType.CAKE_CJU,
		BoxType.CAKE_CLU,
		BoxType.CAKE_CTU,
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
		FoodType.CHEESE_0,
		FoodType.CHEESE_1,
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
		FoodType.CAKE_CJU,
		FoodType.CAKE_CLU,
		FoodType.CAKE_CTU,
	]
