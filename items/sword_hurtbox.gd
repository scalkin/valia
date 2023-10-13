extends Area2D

var points = []
var type = BASIC
var damage = 0
var knockback_strength = 0

enum {
	BASIC,
	SPIN
}

func _ready():
	match type:
		BASIC:
			$CollisionPolygon2D.polygon = [
				points[0],
				points[1],
				points[3],
				points[5],
				points[4]
			]
		SPIN:
			$CollisionPolygon2D.polygon = [
				points[0],
				points[1],
				points[3],
				points[2],
			]


func _on_timer_timeout():
	queue_free()
