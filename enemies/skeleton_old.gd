extends CharacterBody2D

@onready var nav_agent = $NavigationAgent2D
@onready var idle_timer = $"Idle Timer"
@onready var sideways = $Node2D
@onready var sideways_target = $Node2D/Node2D
@onready var dagger = $Shoulder/Dagger
@onready var shoulder = $Shoulder
@onready var attack_animation = $Attack
@onready var hurtbox = $Shoulder/Dagger/Hurtbox
@onready var flash_timer = $"Flash Timer"

enum{
	IDLE,
	CHASE
}

@export var shoulder_rotation_augment = 0.0
@export var dagger_x_augment = 0.0

var speed = 20
var spawn_point: Vector2
var state = IDLE
var first_frame = true
var last_velocity = Vector2.ZERO
var player = null
var health = 50:
	set(value):
		health = value
		if health <= 0:
			queue_free()

func _ready():
	hurtbox.damage = 15

func _physics_process(delta):
	if first_frame:
		spawn_point = global_position
		first_frame = false
		nav_agent.target_position = spawn_point + Vector2(
				randi_range(-50, 50),
				randi_range(-50, 50))
		return
	
	print(bool(flash_timer.time_left))
	$Sprite2D.material.set("shader_parameter/flash", bool(flash_timer.time_left))
	
	dagger.position.x = ((abs(cos(get_parent().rotation)*2)*-2)-3)+dagger_x_augment
	
	if state == IDLE or global_position.distance_to(player.global_position) > 25:
		shoulder.rotation = atan2(last_velocity.y, last_velocity.x)
	elif global_position.distance_to(player.global_position) < 25:
		var direction = shoulder.global_position.direction_to(player.global_position)
		shoulder.rotation = atan2(direction.y, direction.x)
	
	if state == CHASE:
		var direction = global_position.direction_to(player.global_position)
		sideways.rotation = atan2(direction.y, direction.x)
	
	var target = to_local(nav_agent.get_next_path_position())
	velocity = velocity.move_toward(target.normalized()*speed, delta*500)
	move_and_slide()
	$Icon.position = target
	if velocity:
		last_velocity = velocity
		$Sprite2D.flip_h = velocity.x < 0
		if velocity.y < -0.25:
			$AnimationPlayer.play("walk_up")
		else:
			$AnimationPlayer.play("walk")
	else:
		if last_velocity.y < -0.25:
			$AnimationPlayer.play("idle_up")
		else:
			$AnimationPlayer.play("idle")

func make_path():
	match state:
		CHASE:
			if global_position.distance_to(player.global_position) < 15 and nav_agent.target_position.distance_to(player.global_position) < 10:
				nav_agent.target_position = sideways_target.global_position
				return
			nav_agent.target_position = player.global_position
		IDLE:
			if nav_agent.distance_to_target() > 15 or idle_timer.time_left:
				return
			match randi() % 2:
				0:
					nav_agent.target_position = spawn_point + Vector2(
					randi_range(-50, 50),
					randi_range(-50, 50))
				1:
					idle_timer.start(randf_range(0.5, 1))

func _on_timer_timeout():
	make_path()

func _on_hitbox_knockback(vector, knockback_strength):
	velocity = vector*knockback_strength

func _on_sight_area_entered(area):
	state = CHASE
	player = area
	speed = 40

func _on_sight_area_exited(area):
	state = IDLE
	player = area
	speed = 20


func _on_attack_timer_timeout():
	if not state ==  CHASE:
		return
	if global_position.distance_to(player.global_position) < 20:
		attack_animation.play("attack")
		speed -= 5
	elif speed < 55 and global_position.distance_to(player.global_position) < 70:
		speed += 5

func _on_hitbox_area_entered(area):
	flash_timer.start(0.5)
