extends CharacterBody2D

var player = null
var damage = 0

func _ready():
	pass


func _process(delta):
	if player != null:
		velocity = velocity.move_toward(global_position.direction_to(player.global_position)*1000/(global_position.distance_to(player.global_position)*25), delta*50)
	else:
		velocity = Vector2.ZERO
	move_and_slide()


func _on_player_nearby_body_entered(body):
	player = body


func _on_touching_player_body_entered(body):
	Global.player_health += 5
	queue_free()


func _on_player_nearby_body_exited(body):
	player = null
