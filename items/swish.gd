extends Line2D

var time = 0.2

func _ready():
	$Timer.start(time)

func _on_timer_timeout():
	if points:
		remove_point(0)
		$Timer.start(0.005)
	else:
		queue_free()
