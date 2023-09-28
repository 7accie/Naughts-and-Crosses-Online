extends Node
class_name GameStateManager


# References
@export var game_board_manager : Node
@export var player : Node

# Signals
signal game_state_change(new_game_state : GameStates) # Primary way to control how game flows
signal game_end(naughts_won, crosses_won)


# Data
enum GameStates {LOAD, MENU, PIECE_CHOICE, PLAYING, NAUGHT, CROSS, END_GAME, RESET}
static var current_game_state : GameStates
var initial_waiting_count = 0

# Data that needs to be reset
var can_end_state = false
var waiting_count : int = 0	 # Used for counting how many scripts need to be loaded or restarted, needs to be set manually.
var naughts_won = false
var crosses_won = false
var play_after_restart = false

# Play against computer
var comp_is_playing = false
var piece_chosen = false



# Game start
func _ready():
	
	can_end_state = true
	connect_signals()
	
	if waiting_count > 0:
		change_game_state(GameStates.LOAD)
	else:
		change_game_state(GameStates.MENU)
	

func _on_UI_button_click(signal_type : GlobalSignalManager.SignalType):
	
	match signal_type:
		
		GlobalSignalManager.SignalType.REPLAY:
			_on_reset()
		
		GlobalSignalManager.SignalType.PLAY_LOCAL:
			start_game()
			
		GlobalSignalManager.SignalType.PLAY_COMPUTER:
			set_play_computer()
			
		GlobalSignalManager.SignalType.MENU:
			_on_menu_button()
			
		GlobalSignalManager.SignalType.PLAYER_CHOSE_CROSS:
			set_play_computer()
		
		GlobalSignalManager.SignalType.PLAYER_CHOSE_NAUGHT:
			set_play_computer()
		

# Restarting game data
func _on_reset():
	
	can_end_state = true
	naughts_won = false
	crosses_won = false
	
	change_game_state(GameStates.RESET)
		
	if initial_waiting_count == 0:
		end_state()
		


func _on_menu_button():
	
	comp_is_playing = false
	piece_chosen = false
	
	play_after_restart = false
	change_game_state(GameStates.RESET)
	

# Handles what happens on the end of a game state	
func end_state():	
	
	if not can_end_state:
		print("Error! End state is currently disabled.")
		return
	
	# Used to handle loading state
	if is_waiting():
		return
		
	if has_game_ended():
		change_game_state(GameStates.END_GAME)
		return
	
	match current_game_state:
		
		GameStates.LOAD:
			change_game_state(GameStates.MENU)
			
		GameStates.RESET:
			if play_after_restart:
				start_game()
			else:
				change_game_state(GameStates.MENU)
		
		GameStates.NAUGHT:
			change_game_state(GameStates.CROSS)
			
		GameStates.CROSS:
			change_game_state(GameStates.NAUGHT)


# Handles loading in each script that needs to be loaded in prior to the game starting, returning whether if the game is waiting still or not
func is_waiting():
	
	# Only is waiting if the game is loading or resetting
	if current_game_state == GameStates.LOAD or current_game_state == GameStates.RESET:
		
		waiting_count -= 1
		
		# Stops waiting if the waiting count is 0
		if waiting_count <= 0:
			can_end_state = false
			return false
		else:
			return true
			
	else:
		return	false


# Checks if game has ended and updates data accordingly
func has_game_ended():
	
	# Checks who has won. 
	# If no one has won, then checks if it's a draw
	# If not then carries on with the game and returns false
	
	if game_board_manager.has_naughts_won():
		naughts_won = true
	elif game_board_manager.has_crosses_won():
		crosses_won = true
	elif not game_board_manager.has_game_ended():
		return false
	
	handle_game_end()
	return true


# Changes state and activates the signal
func change_game_state(new_game_state : GameStates):		
	
	current_game_state = new_game_state
	game_state_change.emit(new_game_state)


# Handles what happens on game end
func handle_game_end():
	
	print("Game ended.")
	can_end_state = false
	
	if naughts_won:
		print("Naughts won!")
	elif crosses_won:
		print("Crosses won!")
	else:
		print("It's a draw!")
		
	game_end.emit(naughts_won,crosses_won)




# Handles what happens after the game resets based on certain conditions (such as if it's a replay or return to menu)
func handle_reset():
	
	if play_after_restart:
		change_game_state(GameStates.PLAYING)
		change_game_state(GameStates.NAUGHT)
	else:
		change_game_state(GameStates.MENU)


# Starts the game
func start_game():
	
	can_end_state = true
	play_after_restart = true
	change_game_state(GameStates.PLAYING)
	change_game_state(GameStates.NAUGHT)
 

# Starts a game with the computer
func set_play_computer():
	
	comp_is_playing = true
	
	if piece_chosen == false:
		change_game_state(GameStates.PIECE_CHOICE)
		piece_chosen = true
	elif piece_chosen == true:
		start_game()


# Handles logic on each game turn
func handle_game_turn():
	
	if current_game_state == GameStates.NAUGHT:
		print("CROSS")
		change_game_state(GameStates.CROSS)
	elif current_game_state == GameStates.CROSS:
		print("NAUGHT")
		change_game_state(GameStates.NAUGHT)
	else:
		print("Error! Cannot handle game turn as the game is currently not being played!")
		

# Allows a script to request the game state manager to wait for them to finish loading
func request_loading():
	waiting_count += 1
	initial_waiting_count += 1


# Connects all necessary signals for the game state manager
func connect_signals():
	
	GlobalSignalManager.UI_button_click.connect(_on_UI_button_click)
