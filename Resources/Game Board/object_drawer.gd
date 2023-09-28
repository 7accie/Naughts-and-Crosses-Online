extends Node
class_name ObjectDrawer

@onready var naught_scene : Resource = load("res://Resources/Game Board/naught.tscn")
@onready var cross_scene : Resource = load("res://Resources/Game Board/cross.tscn")


# Creates a specified game piece at a certain position
func create_game_piece(game_piece_type:GameBoardManager.GamePieces, position:Vector3):
	
	# Validation
	# Checks if game_piece_type isn't empty as cannot place empty game piece!
	if game_piece_type == GameBoardManager.GamePieces.EMPTY:
		print("Error! Cannot create an empty game piece")
		return
	
	# Gets scene path of the object to make
	var obj_scene 
	if game_piece_type == GameBoardManager.GamePieces.NAUGHT:
		obj_scene = naught_scene
	elif game_piece_type == GameBoardManager.GamePieces.CROSS:
		obj_scene = cross_scene
	
	# Creates object and offsets it so it sits on top of input position
	var new_obj : Node3D = obj_scene.instantiate()	
	add_child(new_obj)
	position.y += 0.1
	new_obj.position = position
	
	return new_obj
	


