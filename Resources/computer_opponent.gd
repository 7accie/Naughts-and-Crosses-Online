
# ---------------------------------------------------------------------------------------------- #

## Controls computer behaviour.
 
# ---------------------------------------------------------------------------------------------- #


extends Node
class_name ComputerOpponent




### --- Properties --- ###
																									
### ------------------------------------------------------------------------------------------ ###


# References
@export var game_board_manager : Node
@export var game_state_manager : Node


## Stores the game_piece that the computer is currently playing.
var game_piece : GameBoardManager.GamePieces

## Used to check if the computer is playing the game or not.
var is_playing = false




### --- Functions --- ###
																									
### ------------------------------------------------------------------------------------------ ###


## Connects necessary signals for the script
func _ready():
	
	GlobalSignalManager.UI_button_click.connect(_on_UI_button_click)


## Controls what happens on each game state. [br]
## Just reacts to game turn states (NAUGHTS or CROSSES)
func on_game_state_change(new_game_state):
	
	if is_playing:
		
		match new_game_state:
			
			GameStateManager.GameStates.CROSS:
				_on_game_turn(GameBoardManager.GamePieces.CROSS)
				
			GameStateManager.GameStates.NAUGHT:
				_on_game_turn(GameBoardManager.GamePieces.NAUGHT)


## Handles what to do on certain UI inputs. [br]
## Mainly to get game_piece and is_playing values.
func _on_UI_button_click(signal_type):
	
	match signal_type:
		
		GlobalSignalManager.SignalType.PLAYER_CHOSE_NAUGHT:
			game_piece = GameBoardManager.GamePieces.CROSS
			is_playing = true
		
		GlobalSignalManager.SignalType.PLAYER_CHOSE_CROSS:
			game_piece = GameBoardManager.GamePieces.NAUGHT
			is_playing = true
			
		GlobalSignalManager.SignalType.MENU:
			is_playing = false


## Handles what happens on a game turn.
func _on_game_turn(game_piece_turn : GameBoardManager.GamePieces):
	
	if game_piece == game_piece_turn:
		handle_computer_turn()


## Handles the actual game turn.
func handle_computer_turn():
	
	# Waits 1 second
	await get_tree().create_timer(1.0).timeout
	
	# Adds a random piece to the game board
	game_board_manager.add_random_piece(game_piece)
	game_state_manager.end_state()
	

