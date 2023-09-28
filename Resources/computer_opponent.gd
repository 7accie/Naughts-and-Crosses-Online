extends Node


# References
@export var game_board_manager : Node
@export var game_state_manager : Node


var game_piece : GameBoardManager.GamePieces
var is_playing = false


func _ready():
	
	GlobalSignalManager.UI_button_click.connect(_on_UI_button_click)


func on_game_state_change(new_game_state):
	
	if is_playing:
		
		match new_game_state:
			
			GameStateManager.GameStates.CROSS:
				_on_game_turn(GameBoardManager.GamePieces.CROSS)
				
			GameStateManager.GameStates.NAUGHT:
				_on_game_turn(GameBoardManager.GamePieces.NAUGHT)
				
			


# Handles what to do on certain UI inputs
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
			

# Handles what happens on a game turn
func _on_game_turn(game_piece_turn : GameBoardManager.GamePieces):
	
	if game_piece == game_piece_turn:
		handle_computer_turn()
		
		
func handle_computer_turn():
	
	# Waits 1 second
	await get_tree().create_timer(1.0).timeout
	
	# Adds a random piece to the game board
	game_board_manager.add_random_piece(game_piece)
	game_state_manager.end_state()
	

