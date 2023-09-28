# Used for transitioning two cameras globally


extends Camera3D


@onready var camera : Camera3D = get_node(".")
@onready var tween : Tween 
var is_transitioning = false


# Transitions smoothly from one camera to another camera
func transition_camera(from: Camera3D, to: Camera3D, duration: float = 1.0):
	
	# Checks if the current camera is trying to be transitioned to
	if camera.get_viewport().get_camera_3d() == to:
		print("Error! Can't transition to the same camera!")
		return
	
	# Checks if there is an ongoing transition already
	if is_transitioning:
		print("Error! A camera transition is already ongoing.")
		return
	
	# Creates the tween used for smooth motion
	tween = camera.create_tween()
	
	# Ensure the proprties are the same in the first camera
	camera.fov = from.fov
	camera.cull_mask = from.cull_mask
	camera.global_transform = from.global_transform
	camera.current = true
	
	is_transitioning = true
	
	# Use tweens to smoothly transition to second camera
	tween.tween_property(camera, "global_transform", to.global_transform, duration)
	tween.tween_property(camera, "fov", to.fov, duration)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.play()
	
	# Wait for tween to complete
	await tween.finished
	
	# Make second camera current
	to.current = true
	is_transitioning = false
	tween.kill()
	
