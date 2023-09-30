 
# ---------------------------------------------------------------------------------------------- #

## Manages UI and connects it to the rest of the game.
## Also manages input from UI.
 
# ---------------------------------------------------------------------------------------------- #


extends Node
class_name UIController




### --- Signals --- ###
																									
### ------------------------------------------------------------------------------------------ ###


## Called when any UI button is pressed, sending the Global SignalType
signal button_input(input_type: InputTypes)

signal player_name_input(name: String)




### --- Properties --- ###
																									
### ------------------------------------------------------------------------------------------ ###


## Stores all possible types of input from UI.
enum InputTypes {
	REPLAY_BUTTON, 
	PLAY_LOCAL_BUTTON, 
	PLAY_COMPUTER_BUTTON, 
	MENU_BUTTON, 
	PLAYER_CHOSE_NAUGHT_BUTTON, 
	PLAYER_CHOSE_CROSS_BUTTON,
	MULTIPLAYER_PLAYER_NAME_BUTTON,
	MULTIPLAYER_OPTIONS_BUTTON, 
	MULTIPLAYER_HOST_BUTTON, 
	MULTIPLAYER_JOIN_BUTTON, 
	MULTIPLAYER_START_BUTTON,
}

## States the UI can be in. [br]
## Not same as Menus (i.e. could be same state, but different menus or vice versa)
enum UIStates{
	REPLAY,
	TO_MENU,
	MULTIPLAYER_PLAYER_NAME_INPUT,
	MULTIPLAYER_HOST,
	MULTIPLAYER_OPTIONS,
	MULTIPLAYER_JOIN,
	COMPUTER_PIECE_CHOICE,
	PLAYING,
	NEW_GAME_TURN,
	GAME_END
}


## Dictionary used for converting a UI input name to an input type.
const name_to_input_type = {
	"LOCAL": InputTypes.PLAY_LOCAL_BUTTON,
	"COMPUTER": InputTypes.PLAY_COMPUTER_BUTTON,
	"REPLAY": InputTypes.REPLAY_BUTTON,
	"MENU": InputTypes.MENU_BUTTON,
	"NAUGHTS": InputTypes.PLAYER_CHOSE_NAUGHT_BUTTON,
	"CROSSES": InputTypes.PLAYER_CHOSE_CROSS_BUTTON,
	"CANCELNAMEINPUT": InputTypes.MENU_BUTTON,
	"CONFIRMNAMEINPUT": InputTypes.MULTIPLAYER_OPTIONS_BUTTON,
	"ONLINE": InputTypes.MULTIPLAYER_PLAYER_NAME_BUTTON,
	"HOST": InputTypes.MULTIPLAYER_HOST_BUTTON,
	"JOIN": InputTypes.MULTIPLAYER_JOIN_BUTTON,
	"START": InputTypes.MULTIPLAYER_START_BUTTON}	


## Stores all menus that have buttons that need to be listened to. [br]
## Key: 'Name as String' , Value: 'Menu as Control'
var input_menus : Dictionary

## Stores all menus that have have text that can be edited. [br]
## Key: 'Name as String' , Value: 'Menu as Control'
var label_menus : Dictionary

## Stores the current active menu that is being displayed.
var active_UI_node : Control

## Stores all default UI data so that it can be used to reset it. [br]
## Key: 'UI element', Value: 'Default data of UI element'
var default_UI_data = {}



### --- Functions --- ###
																									
### ------------------------------------------------------------------------------------------ ###


## Loads menus, connects necessary signals and sets current active menu as the main menu.
func _ready():
	
	get_all_menus()
	_connect_signals()	
	_get_default_UI_data()
	active_UI_node = input_menus["MAIN"]
	

## When a UI button is pressed, emits the button press signal with the correct SignalType. [br]
## Validations: button_name: must be one registered in button_global_signals.
func _on_button_input(input_type: InputTypes):
	
	match input_type:
		
		InputTypes.REPLAY_BUTTON:
			_handle_UI_state(UIStates.REPLAY)
		
		InputTypes.MENU_BUTTON:
			_handle_UI_state(UIStates.TO_MENU)
			
		InputTypes.MULTIPLAYER_PLAYER_NAME_BUTTON: 
			_handle_UI_state(UIStates.MULTIPLAYER_PLAYER_NAME_INPUT)
			
		InputTypes.MULTIPLAYER_OPTIONS_BUTTON:
			_handle_UI_state(UIStates.MULTIPLAYER_OPTIONS)
		
		InputTypes.MULTIPLAYER_HOST_BUTTON: 
			_handle_UI_state(UIStates.MULTIPLAYER_HOST)
			

## Handles what to do when the game state changes. [br]
## This is done mainly through changing/updating UI menus.
func _on_game_state_change(new_game_state: GameStateManager.GameStates):
	
	match new_game_state:
		
		GameStateManager.GameStates.MENU:
			_handle_UI_state(UIStates.TO_MENU)
			
		GameStateManager.GameStates.PIECE_CHOICE:
			_handle_UI_state(UIStates.COMPUTER_PIECE_CHOICE)
			
		GameStateManager.GameStates.PLAYING:
			_handle_UI_state(UIStates.PLAYING)
			
		GameStateManager.GameStates.NAUGHT:
			_handle_UI_state(UIStates.NEW_GAME_TURN, new_game_state)
			
		GameStateManager.GameStates.CROSS:
			_handle_UI_state(UIStates.NEW_GAME_TURN, new_game_state)


