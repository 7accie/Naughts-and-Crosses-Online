
# ---------------------------------------------------------------------------------------------- #

## Can only be used for control nodes.
## Gets all buttons on a control node and connects all presses.
 
# ---------------------------------------------------------------------------------------------- #


extends "res://Resources/UI/label_menu_manager.gd"
class_name ButtonMenuManager




## Emitted on any button click.
signal button_pressed(button_name: String)	

## Holds all buttons in node.
var buttons : Array[Button]




### --- Functions --- ###
																									
### ------------------------------------------------------------------------------------------ ###


## Gets all buttons and connects them accordingly.
func _ready():
	
	buttons = get_all_buttons(self)
	
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button.name))
		

## Recursively gets all the buttons in the children and returns an array of them.
func get_all_buttons(node) -> Array[Button]:
	
	var nodes : Array[Button] = []

	for N in node.get_children():

		if N.get_child_count() > 0:
			
			if N.is_class("Button"):
				nodes.append(N)

			nodes.append_array(get_all_buttons(N))

		else:
			if N.is_class("Button"):
				nodes.append(N)

	return nodes


## Sends out button_pressed signal.
func _on_button_pressed(button_name: String):
	button_pressed.emit(button_name)
