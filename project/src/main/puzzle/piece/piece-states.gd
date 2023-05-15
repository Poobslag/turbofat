class_name PieceStates
extends StateMachine
## State machine for the states of the active piece.

## Default null state. The puzzle hasn't started yet.
@onready var none: State = $None

## The piece is waiting to spawn. Another piece has just been dropped or the puzzle is just starting.
@onready var prespawn: State = $Prespawn

## The piece is able to be moved/rotated.
@onready var move_piece: State = $MovePiece

## The piece has reached the bottom of the playfield and will lock soon, unless the player performs a lock cancel.
@onready var prelock: State = $Prelock

## The piece has locked, and the playfield is processing the locked piece by clearing lines or forming boxes.
@onready var wait_for_playfield: State = $WaitForPlayfield

## The player has topped out, and the playfield is processing the top out by making room.
@onready var top_out: State = $TopOut

## The game is over. The player won, lost or gave up.
@onready var game_ended: State = $GameEnded
