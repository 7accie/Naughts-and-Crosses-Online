extends Node

@onready var labels : Dictionary = get_all_labels(self)


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
