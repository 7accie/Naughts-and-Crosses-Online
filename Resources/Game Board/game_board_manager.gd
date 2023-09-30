 
# ---------------------------------------------------------------------------------------------- #

## Manages game pieces on the game board
## Allows for adding, removal and analysis of game pieces on the game board
 
# ---------------------------------------------------------------------------------------------- #


extends Node
class_name GameBoardManager




### --- Signals --- ###
																									
### ------------------------------------------------------------------------------------------ ###




signal game_board_click(position : Vector3)
signal game_end(naughts_won: bool, crosses_won: bool)




### --- Properties --- ###
																									
### ------------------------------------------------------------------------------------------ ###


@export var game_state_manager : Node
@export var object_drawer : Node
@export var board_mesh : Node


## Holds all possible game pieces that may be on the game board.
enum GamePieces {EMPTY, NAUGHT, CROSS}

## Constant for size of grid. [br]
## Not a good idea to change this from 3 though.
const GRID_SIZE = 3

## Stores a vector translation from the centre of each grid cell to the bottom right of that cell. [br]
var cell_size : Vector2

## Stores global positions in space of the grid cells. [br]
## Does not change after it has been set!
var board_positions = []

## Stores the bounds for the entire game grid.
var board_bounds : Rect2

## Stores the game piece types in a 2d array. [br]
## Stores GamePieces enum in each element. [br]
## Each position in the array corresponds to board_positions.
## Non-persistant data that is reset to its origianl state.
var board_data = Array(Array())

## Stores game piece meshes. [br]
## Key: Global position [br]
## Value: Mesh
## Non-persistant data that is reset to its origianl state.
var board_pieces = {}




### --- Functions --- ###
																									
### ------------------------------------------------------------------------------------------ ###


## Initialises board and connects relevant signals.
func _ready():
	_connect_signals()
	_initialise_game_board()


## Handles what's done on each game state. [br]
## Just deals with board resetting.
func _on_game_state_change(new_game_state):
	
	match new_game_state:			
			
		game_state_manager.GameStates.RESET:
			_reset_board()


## Sets up game board and all it's relevant properties. [br]
## Sets board_bounds, board_positions, board_data and cell_size based on GRID_SIZE
func _initialise_game_board():
	
	# Gets important data about the board
	var board_dimensions : Vector2 = Vector2(board_mesh.scale.x, board_mesh.scale.z)
	var current_position : Vector2 = Vector2(board_mesh.position.x, board_mesh.position.z) - (board_dimensions / 3)
	board_bounds = Rect2(Vector2(board_mesh.position.x, board_mesh.position.z) - Vector2(board_mesh.scale.x, board_mesh.scale.z) / 2, Vector2(board_mesh.scale.x, board_mesh.scale.z))
	cell_size = Vector2(board_mesh.position.x, board_mesh.position.y) + (Vector2(board_dimensions.x, board_dimensions.y) * (1.0/6.0) )
	
	# Iterates to get each position in the game board grid, starting with top left 
	# Builds up arrays storing important data
	for x in range(GRID_SIZE):
		board_positions.append([])
		board_data.append([])
		var position_to_add : Vector2 = Vector2.ZERO
		for y in range(GRID_SIZE):
			board_positions[x].append(current_position + position_to_add)
			board_data[x].append(GamePieces.EMPTY)
			position_to_add.y += board_dimensions.y / 3
		current_position.x += board_dimensions.x / 3


## Converts a global position to the a specific 2d position of a grid cell on the board. [br]
## Also returns the array positions of the grid cell. [br]
## In vector4, first 2 values represent grid cell position, last 2 values represent array 
## position. [br] 
## Validation: returns an empty vector4 if input is not within the game grid
func _get_rounded_piece_position(position_3D) -> Vector4:
	
	# Converts input Vector3 to Vector2 for the 2D bounds used for each grid cell on the game board
	var position_2D = Vector2(position_3D.x, position_3D.z)#
	var output_vector = Vector4()
	
	# Checks if input position is outside the game board bounds which would cause an error
	if not board_bounds.has_point(position_2D):
		print("Error! Position inputted outside bounds!")
		return output_vector
	
	# Goes through each grid cell and creates a bound to check if the position is contained within it
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE): 
			var cell_bounds = Rect2(board_positions[x][y] - cell_size, cell_size * 2)	
			if cell_bounds.has_point(position_2D):
				output_vector = Vector4(board_positions[x][y].x, board_positions[x][y].y, x, y)
				return output_vector
	
	# If nothing is found then something must be wrong...
	print("Error! Position not found?")
	return output_vector


## Connects all required signals for the script.
func _connect_signals():
	
	GlobalSignalManager.connect_global_signal(board_mesh.get_node("StaticBody3D").input_event, "GAME_BOARD_INPUT")
	GlobalSignalManager.connect_global_signal(game_end, "GAME_END")
	
