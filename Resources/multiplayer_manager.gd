# ---------------------------------------------------------------------------------------------- #

## Script description...
 
# ---------------------------------------------------------------------------------------------- #


extends Node
class_name MultiplayerManager




### --- Signals --- ###
																									
### ------------------------------------------------------------------------------------------ ###


signal player_join()




### --- Properties --- ###
																									
### ------------------------------------------------------------------------------------------ ###


## Address that will be connected to on join game.
const ADDRESS = "127.0.0.1"

## Port that will be hosted/connected to.
const PORT = 2121

## Represents the player in a multiplayer setting.
var peer

## Compression type used for compression globally.
const compression_type = ENetConnection.COMPRESS_RANGE_CODER

var player_name : String

var players = {}





### --- Functions --- ###
																									
### ------------------------------------------------------------------------------------------ ###


func _ready():
	
	connect_signals()


## Called on server and clients.
func peer_connected(id):
	
	print("Player Connected with id " + str(id))
	
	
## Called on server and clients.
func peer_disconnected(id):
	
	print("Player Disconnected with id " + str(id))
	
	pass
	
	
## Called only from clients.
func connected_to_server():
	
	# Sends new client's player information to the server (hence ID of 1).
	send_player_information.rpc_id(1, multiplayer.get_unique_id())
	player_join.emit()
	
	print("Connected to server!")


## Called only from clients.
func connection_failed():
	
	print("Connection failed!")


## Sets current player instance as the host peer and starts a server.
func _on_host_game():
	
	# Object that wants to host the server
	peer = ENetMultiplayerPeer.new()
	var server = peer.create_server(PORT, 2)
	
	# Checks for potential errors
	if not server == OK:
		print("Error! Cannot host: " + server)
		return
		
	# Compresses connection
	peer.get_host().compress(compression_type)

	# Sets host peer as multiplayer
	multiplayer.set_multiplayer_peer(peer)
	
	# Sends host's player information manually since connected_to_server won't be ran by it.
	send_player_information(multiplayer.get_unique_id())
	
	print("Waiting for players!")
	

## Joins a server started on ADDRESS and PORT and sets current player instance to a multiplayer 
## peer.
func _on_join_game():
	
	# Sets up player peer
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ADDRESS, PORT)
	
	# Compresses connection
	peer.get_host().compress(compression_type)
	
	# Sets the current player as the multiplayer peer
	multiplayer.set_multiplayer_peer(peer)


func _on_start_game():
	
	# Calls function to all clients
	start_multiplayer_game.rpc()


## Starts multiplayer game.
## Calls function to all peers connected to the server, including host peer.
@rpc("any_peer", "call_local")
func start_multiplayer_game():
	pass


## Called by clients to send their player information to all other clients on the server.
@rpc("any_peer")
func send_player_information(id: int):
	
	# Creates new player information data if it does not already exist.
	if not players.has(id):
		players[id] = {
			"name": player_name,
			"id": id,
		}
	
	# Passes on player information to all peer clients.
	if multiplayer.is_server():
		for player_id in players:
			send_player_information.rpc(player_id)
	

## Connects all necessary signals for the game state manager
func connect_signals():
	
	GlobalSignalManager.multiplayer_name_input.connect(func(text_input: String): player_name = text_input) 
	GlobalSignalManager.UI_button_input.connect(_on_UI_button_input)
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	


func _on_UI_button_input(input_type: UIController.InputTypes):
	
		match input_type:
			
			UIController.InputTypes.MULTIPLAYER_HOST_BUTTON:
				_on_host_game()
				
			UIController.InputTypes.MULTIPLAYER_JOIN_BUTTON:
				_on_join_game()
				
			UIController.InputTypes.MULTIPLAYER_START_BUTTON:
				_on_start_game()
	
	
	




