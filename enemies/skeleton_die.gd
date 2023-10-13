extends AnimatedSprite2D

func _ready():
	play()

func _on_animation_finished():
	$Timer.start()

func _on_timer_timeout():
	queue_free()