## Checks if a specific game piece has won or not. [br]
## Validation: GamePiece.EMPTY cannot be inputted and will return false
func _has_game_piece_won(game_piece : GamePieces) -> bool:
	
	# Validation
	if game_piece == GamePieces.EMPTY:
		print("Error. Cannot input empty!")
		return false
	
	
	
	var current_position = Vector2i.ZERO
	
	# If there aren't enough pieces placed, it's guaranteed to not have won
	if board_pieces.size() < GRID_SIZE  * 2 - 1:
		return false
	
	# Check for horizontal matches 
	for i in range(GRID_SIZE):
		if _is_matching_line(game_piece, current_position, Vector2i.RIGHT):
			return true
		current_position.y += 1
	
	current_position = Vector2i.ZERO
	
	# Check vertical matches
	for i in range(GRID_SIZE):
		#print("Checking column %s" % (i+1))
		if _is_matching_line(game_piece, current_position, Vector2i.DOWN):
			return true
		current_position.x += 1
	
	current_position = Vector2i.ZERO
	
	# Check for diagonal matches
	var diagonal1 = _is_matching_line(game_piece, current_position, Vector2i(1,1))
	var diagonal2 = _is_matching_line(game_piece, Vector2i(0, GRID_SIZE-1), Vector2i(1,-1))
	
	if diagonal1 or diagonal2:
		return true
	
	return false

 
## Finds a matching line on the grid in  a specific direction, to see if that piece has won.
## Validation: [br]
## ~ GamePiece.EMPTY cannot be inputted and will return false [br]
## ~ Starting position must be the array position [br]
## ~ Line_direction must have a magnitude of 1 in only 1 2d direction
func _is_matching_line(game_piece : GamePieces, starting_position : Vector2, line_direction : Vector2) -> bool:
	
	# Validation
	if game_piece == GamePieces.EMPTY:
		print("Error? Cannot input empty game piece!")
		return false
	elif starting_position.x >= GRID_SIZE or starting_position.x < 0 or starting_position.y >= GRID_SIZE or starting_position.y < 0:
		print("Erorr? Invalid starting position!")
		return false
	elif not (line_direction.x == 1 or line_direction.x == 0 
		and line_direction.y == 1 or line_direction.x == 0):
		print("Erorr? Invalid line direction vector! Must have a magnitude of 1.")
		return false
	
	var current_position = starting_position
	
	for i in range(GRID_SIZE-1):
		
		var next_position = current_position + line_direction
		var current_game_piece = board_data[current_position.x][current_position.y]
		var next_game_piece = board_data[next_position.x][next_position.y]
		var positions_match = current_game_piece == next_game_piece
		var position_matches_piece = game_piece == current_game_piece
		
		if not (positions_match and position_matches_piece):
			return false
			
		current_position = next_position
		
	return true


## Resets all data that needs to be reset.
## Sets all non-persistent properties to it's original state
func _reset_board():
	
	# Clears each array in board_data 2d array
	for i in range(GRID_SIZE):
		board_data[i].fill(GamePieces.EMPTY)
	
	# Gets an array copy of the board mesh pieces dictionary and deletes them all
	var board_pieces_clearing = board_pieces.values()
	for i in range(board_pieces_clearing.size()-1 , -1, -1):
		board_pieces_clearing[i].queue_free() 
	
	board_pieces.clear()


## Adds a new game piece mesh and data at a specified position.
func add_piece(piece_type:GamePieces, position_3D:Vector3):
	
	# Checks if an empty game piece is inputted for some reason
	if piece_type == GamePieces.EMPTY:
		print("Error! Cannot place an empty piece.")
		return
	
	var piece_position_data = _get_rounded_piece_position(position_3D)
	var position_2D = Vector2(piece_position_data.x, piece_position_data.y)
		
	# Checks if board piece is already added with the input position
	if board_pieces.get(position_2D):
		return false
	
	# Gets new piece data	
	var new_board_piece_position = Vector3(position_2D.x, board_mesh.position.y + (board_mesh.scale.y / 2), position_2D.y)
	board_pieces[position_2D] = object_drawer.create_game_piece(piece_type, new_board_piece_position)
	board_data[piece_position_data.z][piece_position_data.w] = piece_type
	
	# Checks if the game has ended
	handle_game_ended()
	
	return true


## Adds a random new game piece mesh and data at a specified position.
func add_random_piece(piece_type:GamePieces):

	# Checks if an empty game piece is inputted for some reason
	if piece_type == GamePieces.EMPTY:
		print("Error! Cannot place an empty piece.")
		return
	
	var empty_positions = []

	# Iterates over game grid to add empty positions
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			if board_data[x][y] == GamePieces.EMPTY:
				empty_positions.append(board_positions[x][y])
	
	# Gets random empty position
	var random_piece_position = empty_positions[randi_range(0, empty_positions.size()-1)]
	
	add_piece(piece_type, Vector3(random_piece_position.x, 0, random_piece_position.y))
	return _has_game_piece_won(GamePieces.CROSS)


func handle_game_ended():
	
	var naughts_won = false
	var crosses_won = false
	
	if _has_game_piece_won(GamePieces.NAUGHT):
		naughts_won = true
		
	elif _has_game_piece_won(GamePieces.CROSS):
		crosses_won = true
		
	elif board_pieces.size() < GRID_SIZE ** 2:
		# Game has not ended as neitehr naughts or crosses has won and the game hasn't drawn.
		return
	
	# Game has definitely ended
	game_end.emit(naughts_won, crosses_won)
