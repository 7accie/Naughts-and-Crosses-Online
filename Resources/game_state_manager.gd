
# ---------------------------------------------------------------------------------------------- #

## Controls the flow of the game.
## Uses states that the rest of the game listens and reacts to.
 
# ---------------------------------------------------------------------------------------------- #


extends Node
class_name GameStateManager




### --- Signals --- ###
																									
### ------------------------------------------------------------------------------------------ ###



signal game_state_change(new_game_state : GameStates) # Primary way to control how game flows
signal game_end(naughts_won, crosses_won)




### --- Properties --- ###
																									
### ------------------------------------------------------------------------------------------ ###



# References
@export var game_board_manager : Node
@export var player : Node


## Stores each kind of game state.
enum GameStates {
	LOAD, 
	MENU, 
	PIECE_CHOICE, 
	PLAYING, 
	NAUGHT, 
	CROSS, 
	END_GAME, 
	RESET}

## Stores the current game state.
var current_game_state : GameStates

## Stores the total count of scripts that need time to load on ready or reset. [br]
## Does not change after it's set.
var initial_waiting_count : int = 0

## Used to control whether a game state can be externally ended or not.
var can_end_state : bool = false

## Used to check if any scripts are currently waiting.
var check_if_waiting : bool = false

## Used to check if an end-game check needs to be done or not.
var check_if_endgame : bool = false

## Used to temprarily check how many scripts are still waiting. [br]
## Set using initial_waiting_count
var waiting_counter : int = 0

## Stores whether naughts has won, for end game UI. [br]
## Non-persistant variable that will need to be reset.
var naughts_won : bool = false

## Stores whether crosses has won, for end game UI. [br]
## Non-persistant variable that will need to be reset.
var crosses_won : bool = false

## Controls whether the game will automaticlaly be replayed after a reset or not. [br]
var play_after_restart : bool = false

## When the computer is playing, stores whether the player (and therefore computer) has chosen their
## piece and the game can start.
var piece_chosen : bool = false




### --- Functions --- ###
																									
### ------------------------------------------------------------------------------------------ ###



## Connects signals, loads if needed and then starts game at main menu.
func _ready():
	
	can_end_state = true
	connect_signals()
	
	if waiting_counter > 0:
		check_if_waiting = true
		change_game_state(GameStates.LOAD)
	else:
		change_game_state(GameStates.MENU)
	

## Controls what happens on a UI button click.
## UI button clicks have a big influence on game flow.
func _on_UI_button_click(signal_type : GlobalSignalManager.SignalType):
	
	match signal_type:
		
		GlobalSignalManager.SignalType.REPLAY:
			_on_reset()
		
		GlobalSignalManager.SignalType.PLAY_LOCAL:
			start_game()
			
		GlobalSignalManager.SignalType.PLAY_COMPUTER:
			start_game_computer()
			
		GlobalSignalManager.SignalType.MENU:
			_on_menu_button()
			
		GlobalSignalManager.SignalType.PLAYER_CHOSE_CROSS:
			start_game_computer()
		
		GlobalSignalManager.SignalType.PLAYER_CHOSE_NAUGHT:
			start_game_computer()
		

## Resets the game for another game. [br]
## Resets all variables that are non-persistant and sends out the reset signal.
func _on_reset():
	
	can_end_state = true
	naughts_won = false
	crosses_won = false
	
	change_game_state(GameStates.RESET)
		
	if initial_waiting_count == 0:
		end_state()
	else:
		check_if_waiting = true


## Exits out of game, resetting it, to main menu.
func _on_menu_button():
	
	piece_chosen = false
	play_after_restart = false
	
	change_game_state(GameStates.RESET)
	

## Ends current game state and controls what the next game state will then be.
## Checks if there are any waiting scripts or if the current game has ended or not.
func end_state():	
	
	if not can_end_state:
		print("Error! End state is currently disabled.")
		return
	
	# Used to handle loading state
	if check_if_waiting:
		handle_waiting()
		return
		
	if check_if_endgame:
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
func handle_waiting():
	
	# Only is waiting if the game is loading or resetting
	if current_game_state == GameStates.LOAD or current_game_state == GameStates.RESET:
		
		waiting_counter -= 1
		
		# Stops waiting if the waiting count is 0
		if waiting_counter <= 0:
			can_end_state = false
			check_if_waiting = false
			return false
		else:
			return true
			
	else:
		print("Error! Current game state isn't load or reset?")
		return	false


# Checks if game has ended and updates data accordingly.
func has_game_ended():
	
	# Checks who has won. 
	# If no one has won, then checks if it's a draw
	# If not then carries on with the game and returns false
	
	if game_board_manager.has_naughts_won():
		naughts_won = true
	elif game_board_manager.has_crosses_won():
		crosses_won = true
	elif not game_board_manager.has_game_drawn():
		return false
	
	handle_game_end()
	return true


# Changes state and activates the signal.
func change_game_state(new_game_state : GameStates):		
	
	print(new_game_state)
	
	current_game_state = new_game_state
	game_state_change.emit(new_game_state)


# Handles what happens on game end.
func handle_game_end():
	
	print("Game ended.")
	can_end_state = false
	check_if_endgame = false
	
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
	check_if_endgame = true
	change_game_state(GameStates.PLAYING)
	change_game_state(GameStates.NAUGHT)
 

# Starts a game with the computer
func start_game_computer():
	
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
	waiting_counter += 1
	initial_waiting_count += 1


# Connects all necessary signals for the game state manager
func connect_signals():
	
	GlobalSignalManager.UI_button_click.connect(_on_UI_button_click)
