
# ---------------------------------------------------------------------------------------------- #

## Can only be used for control nodes.
## Gets all input nodes (i.e. buttons) on a control node and connects all presses.
 
# ---------------------------------------------------------------------------------------------- #


extends "res://Resources/UI/label_menu_manager.gd"
class_name ButtonMenuManager




## Emitted on any button click.
signal button_press(button_name: String)	

## Holds all buttons in node.
var buttons : Array[Button]

## Stores all line edits. [br]
## Key: 'line edit name', Value 'line edit node'
var line_edits : Dictionary


	

### --- Functions --- ###
																									
### ------------------------------------------------------------------------------------------ ###


## Gets all buttons and connects them accordingly.
func _ready():
	
	_check_all_children()
		

## Recursively gets all the buttons and lineedits in the children.
## Sets buttons and line_edits variables
func _check_all_children(node = self):

		for N in node.get_children():

			if N.is_class("Button"):
				buttons.append(N)
				N.pressed.connect(func(): button_press.emit(N.name))
				
			elif N.is_class("LineEdit"):
				line_edits[N.name.to_upper()] = N

			if N.get_child_count() > 0:
				_check_all_children(N)
