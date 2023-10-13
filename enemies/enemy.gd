extends CharacterBody2D

enum{
	IDLE,
	CHASE
}

signal pathfind_to_player
signal player_spotted
signal player_fled

var state = IDLE
var first_frame = true
var spawn_point = Vector2.ZERO
var player = null
var last_velocity = Vector2.ZERO
var hit_effect = preload("res://effects/white_hit_effect.tscn")
var number_effect = preload("res://effects/number.tscn")
var next_path_position = Vector2.ZERO

@export var wander = true
@export var wander_distance = 50
@export var speed = 20
@export var health = 10:
	set(value):
		health = value
		if health <= 0:
			die()

@onready var nav_agent = $NavigationAgent2D
@onready var sprite = $Node2D/Sprite2D
@onready var flash_timer = $"Flash Timer"

func _physics_process(delta):
	if first_frame:
		spawn_point = global_position
		first_frame = false
		target_position(Vector2(
				randi_range(-wander_distance, wander_distance),
				randi_range(-wander_distance, wander_distance)))
		return
	
	if $"Detect Nearby Enemies".get_overlapping_bodies() != []:
		global_position += delta*$"Detect Nearby Enemies".get_overlapping_bodies()[0].global_position.direction_to(global_position)
	
	if velocity:
		last_velocity = velocity
	
	
	#sprite.material.set("shader_parameter/flash", bool(flash_timer.time_left))

func die():
	queue_free()


func _on_sight_area_entered(area):
	state = CHASE
	player = area
	emit_signal("player_spotted")

func _on_sight_area_exited(_area):
	state = IDLE
	emit_signal("player_fled")

func _on_nav_timer_timeout():
	match state:
		IDLE:
			if wander:
				if global_position.distance_to(nav_agent.target_position) < speed:
					target_position(spawn_point + Vector2(
						randi_range(-wander_distance, wander_distance),
						randi_range(-wander_distance, wander_distance)))
			else:
				if global_position.distance_to(spawn_point) < speed:
					target_position(global_position)
				else:
					target_position(spawn_point)
		CHASE:
			emit_signal("pathfind_to_player")
	
	next_path_position = nav_agent.get_next_path_position()

func _on_hitbox_area_entered(area):
	$Hit.play("hit")
	var effect = number_effect.instantiate()
	effect.global_position = global_position + (Vector2.UP*5)
	effect.text = str(area.damage)
	add_sibling(effect)
	health -= area.damage
	flash_timer.start()
	Global.shake_camera()

func freeze_frame():
	Global.freeze_frame()

func target_position(target):
	
	$RayCast2D.target_position = to_local(target)
	$RayCast2D.force_raycast_update()
	if $RayCast2D.is_colliding():
		target = $RayCast2D.get_collision_point()
	
	nav_agent.target_position = target
