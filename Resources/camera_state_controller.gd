
# ---------------------------------------------------------------------------------------------- #

## Manages different camera positions and how they are switched based on game state.
 
# ---------------------------------------------------------------------------------------------- #


extends Node
class_name CameraStateController




### --- Properties --- ###
																									
### ------------------------------------------------------------------------------------------ ###


# References
@export var camera_not_playing : Camera3D
@export var camera_playing : Camera3D


## Stores all possible states the camera could be in.
enum CameraStates {PLAYING, NOT_PLAYING}


## Stores the duration of each transition in seconds.
var transition_duration : float = 0.2

## Used to store the current camera state
var current_game_state




### --- Functions --- ###
																									
### ------------------------------------------------------------------------------------------ ###



## Changes camera state based on the current game state
func _on_game_state_changed(new_game_state : GameStateManager.GameStates):
	
	if current_game_state == new_game_state:
		return
	
	match new_game_state:
		
		GameStateManager.GameStates.PLAYING:
			CameraTransitioner.transition_camera(camera_not_playing, camera_playing, transition_duration)
			
		GameStateManager.GameStates.END_GAME:
			CameraTransitioner.transition_camera(camera_playing,camera_not_playing, transition_duration)
		
	current_game_state = new_game_state
