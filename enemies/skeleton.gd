extends "res://enemies/enemy.gd"

var die_animation = preload("res://enemies/skeleton_die.tscn")

@onready var shoulder = $Shoulder
@onready var directions = [
	$directions/left,
	$directions/right,
]
@onready var back = $directions/back
@onready var dagger = $Shoulder/Dagger
@onready var attack_animation = $Attack
@onready var walk_animation = $Walk
@onready var hurtbox = $Shoulder/Dagger/Hurtbox

@export var shoulder_rotation_augment = 0
@export var dagger_x_augment = 0

func _ready():
	health = 10
	hurtbox.damage = 5

func die():
	var death = die_animation.instantiate()
	death.global_position = global_position
	add_sibling(death)
	#Music.update_mosters(Music.monsters_on_screen - 1)
	#Music.monster_slain()
	queue_free()

func _process(delta):
	var target = to_local(next_path_position)
	print(nav_agent.target_position)
	$Icon.global_position = next_path_position
	velocity = velocity.move_toward(target.normalized()*speed, 500*delta)
	move_and_slide()
	
	if velocity.y < 0.25:
		sprite.flip_h = velocity.x > 0
	else:
		sprite.flip_h = velocity.x < 0
	
	$Label.position = target
	
	calculate_shoulder_rotation()
	calculate_animation()
	
	dagger.position.x = ((abs(cos(shoulder.rotation)*2)*-3)-4) + dagger_x_augment

func calculate_animation():
	if not velocity:
		if last_velocity.y < 0.25:
			walk_animation.play("idle_up")
			return
		walk_animation.play("idle_down")
		return
	if velocity.y < -0.25:
		walk_animation.play("walk_up")
		return
	walk_animation.play("walk_down")
	

func calculate_shoulder_rotation():
	match state:
		IDLE:
			shoulder.rotation = atan2(velocity.y, velocity.x)
		CHASE:
			shoulder.rotation = atan2(
		global_position.direction_to(player.global_position).y, 
		global_position.direction_to(player.global_position).x)
	shoulder.show_behind_parent = shoulder.rotation < 2.35 and shoulder.rotation > 0.75
	shoulder.rotation = round(shoulder.rotation*5)/5

func _on_player_spotted():
	speed = 70

func _on_player_fled():
	speed = 20

func _on_pathfind_to_player():
	$directions.rotation = atan2(
		global_position.direction_to(player.global_position).y, 
		global_position.direction_to(player.global_position).x)
	if global_position.distance_to(player.global_position) > 20:
		nav_agent.target_position = player.global_position
	elif global_position.distance_to(player.global_position) < 15:
		nav_agent.target_position = back.global_position
	else:
		for x in directions:
			if not x.has_overlapping_bodies():
				nav_agent.target_position = x.global_position
				if not directions[0] == x:
					directions.reverse()
				return

func _on_attack_timer_timeout():
	if state == IDLE or global_position.distance_to(player.global_position) > 30:
		return
	attack_animation.play("attack")


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	if not safe_velocity == Vector2.ZERO:
		velocity = safe_velocity
