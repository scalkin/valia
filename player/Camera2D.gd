extends Camera2D

var camera_mode = false
var zoom_0 = 1

@export var zoom_curve: Curve

func _process(delta):
	if Input.is_action_just_pressed("camera_mode_toggle"):
		camera_mode = not camera_mode
		get_tree().paused = camera_mode
		get_parent().visible = not camera_mode
	
	if Input.is_action_just_pressed("camera_reset"):
		camera_mode = false
		get_tree().paused = false
		get_parent().visible = true
		offset = Vector2.ZERO
		zoom = Vector2.ONE
	
	if not camera_mode:
		return
	
	var zoom_input = Input.get_axis("zoom_out", "zoom_in")
	
	zoom_0 = clamp(zoom_0 + zoom_input*delta, 0.0, 1.0)
	
	offset += Input.get_vector("left", "right", "up", "down")*delta*(1.2 - zoom_0)*500
	
	zoom = Vector2(
		zoom_curve.sample(zoom_0),
		zoom_curve.sample(zoom_0)
	)
