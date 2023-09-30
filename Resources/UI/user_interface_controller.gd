 
# ---------------------------------------------------------------------------------------------- #

## Manages UI and connects it to the rest of the game
 
# ---------------------------------------------------------------------------------------------- #


extends Node
class_name UIManager




### --- Signals --- ###
																									
### ------------------------------------------------------------------------------------------ ###



## Called when any UI button is pressed, sending the Global SignalType
signal button_press(signal_type: GlobalSignalManager.SignalType)




### --- Properties --- ###
																									
### ------------------------------------------------------------------------------------------ ###


## Stores all menus that have buttons that need to be listened to. [br]
## Key: 'Name as String' , Value: 'Menu as Control'
var button_menus : Dictionary

## Stores all menus that have have text that can be edited. [br]
## Key: 'Name as String' , Value: 'Menu as Control'
var label_menus : Dictionary

## Stores the current active menu that is being displayed. [br]
var active_UI_node : Control




### --- Functions --- ###
																									
### ------------------------------------------------------------------------------------------ ###


## Loads menus, connects necessary signals and sets current active menu as the main menu. [br]
func _ready():
	
	_load_menus()
	_connect_signals()	
	active_UI_node = button_menus["MAIN"]


## When a UI button is pressed, emits the button press signal with the correct SignalType. [br]
## Validations: button_name: must be one registered in the match statement
func _on_button_press(button_name: String):
	
	# Matches input button name to the registered button names
	match button_name.to_upper():
		
		"LOCAL":
			button_press.emit(GlobalSignalManager.SignalType.PLAY_LOCAL)
			
		"COMPUTER":
			button_press.emit(GlobalSignalManager.SignalType.PLAY_COMPUTER)
		
		"REPLAY":
			button_press.emit(GlobalSignalManager.SignalType.REPLAY)
			
		"MENU":
			button_press.emit(GlobalSignalManager.SignalType.MENU)
		
		"NAUGHTS":
			button_press.emit(GlobalSignalManager.SignalType.PLAYER_CHOSE_NAUGHT)
		
		"CROSSES":
			button_press.emit(GlobalSignalManager.SignalType.PLAYER_CHOSE_CROSS)
		
		_:
			printerr("Error! Unregistered button name was inputted.")


## Handles what to do when the game state changes. [br]
## This is done mainly through changing/updating UI menus.
func _on_game_state_change(new_game_state: GameStateManager.GameStates):
	
	match new_game_state:
		
		GameStateManager.GameStates.MENU:
			_change_UI_menu(button_menus["MAIN"])
			
		GameStateManager.GameStates.PIECE_CHOICE:
			_change_UI_menu(button_menus["PIECECHOICE"])
			
		GameStateManager.GameStates.PLAYING:
			_change_UI_menu(label_menus["PLAYING"])
			
		GameStateManager.GameStates.NAUGHT:
			_update_playing_menu(new_game_state)
			
		GameStateManager.GameStates.CROSS:
			_update_playing_menu(new_game_state)


## Handles the UI needed for when the game ends. [br]
## Will display the end game menu and will update labels accordingly based on who won.
func _on_game_end(naughts_won, crosses_won):
	
	var end_game_menu = button_menus["ENDGAME"]
		
	_change_UI_menu(end_game_menu)
	
	if naughts_won:
		end_game_menu.labels["GameEnd"].text = "Naughts won the game!"
	elif crosses_won:
		end_game_menu.labels["GameEnd"].text = "Crosses won the game!"
	else:
		end_game_menu.labels["GameEnd"].text = "It's a draw!"


## Switches the current menu to a new one. [br]
## new_menu should ideally be an actual menu.
func _change_UI_menu(new_menu : Control):
	
	active_UI_node.visible = false
	active_UI_node = new_menu
	active_UI_node.visible = true


## Updates playng menu label based on the current game state.
func _update_playing_menu(new_game_state: GameStateManager.GameStates):
	
	if new_game_state == GameStateManager.GameStates.NAUGHT:
		label_menus["PLAYING"].labels["Turn"].text = "Naughts turn."
	elif new_game_state == GameStateManager.GameStates.CROSS:
		label_menus["PLAYING"].labels["Turn"].text = "Crosses turn."


## Connects all necessary signals needed for the script to operate.
func _connect_signals():
	
	GlobalSignalManager.connect_ui_buttons(button_press)
	GlobalSignalManager.UI_button_click.connect(func(signal_type: GlobalSignalManager.SignalType): if signal_type == GlobalSignalManager.SignalType.REPLAY: button_menus["ENDGAME"].visible = false)
	GlobalSignalManager.UI_button_click.connect(func(signal_type: GlobalSignalManager.SignalType): if signal_type == GlobalSignalManager.SignalType.MENU: _change_UI_menu(button_menus["MAIN"]))


## Gets all menu control nodes from children and adds them to appropriate variables.
func _load_menus():
	
		var menus = get_children()
	
		for menu in menus:
			if menu is ButtonMenuManager:
				button_menus[menu.name.to_upper()] = menu
				menu.button_pressed.connect(_on_button_press)
			else:
				label_menus[menu.name.to_upper()] = menu
	
	