## Handles the UI needed for when the game ends. [br]
## Will display the end game menu and will update labels accordingly based on who won.
func _on_game_end(naughts_won: bool, crosses_won: bool):
	
	
	var end_game_menu = input_menus["ENDGAME"]
	
	if naughts_won:
		end_game_menu.labels["GameEnd"].text = "Naughts won the game!"
	elif crosses_won:
		end_game_menu.labels["GameEnd"].text = "Crosses won the game!"
	else:
		end_game_menu.labels["GameEnd"].text = "It's a draw!"
		
	_handle_UI_state(UIStates.GAME_END)
	

## Switches the current menu to a new one. [br]
## new_menu should ideally be an actual menu.
## Should only be called from _change_UI_states!
func _change_UI_menu(new_menu: Control):
	
	active_UI_node.visible = false
	active_UI_node = new_menu
	active_UI_node.visible = true


## Handles the logic for a UI state.
## opt_game_state is option parameter used in case the game state is needed for the new UI state.
func _handle_UI_state(new_UI_state: UIStates, opt_game_state = null):
	
	match new_UI_state:
		
		UIStates.REPLAY:
			input_menus["ENDGAME"].visible = false
			
		UIStates.TO_MENU:
			_reset_UI_to_default()
			_change_UI_menu(input_menus["MAIN"])
		
		UIStates.MULTIPLAYER_PLAYER_NAME_INPUT:
			_change_UI_menu(input_menus["INPUTNAME"])
			
		UIStates.MULTIPLAYER_OPTIONS:
			if _validate_input_name_lineedit():
				_change_UI_menu(input_menus["MULTIPLAYEROPTIONS"])
		
		UIStates.MULTIPLAYER_HOST:
			_change_UI_menu(input_menus["HOST"])
			
		UIStates.MULTIPLAYER_JOIN:
			_change_UI_menu(label_menus["WAITING"])
		
		UIStates.COMPUTER_PIECE_CHOICE:
			_change_UI_menu(input_menus["PIECECHOICE"])
		
		UIStates.PLAYING:
			_change_UI_menu(label_menus["PLAYING"])
			
		UIStates.NEW_GAME_TURN:
			if not opt_game_state == null:
				_update_playing_menu(opt_game_state) 
			else:
				printerr("Error! Inputted opt_game_state as null even though it's needed!")
				
		UIStates.GAME_END:
			_change_UI_menu(input_menus["ENDGAME"])
			
		

## Updates playng menu label based on the current game state.
func _update_playing_menu(new_game_state: GameStateManager.GameStates):
	
	if new_game_state == GameStateManager.GameStates.NAUGHT:
		label_menus["PLAYING"].labels["Turn"].text = "Naughts turn."
	elif new_game_state == GameStateManager.GameStates.CROSS:
		label_menus["PLAYING"].labels["Turn"].text = "Crosses turn."


## Specific function to validate input name line edit.
func _validate_input_name_lineedit() -> bool:
	
	var is_valid : bool = true
	var line_edit = input_menus["INPUTNAME"].line_edits["NAMEINPUT"]
	var line_edit_input : String = line_edit.text
	
	if line_edit_input.length() == 0:
		is_valid = false
		line_edit.placeholder_text = "Please input your 
				player name!!"
		
	return is_valid
	
	
## Connects all necessary signals needed for the script to operate. [br]
## Handles connecting, with lambdas, UI button clicks.
func _connect_signals():
	
	GlobalSignalManager.connect_global_signal(button_input, "UI_BUTTON_INPUT")
	
	GlobalSignalManager.connect_global_signal(
			input_menus["INPUTNAME"].line_edits["NAMEINPUT"].text_changed, 
			"MULTIPLAYER_PLAYER_NAME")
	
	GlobalSignalManager.game_end.connect(_on_game_end)
	
	GlobalSignalManager.player_join.connect(func(): _handle_UI_state(UIStates.MULTIPLAYER_JOIN))
	
	button_input.connect(_on_button_input)


## Recursively gets all mennus in children.
func get_all_menus(node = self) -> Array[Node]:
	
	var menus : Array[Node] = []

	for menu in node.get_children():
		
		if menu is ButtonMenuManager:
			input_menus[menu.name.to_upper()] = menu
			menu.button_press.connect(_on_raw_button_input)
			
		elif menu is LabelMenuManager:
			label_menus[menu.name.to_upper()] = menu
			
		elif menu.get_child_count() > 0:
			menus.append_array(get_all_menus(menu))

	return menus


## Processes raw button input signals from children and relays it to button_input signal. [br]
## Validations: button_name must be in name_to_input_type or an error will be produced.
func _on_raw_button_input(button_name: String):
	
	if name_to_input_type.has(button_name.to_upper()):
		button_input.emit(name_to_input_type[button_name.to_upper()])
	else:
		printerr("Error! Button not registered with name: " + button_name)
	

## Resets certain UI elements to its default value.
func _reset_UI_to_default():
	
	var player_name_line_edit = input_menus["INPUTNAME"].line_edits["NAMEINPUT"]
	
	for resetting in default_UI_data.keys():
		
		match resetting:
			
			player_name_line_edit:
				player_name_line_edit.placeholder_text = default_UI_data[player_name_line_edit]
			

## Gets all default UI values of things that need to be reset later.
func _get_default_UI_data():
	
	var player_name_line_edit = input_menus["INPUTNAME"].line_edits["NAMEINPUT"]
	
	default_UI_data = {
		player_name_line_edit: player_name_line_edit.placeholder_text
	}
	
