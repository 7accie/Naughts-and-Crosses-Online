
# ---------------------------------------------------------------------------------------------- #

## Manages signals that are needed across the entire game
## Relays signals from individual scripts so all scripts can access them in a straightforward way
 
# ---------------------------------------------------------------------------------------------- #


extends Node
enum SignalType {
	GAME_BOARD_INPUT, 
	MULTIPLAYER_NAME_INPUT,}




### --- Signals --- ###
																									
### ------------------------------------------------------------------------------------------ ###



## Emitted on a button click from any UI button without a parameter.
signal UI_button_input(input_type: UIController.InputTypes)

## Emitted on player name input.
signal multiplayer_name_input(name: String)

## Emitted on a click on the game board mesh.
signal game_board_input(position: Vector3)

## Emmitted on game end and gives information about who won.
signal game_end(naughts_won: bool, crosses_won: bool)

## Emitted once a player joins an online game.
signal player_join()




### --- Functions --- ###
																									
### ------------------------------------------------------------------------------------------ ###



## Used to connect signals from other scripts to the global signals in this script for all listeners
## to hear.
func connect_global_signal(signal_event, signal_name : String):
	
	match signal_name:
		
		# Matches any misc signals manually	
		"GAME_BOARD_INPUT":
			signal_event.connect(func(_camera:Node, _event:InputEvent, position:Vector3, 
					_normal:Vector3, _shape_idx:int): if Input.is_action_just_pressed("input_hit"): 
						game_board_input.emit(position))
		
		"MULTIPLAYER_PLAYER_NAME":
			signal_event.connect(func(text: String): multiplayer_name_input.emit(text))
			
		"UI_BUTTON_INPUT":
			signal_event.connect(func(input_type: UIController.InputTypes): 
				UI_button_input.emit(input_type))
		
		"GAME_END":
			signal_event.connect(func(naughts_won: bool, crosses_won: bool): 
				game_end.emit(naughts_won, crosses_won))
		
		"PLAYER_JOIN":
			signal_event.connect(func(): player_join.emit())
		
		# In case a signal is not made a case	
		_:
			printerr("Error! Signal not registed named: " + signal_name)


