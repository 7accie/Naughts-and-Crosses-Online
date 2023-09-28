extends Node


# Reference
@export var game_state_manager : Node
@export var game_board_manager : Node


# Data
var game_piece : GameBoardManager.GamePieces = GameBoardManager.GamePieces.CROSS
var change_game_piece = true


func _ready():
	
	GlobalSignalManager.UI_button_click.connect(_on_UI_button_click)


# Handles what to do on certain UI inputs
func _on_UI_button_click(signal_type):
	
	match signal_type:
		
		GlobalSignalManager.SignalType.PLAYER_CHOSE_NAUGHT:
			game_piece = GameBoardManager.GamePieces.NAUGHT
			change_game_piece = false
		
		GlobalSignalManager.SignalType.PLAYER_CHOSE_CROSS:
			game_piece = GameBoardManager.GamePieces.CROSS
			change_game_piece = false
			
		GlobalSignalManager.SignalType.MENU:
			change_game_piece = true
			

# Handles what to do when game state changes, such as for playing and loading
func _on_game_state_change(new_game_state : GameStateManager.GameStates):

	match new_game_state:
		
		#Switches game piece and starts turn
		GameStateManager.GameStates.CROSS:
			_on_game_turn(GameBoardManager.GamePieces.CROSS)
		
		# Switches game piece and starts turn
		GameStateManager.GameStates.NAUGHT:
			_on_game_turn(GameBoardManager.GamePieces.NAUGHT)


# Checks if the input was valid, if not listens for another input
func _on_game_board_click(position:Vector3):
	GlobalSignalManager.game_board_input.disconnect(_on_game_board_click)
	
	if not game_board_manager.add_piece(game_piece, position):
		GlobalSignalManager.game_board_input.connect(_on_game_board_click)
	else:
		game_state_manager.end_state()
	

# Handle turns regardless of whether its for local or computer play
func _on_game_turn(game_piece_turn : GameBoardManager.GamePieces):
	
	# For swtiching pieces the player places for local games
	if change_game_piece:
		game_piece = game_piece_turn
		
	# For checking if it's the player's turn or not for non-local games
	elif not game_piece == game_piece_turn:
		return
	
	handle_player_turn()


# Gets the player move by listening to game board input
func handle_player_turn():
	
	if GlobalSignalManager.game_board_input.is_connected(_on_game_board_click):
		print("Already connected!")
	else:
		GlobalSignalManager.game_board_input.connect(_on_game_board_click)
