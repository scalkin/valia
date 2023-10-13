extends Label

var direction = Vector2.ZERO


func _ready():
	direction = Vector2.UP
	direction.x = randf_range(-1, 1)


func _process(delta):
	global_position += direction*delta*50


func _on_timer_timeout():
	queue_free()
