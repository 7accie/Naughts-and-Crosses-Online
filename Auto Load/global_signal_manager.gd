
# ---------------------------------------------------------------------------------------------- #

## Manages signals that are needed across the entire game
## Relays signals from individual scripts so all scripts can access them in a straightforward way
 
# ---------------------------------------------------------------------------------------------- #


extends Node
enum SignalType {GAME_BOARD_INPUT, REPLAY, PLAY_LOCAL, PLAY_COMPUTER, MENU, PLAYER_CHOSE_NAUGHT, PLAYER_CHOSE_CROSS}




### --- Signals --- ###
																									
### ------------------------------------------------------------------------------------------ ###



## Emitted on a button click from any UI button without a parameter.
signal UI_button_click(signal_type: SignalType)

## Emitted on a click on the game board mesh.
signal game_board_input(position: Vector3)



### --- Functions --- ###
																									
### ------------------------------------------------------------------------------------------ ###



## Used to connect signals from other scripts to the global signals in this script for all listeners
## to hear.
func connect_global_signal(signal_event, signal_type : SignalType):
	
	match signal_type:
		
		# Matches any misc signals manually	
		SignalType.GAME_BOARD_INPUT:
			signal_event.connect(func(_camera:Node, _event:InputEvent, position:Vector3, _normal:Vector3, _shape_idx:int): if Input.is_action_just_pressed("input_hit"): game_board_input.emit(position))
		
		# In case a misc signal is not made a case	
		_:
			print("Error! Signal detected that's not registered.")


## Used for automatically connecting UI buttons to the global UI button signal.
func connect_ui_buttons(signal_event):
	
	signal_event.connect(func(signal_type): UI_button_click.emit(signal_type))

