# Manages game pieces on the game board
# Allows for adding, removal and analysis of game pieces on the game board

 

extends Node
class_name GameBoardManager



# References
@export var game_state_manager : Node
@export var object_drawer : Node
@export var board_mesh : Node



# Signals
signal game_board_click(position : Vector3)



# Data
enum GamePieces {EMPTY, NAUGHT, CROSS}
const GRID_SIZE = 3
var cell_size : Vector2 # Vector from centre of cell to the bottom right of the cell
var board_positions = [] # Contains all possible positions of game piecs, doesn't change
var board_bounds : Rect2

# Data that needs to be reset
var board_data = [] # Contains all game piece type positions
var board_pieces = {} # Contains physical game piece object positions



# Signal functions	
		
	
func _ready():
	_connect_signals()
	_initialise_game_board()


func _on_game_state_change(new_game_state):
	
	match new_game_state:			
			
		game_state_manager.GameStates.RESET:
			_reset_board()
	

		
	
	

# 'Private' functions

# Gets all board positions and fills in board data to be empty
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
	
	
# Returns 4d vector, first 2 positions being the rounded positon, the last 2 positions being the index of the position
func _get_rounded_piece_position(position_3D):
	
	# Converts input Vector3 to Vector2 for the 2D bounds used for each grid cell on the game board
	var position_2D = Vector2(position_3D.x, position_3D.z)
	
	# Checks if input position is outside the game board bounds which would cause an error
	if not board_bounds.has_point(position_2D):
		print("Error! Position inputted outside bounds!")
		return
	
	# Goes through each grid cell and creates a bound to check if the position is contained within it
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE): 
			var cell_bounds = Rect2(board_positions[x][y] - cell_size, cell_size * 2)	
			if cell_bounds.has_point(position_2D):
				return Vector4(board_positions[x][y].x, board_positions[x][y].y, x, y)
	
	# If nothing is found then something must be wrong...
	print("Error! Position not found?")
	return


# Connects all signals required for the script
func _connect_signals():
	# Connects to input manager
	GlobalSignalManager.connect_global_signal(board_mesh.get_node("StaticBody3D").input_event, GlobalSignalManager.SignalType.GAME_BOARD_INPUT)

	
# Checks if a specific game piece has won or not
func _has_game_piece_won(game_piece : GamePieces):
	
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
		if _find_matching_line(game_piece, current_position, Vector2i.RIGHT):
			return true
		current_position.y += 1
	
	current_position = Vector2i.ZERO
	
	# Check vertical matches
	for i in range(GRID_SIZE):
		#print("Checking column %s" % (i+1))
		if _find_matching_line(game_piece, current_position, Vector2i.DOWN):
			return true
		current_position.x += 1
	
	current_position = Vector2i.ZERO
	
	# Check for diagonal matches
	var diagonal1 = _find_matching_line(game_piece, current_position, Vector2i(1,1))
	var diagonal2 = _find_matching_line(game_piece, Vector2i(0, GRID_SIZE-1), Vector2i(1,-1))
	
	if diagonal1 or diagonal2:
		return true
	
	return false

 
# Finds a matching line on the grid in  a specific direction, to see if that piece has won
func _find_matching_line(game_piece, starting_position, line_direction):
	
	# Validation
	if game_piece == GamePieces.EMPTY:
		print("Error? Cannot input empty game piece!")
		return false
	elif starting_position.x >= GRID_SIZE or starting_position.x < 0 or starting_position.y >= GRID_SIZE or starting_position.y < 0:
		print("Erorr? Invalid starting position!")
		return false
	
	var current_position = starting_position
	
	for i in range(GRID_SIZE-1):
		var next_position = current_position + line_direction
		var positions_match = board_data[current_position.x][current_position.y] == board_data[next_position.x][next_position.y]
		var position_matches_piece = game_piece == board_data[next_position.x][next_position.y]
		
		#print("%s (at position %s) == %s (at position %s) is %s" % [board_data[current_position.x][current_position.y], current_position, board_data[next_position.x][next_position.y], next_position, positions_match])
		#print("Matching game piece: %s" % position_matches_piece) 
		
		if not (positions_match and position_matches_piece):
			#print("Current column therefore does not contain match")
			return false
		current_position = next_position
		
	#print("Therefore match has been found!")
	return true


# Resets all data that needs to be reset
func _reset_board():
	
	# Clears each array in board_data 2d array
	for i in range(GRID_SIZE):
		board_data[i].fill(GamePieces.EMPTY)
	
	# Gets an array copy of the board mesh pieces dictionary and deletes them all
	var board_pieces_clearing = board_pieces.values()
	for i in range(board_pieces_clearing.size()-1 , -1, -1):
		board_pieces_clearing[i].queue_free() 
	
	board_pieces.clear()




# 'Public' functions

# Adds a new game piece as a specified position
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
	
	return true


# Adds a random new game piece for the computer opponent
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


# Returns whether it's a draw or not
func has_game_drew():
	return board_pieces.size() >= GRID_SIZE ** 2


# Returns whether naughts has won or not
func has_naughts_won():
	return _has_game_piece_won(GamePieces.NAUGHT)
	
	
# Returns whether crosses has won or not
func has_crosses_won():
	return _has_game_piece_won(GamePieces.CROSS)
