extends Area2D

var damage = 0
var knockback_strength = 0
var length = 10.0
@export var x = 0.0

func _ready():
	$"Draw Lightning".play("lightning")
	$Shrink.play("shrink")
	$Line2D.add_point(Vector2(x, -4))

func _on_timer_timeout():
	queue_free()

func add_point_animation():
	$CollisionShape2D.position.x = x
	var point = Vector2(x, -4)
	point += Vector2(
		randi_range(-5, 5),
		randi_range(-5, 5)
	)
	$Line2D.add_point(point)

func _on_draw_lightning_animation_finished(_anim_name):
	$CollisionShape2D/GPUParticles2D2.emitting = false


func _on_area_2d_body_entered(_body):
	$CollisionShape2D.set_deferred("disabled", true)
