extends Node


@export var camera_not_playing_path := NodePath()
@onready var camera_not_playing : Camera3D = get_node(camera_not_playing_path)
@export var camera_playing_path := NodePath()
@onready var camera_playing : Camera3D = get_node(camera_playing_path)


enum CameraStates {PLAYING, NOT_PLAYING}
var transition_duration : float = 0.2
var current_game_state



func _on_game_state_changed(new_game_state : GameStateManager.GameStates):
	
	if current_game_state == new_game_state:
		return
	
	match new_game_state:
		
		GameStateManager.GameStates.PLAYING:
			CameraTransitioner.transition_camera(camera_not_playing, camera_playing, transition_duration)
			
		GameStateManager.GameStates.END_GAME:
			CameraTransitioner.transition_camera(camera_playing,camera_not_playing, transition_duration)
		
	current_game_state = new_game_state
