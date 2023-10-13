extends Area2D

@onready var iframe_timer = $"IFrame Timer"

signal knockback(vector : Vector2, strength: float)

func _on_area_entered(area):
	if iframe_timer.time_left:
		return
	iframe_timer.start()
	
	emit_signal("knockback", position.direction_to(area.position).normalized(), area.knockback_strength)

func _process(_delta):
	monitoring = not iframe_timer.time_left
