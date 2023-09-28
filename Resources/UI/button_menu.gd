# Can only be used for control nodes!!
# Gets all buttons on a control node and connects all presses


extends "res://Resources/UI/label_menu.gd"
class_name ButtonMenu

var buttons : Array[Button]
signal button_pressed(button: String)	

func _ready():
	
	buttons = get_all_buttons(self)
	
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button.name))
		


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


func _on_button_pressed(button_name: String):
	button_pressed.emit(button_name)


