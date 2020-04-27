extends Node
"""
Stores data about the different 'speed levels' such as how fast pieces should drop, how long it takes them to lock
into the playfield, and how long to pause when clearing lines.

Much of this speed data was derived from wikis for other piece-dropping games which have the concept of a 'hold piece'
so it's likely it will change over time to become more lenient.
"""

# All gravity constants are integers like '16', which actually correspond to fractions like '16/256' which means the
# piece takes 16 frames to drop one row. G is the denominator of that fraction.
const G := 256

# The maximum number of 'lock resets' the player is allotted for a single piece. A lock reset occurs when a piece is at
# the bottom of the screen but the player moves or rotates it to prevent from locking.
const MAX_LOCK_RESETS := 15

# The gravity constant used when the player soft-drops a piece.
const DROP_G := 128

# When the player does a 'smush move' the piece is unaffected by gravity for this many frames.
const SMUSH_FRAMES := 4



# used when the game isn't running
var null_level := PieceSpeed.new("-",   4, 20, 36, 7, 16, 40, 24, 12)

var beginner_level_0 := PieceSpeed.new("0",   4, 20, 36, 7, 16, 40, 24, 12)
var beginner_level_1 := PieceSpeed.new("1",   5, 20, 36, 7, 16, 40, 24, 12)
var beginner_level_2 := PieceSpeed.new("2",   6, 20, 36, 7, 16, 40, 24, 12)
var beginner_level_3 := PieceSpeed.new("3",   8, 20, 36, 7, 16, 40, 24, 12)
var beginner_level_4 := PieceSpeed.new("4",  10, 20, 36, 7, 16, 40, 24, 12)
var beginner_level_5 := PieceSpeed.new("5",  12, 20, 36, 7, 16, 40, 24, 12)
var beginner_level_6 := PieceSpeed.new("6",  16, 20, 36, 7, 16, 40, 24, 12)
var beginner_level_7 := PieceSpeed.new("7",  24, 20, 36, 7, 16, 40, 24, 12)
var beginner_level_8 := PieceSpeed.new("8",  32, 20, 36, 7, 16, 40, 24, 12)
var beginner_level_9 := PieceSpeed.new("9",  48, 20, 36, 7, 16, 40, 24, 12)

var hard_level_0  := PieceSpeed.new("A0",    4, 20, 20, 7, 16, 40, 24, 12)
var hard_level_1  := PieceSpeed.new("A1",   32, 20, 20, 7, 16, 40, 24, 12)
var hard_level_2  := PieceSpeed.new("A2",   48, 20, 20, 7, 16, 40, 24, 12)
var hard_level_3  := PieceSpeed.new("A3",   64, 20, 20, 7, 16, 40, 24, 12)
var hard_level_4  := PieceSpeed.new("A4",   96, 20, 20, 7, 16, 40, 24, 12)
var hard_level_5  := PieceSpeed.new("A5",  128, 20, 20, 7, 16, 40, 24, 12)
var hard_level_6  := PieceSpeed.new("A6",  152, 20, 20, 7, 16, 40, 24, 12)
var hard_level_7  := PieceSpeed.new("A7",  176, 20, 20, 7, 16, 40, 24, 12)
var hard_level_8  := PieceSpeed.new("A8",  200, 20, 20, 7, 16, 40, 24, 12)
var hard_level_9  := PieceSpeed.new("A9",  224, 20, 20, 7, 16, 40, 24, 12)
var hard_level_10 := PieceSpeed.new("AA",  1*G, 20, 20, 7, 16, 40, 24, 12)
var hard_level_11 := PieceSpeed.new("AB",  2*G, 20, 20, 7, 16, 40, 24, 12)
var hard_level_12 := PieceSpeed.new("AC",  3*G, 20, 20, 7, 16, 40, 24, 12)
var hard_level_13 := PieceSpeed.new("AD",  5*G, 20, 20, 7, 16, 40, 24, 12)
var hard_level_14 := PieceSpeed.new("AE", 20*G, 20, 16, 7, 10, 30, 18,  9)
var hard_level_15 := PieceSpeed.new("AF", 20*G, 16, 12, 7, 10, 30, 12,  6)

var crazy_level_0 := PieceSpeed.new( "F0",    4, 12, 8, 7, 10, 24, 6, 3)
var crazy_level_1 := PieceSpeed.new( "F1",  1*G, 12, 8, 7, 10, 24, 6, 3)
var crazy_level_2 := PieceSpeed.new( "FA", 20*G, 12, 8, 7, 10, 24, 6, 3)
var crazy_level_3 := PieceSpeed.new( "FB", 20*G,  8, 6, 5,  6, 22, 5, 3)
var crazy_level_4 := PieceSpeed.new( "FC", 20*G,  6, 4, 5,  6, 20, 4, 3)
var crazy_level_5 := PieceSpeed.new( "FD", 20*G,  4, 2, 5,  6, 18, 3, 3)
var crazy_level_6 := PieceSpeed.new( "FE", 20*G,  4, 2, 5,  6, 16, 3, 3)
var crazy_level_7 := PieceSpeed.new( "FF", 20*G,  4, 2, 5,  6, 14, 3, 3)
var crazy_level_8 := PieceSpeed.new("FFF", 20*G,  4, 2, 5,  6, 12, 3, 3)
