extends Area2D

func _ready():
	$AnimationPlayer.play("appear")
	$GPUParticles2D.emitting = true

func _on_timer_timeout():
	$AnimationPlayer.play("disappear")
