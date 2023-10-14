extends Area2D

var velocity = Vector2.ZERO
var damage = 0
var knockback_strength = 0

func _ready():
	Global.shake_camera()
	#$AnimatedSprite2D.frame = 0


func _process(delta):
	rotation += delta*10
	global_position -= velocity*delta*100


func _on_timer_timeout():
	velocity = Vector2.ZERO
	$Sprite2D.visible = false
	#$GPUParticles2D2.emitting = true
	#$AnimatedSprite2D.play("default")
	$GPUParticles2D.emitting = false
	$CollisionShape2D.set_deferred("disabled", true)
	Global.screen_shake_size = 1
	Global.shake_camera()


func _on_area_entered(_area):
	velocity = Vector2.ZERO
	$Sprite2D.visible = false
	#$GPUParticles2D2.emitting = true
	#$AnimatedSprite2D.play("default")
	$GPUParticles2D.emitting = false
	$CollisionShape2D.set_deferred("disabled", true)
	Global.screen_shake_size = 1
	Global.shake_camera()


func _on_animated_sprite_2d_animation_finished():
	queue_free()
