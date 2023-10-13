extends Area2D

var velocity = Vector2.ZERO
var damage = 0
var knockback_strength = 0
@export var speed = 400
@export var length_1 = 15
@export var length_2 = 30
@export var empty_frame = 7
@export var electricity_effect = true

func _ready():
	$AnimatedSprite2D.frame = empty_frame
	$GPUParticles2D.rotation = atan2(velocity.y, velocity.x)
	for x in range(1, length_1):
		$Line2D.add_point(global_position)
	$Line2D2.add_point(global_position)


func _process(delta):
	global_position -= velocity*delta*speed
	$Line2D.global_position = Vector2.ZERO
	if $Line2D.get_point_count() == 0:
		return
	if global_position.distance_to($Line2D.points[$Line2D.get_point_count() - 1]) > 5:
		var offset = Vector2(
			randi_range(-2, 2),
			randi_range(-2, 2)
		)
		if not electricity_effect:
			offset = Vector2.ZERO
		$Line2D.add_point(global_position+offset)
		if $Line2D.get_point_count() > length_1 or velocity == Vector2.ZERO:
			$Line2D.remove_point(0)
	$Line2D2.global_position = Vector2.ZERO
	if global_position.distance_to($Line2D2.points[$Line2D2.get_point_count() - 1]) > 3:
		var offset = Vector2(
			randi_range(-3, 3),
			randi_range(-3, 3)
		)
		$Line2D2.add_point(global_position+offset)
	if $Line2D2.get_point_count() > length_2:
		$Line2D2.remove_point(0)


func _on_timer_timeout():
	velocity = Vector2.ZERO
	$GPUParticles2D.emitting = false
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("default")
	$CollisionShape2D.set_deferred("disabled", true)


func _on_area_entered(area):
	global_position = (area.global_position + global_position)/2
	
	velocity = Vector2.ZERO
	$GPUParticles2D.emitting = false
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("default")
	$CollisionShape2D.set_deferred("disabled", true)


func _on_animated_sprite_2d_animation_finished():
	queue_free()


func _on_body_entered(_body):
	_on_area_entered(self)


func _on_area_2d_body_entered(body):
	_on_area_entered(self)
