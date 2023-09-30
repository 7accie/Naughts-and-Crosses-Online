
# ---------------------------------------------------------------------------------------------- #

## Used to evenly space out UI elements, excluding spacers.
## Automatically resizes when any child size changes. [br]
## Can only be used on control nodes!!
 
# ---------------------------------------------------------------------------------------------- #


extends Node
class_name ControlChildrenEvenResizer




### --- Properties --- ###
																									
### ------------------------------------------------------------------------------------------ ###


## Holds all children control nodes/
@onready var children_nodes  = get_children()

## Used to check if a resizing has already occurred. [br]
## To disable other false resize signals whilst even resizing is happening.
var is_resizing = false

## Used to count the number of false resize signals left whilst an even resizing is happening.
var false_signal_counter = 0




### --- Functions --- ###
																									
### ------------------------------------------------------------------------------------------ ###


## Connects all children resized signals so they activate the resize method, resizes all children 
## once and sets children count.
func _ready():
	
	for child in children_nodes:
		child.resized.connect(_on_children_size_change)


# Handles what to do when a child is changed and ensures all children are only resized once.
func _on_children_size_change():
	
	if is_resizing == false:
		is_resizing = true
		_resize_children_evenly()
		false_signal_counter = children_nodes.size()
	
	if false_signal_counter > 0:
		false_signal_counter -= 1
		
	if false_signal_counter == 0:
		is_resizing = false
			

## Resizes all children evenly based on the child with the largest needed size and scale ratios.
func _resize_children_evenly():
	
		# Max size of children, accounting for the stretch ratio
	var max_size : Vector2 = Vector2.ZERO
	
	# For each child, gets max size and applies it to the rest of children
	# Accounts for each stretch ratio
	for child in children_nodes:
		if child.is_class("Control"):
			
			var child_size = child.size / child.size_flags_stretch_ratio

			if child_size.x > max_size.x:
				max_size.x = child.size.x
			if child_size.y > max_size.y:
				max_size.y = child.size.y
		else:
			print("Child isn't control node!")
	
	for child in children_nodes:
		if child.is_class("Control") and not "Spacer" in child.name:
			child.custom_minimum_size = max_size * child.size_flags_stretch_ratio
