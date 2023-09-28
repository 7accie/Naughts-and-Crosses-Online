# Manages UI and connects it to the rest of the game
# Allows UI to react and cause reactions in other parts of the game



extends Node



signal button_press(signal_type: GlobalSignalManager.SignalType)



var button_menus : Dictionary
var label_menus : Dictionary
var active_UI_node : Control


func _ready():
	
	_load_menus()
	_connect_signals()	
	active_UI_node = button_menus["MAIN"]
	

# Called on button press
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


# Called on game state changed
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
			
		GameStateManager.GameStates.END_GAME:
			_change_UI_menu(button_menus["ENDGAME"])
		

# Called when a game ends, displays end game menu with text of who won
func _on_game_end(naughts_won, crosses_won):
	
	var end_game_menu = button_menus["ENDGAME"]
		
	_change_UI_menu(end_game_menu)
	
	if naughts_won:
		end_game_menu.labels["GameEnd"].text = "Naughts won the game!"
	elif crosses_won:
		end_game_menu.labels["GameEnd"].text = "Crosses won the game!"
	else:
		end_game_menu.labels["GameEnd"].text = "It's a draw!"
	
	
# Switches current menu with a new menu
func _change_UI_menu(new_node : Control):
	
	active_UI_node.visible = false
	active_UI_node = new_node
	active_UI_node.visible = true
	

# Updates playing menu text
func _update_playing_menu(new_game_state: GameStateManager.GameStates):
	
	if new_game_state == GameStateManager.GameStates.NAUGHT:
		label_menus["PLAYING"].labels["Turn"].text = "Naughts turn."
	elif new_game_state == GameStateManager.GameStates.CROSS:
		label_menus["PLAYING"].labels["Turn"].text = "Crosses turn."
	
	
# Connects all needed signals for the script
func _connect_signals():
	
	GlobalSignalManager.connect_ui_buttons(button_press)
	GlobalSignalManager.UI_button_click.connect(func(signal_type: GlobalSignalManager.SignalType): if signal_type == GlobalSignalManager.SignalType.REPLAY: button_menus["ENDGAME"].visible = false)
	GlobalSignalManager.UI_button_click.connect(func(signal_type: GlobalSignalManager.SignalType): if signal_type == GlobalSignalManager.SignalType.MENU: _change_UI_menu(button_menus["MAIN"]))
	

# Gets all menus and loads them into variables
func _load_menus():
	
		var menus = get_children()
	
		for menu in menus:
			if menu is ButtonMenu:
				button_menus[menu.name.to_upper()] = menu
				menu.button_pressed.connect(_on_button_press)
			else:
				label_menus[menu.name.to_upper()] = menu
	
	
