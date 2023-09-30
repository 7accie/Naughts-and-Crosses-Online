
# ---------------------------------------------------------------------------------------------- #

## Gets all label child nodes and stores them in an accesible Dicitonary. [br]
## Can only be used on control nodes!
 
# ---------------------------------------------------------------------------------------------- #


extends Node
class_name LabelMenuManager



## Holds all child labels in a dictionary. [br]
## Key: label name, Value: label node
@onready var labels : Dictionary = get_all_labels(self)



## Recursively gets a dictionary with all labels in the parent node.
func get_all_labels(node) -> Dictionary:
	
	var nodes : Dictionary = {}

	for N in node.get_children():

		if N.get_child_count() > 0:
			
			if N.is_class("Label"):
				nodes[N.name] = N

			nodes.merge(get_all_labels(N))

		else:
			if N.is_class("Label"):
				nodes[N.name] = N

	return nodes
