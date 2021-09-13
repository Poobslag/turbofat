class_name Foods
"""
Enums, constants and utilities for the food which gets fed to the customers.
"""

"""
Different box varieties. Boxes have different graphics based on their ingredients.
"""
enum BoxColorInt {
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

"""
Different food varieties.

There are more food types than color ints, because snack boxes of one color produce two different foods.
"""
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

"""
Food colors for the food which gets hurled into the creature's mouth.
"""
const COLOR_VEGETABLE := Color("335320")
const COLOR_BROWN := Color("a4470b")
const COLOR_PINK := Color("ff5d68")
const COLOR_BREAD := Color("ffa357")
const COLOR_WHITE := Color("fff6eb")
const COLORS_ALL := [COLOR_BROWN, COLOR_PINK, COLOR_BREAD, COLOR_WHITE ]

# key: an enum from FoodType
# value: an enum from BoxColorInt for the corresponding box
const COLOR_INT_BY_FOOD_TYPE := {
	FoodType.BROWN_0: BoxColorInt.BROWN,
	FoodType.BROWN_1: BoxColorInt.BROWN,
	FoodType.PINK_0: BoxColorInt.PINK,
	FoodType.PINK_1: BoxColorInt.PINK,
	FoodType.BREAD_0: BoxColorInt.BREAD,
	FoodType.BREAD_1: BoxColorInt.BREAD,
	FoodType.WHITE_0: BoxColorInt.WHITE,
	FoodType.WHITE_1: BoxColorInt.WHITE,
	FoodType.CAKE_JJO: BoxColorInt.CAKE_JJO,
	FoodType.CAKE_JLO: BoxColorInt.CAKE_JLO,
	FoodType.CAKE_JTT: BoxColorInt.CAKE_JTT,
	FoodType.CAKE_LLO: BoxColorInt.CAKE_LLO,
	FoodType.CAKE_LTT: BoxColorInt.CAKE_LTT,
	FoodType.CAKE_PQV: BoxColorInt.CAKE_PQV,
	FoodType.CAKE_PUV: BoxColorInt.CAKE_PUV,
	FoodType.CAKE_QUV: BoxColorInt.CAKE_QUV,
}

# key: an enum from FoodType
# value: Array of Color instances for the colors of the ingredients.
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

# key: an enum from BoxColorInt
# value: array of enums from FoodType for the corresponding food items
const FOOD_TYPES_BY_BOX_COLOR_INTS := {
	BoxColorInt.BROWN: [FoodType.BROWN_0, FoodType.BROWN_1],
	BoxColorInt.PINK: [FoodType.PINK_0, FoodType.PINK_1],
	BoxColorInt.BREAD: [FoodType.BREAD_0, FoodType.BREAD_1],
	BoxColorInt.WHITE: [FoodType.WHITE_0, FoodType.WHITE_1],
	BoxColorInt.CAKE_JJO: [FoodType.CAKE_JJO],
	BoxColorInt.CAKE_JLO: [FoodType.CAKE_JLO],
	BoxColorInt.CAKE_JTT: [FoodType.CAKE_JTT],
	BoxColorInt.CAKE_LLO: [FoodType.CAKE_LLO],
	BoxColorInt.CAKE_LTT: [FoodType.CAKE_LTT],
	BoxColorInt.CAKE_PQV: [FoodType.CAKE_PQV],
	BoxColorInt.CAKE_PUV: [FoodType.CAKE_PUV],
	BoxColorInt.CAKE_QUV: [FoodType.CAKE_QUV],
}

"""
Returns 'true' if the specified color int corresponds to a snack box.

There are four snack color ints; brown, pink, bread and white.
"""
static func is_snack_box(color_int: int) -> bool:
	return color_int <= BoxColorInt.WHITE


"""
Returns 'true' if the specified color int corresponds to a cake box.

There are eight cake color ints; one for each combination of three pieces which forms a rectangle.
"""
static func is_cake_box(color_int: int) -> bool:
	return color_int >= BoxColorInt.CAKE_JJO


"""
Returns 'true' if the specified food type corresponds to a snack food.

There are eight snack food types; two each of brown, pink, bread and white.
"""
static func is_snack_food(food_type: int) -> bool:
	return food_type <= FoodType.WHITE


"""
Returns 'true' if the specified food type corresponds to a cake food.

There are eight cake box colors; one for each combination of three pieces which forms a rectangle.
"""
static func is_cake_food(food_type: int) -> bool:
	return food_type >= FoodType.CAKE_JJO
