extends CharacterBody2D

enum{
	BASIC,
	SECONDARY,
}

enum{
	IDLE,
	IN_USE
}

var max_speed = 50
var acceleration = 250
var direction_to_mouse_from_shoulder = 0
var sword_direction = 0
var hurtbox_points = []
var swish = null
var last_input_vector = Vector2.RIGHT
var pointing_direction = Vector2.ZERO
var action_1_cooldown = 0.25
var action_2_cooldown = 2.0
var action_3_cooldown = 2.0
var action_2_damage = 0
var action_1_damage = 0
var action_3_damage = 0
var item_state = IDLE
var last_shoulder_rotation = 0.0
var secondary_active = false
var tertiary_active = false
var not_attack_dash_active = false
var dash_speed = 3
var super_dash_speed = 6
var swish_thickness = 10
var basic_energy = 0
var secondary_energy = 0
var tertiary_energy = 0
var dark_basic = false
var dark_secondary = false
var dark_tertiary = false

var sword_hurtbox = preload("res://items/sword_hurtbox.tscn")
var sword_swish = preload("res://items/swish.tscn")
var fireball = preload("res://attacks/fireball.tscn")
var magic_ball = preload("res://attacks/magic_ball.tscn")
var lightning_bolt = preload("res://attacks/lightning_bolt.tscn")
var wand_lightning_explosion = preload("res://effects/lightning_explosion.tscn")
var spark = preload("res://attacks/spark.tscn")
var magic_spark = preload("res://attacks/magic_spark.tscn")
var electric_spark = preload("res://attacks/electric_spark.tscn")
var wand_fire_explosion = preload("res://effects/fire_explosion.tscn")
var lifeless_patch = preload("res://effects/lifeless_patch.tscn")
var heart = preload("res://items/heart.tscn")

@export var shoulder_rotation_augment:float = 1

@onready var dash_timer = $"Dash Timer"
@onready var dash_hurtbox = $Shoulder/Hand/Sword/Area2D/CollisionShape2D
@onready var item_animations = $"Item Animations"
@onready var attack_cooldown = $"Attack Cooldown"
@onready var secondary_attack_cooldown = $"Secondary Attack Cooldown"
@onready var tertiary_attack_cooldown = $"Tertiary Attack Cooldown"
@onready var shoulder = $Shoulder
@onready var sprite = $Character1
@onready var head = $Head
@onready var hand = $Shoulder/Hand
@onready var blade_base = $Shoulder/Hand/Sword/Base
@onready var blade_center = $Shoulder/Hand/Sword/Center
@onready var blade_tip = $Shoulder/Hand/Sword/Tip
@onready var character_animations = $"Character Animations"
@onready var pointer = $Pointer
@onready var sword_sprite = $Shoulder/Hand/Sword
@onready var dash_lines = $"Shoulder/Dash Lines"

func _ready():
	randomize()
	dash_hurtbox.disabled = true
	dash_hurtbox.get_parent().damage = action_3_damage
	#shoulder_rotation_augment = 1
	Global.connect("inventory_updated", Callable(self, "update_held_item"))
	Global.connect("camera_shake", Callable(self, "camera_shake"))
	update_held_item()

func _physics_process(delta):
	#Music.update_mosters($Sight.get_overlapping_bodies().size())
	var input_vector = Vector2.ZERO
	if not (secondary_active or tertiary_active):
		input_vector = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = velocity.move_toward(input_vector*max_speed, acceleration*delta)
	move_and_slide()
	
	
	if input_vector:
		last_input_vector = input_vector
	
	
	if input_vector or velocity:
		if last_input_vector.y < -0.25:
			character_animations.play("walk_up")
		else:
			character_animations.play("walk")
	else:
		if last_input_vector.y < -0.25:
			character_animations.play("idle_up")
		else:
			character_animations.play("idle")
	
	
	sprite.flip_h = last_input_vector.x < 0
	hand.flip_h = sword_direction == 0
	
	if Global.control_type == Global.KEYBOARD:
		head.flip_h = global_position.direction_to(get_global_mouse_position()).x < 0
	else:
		head.flip_h = last_input_vector.x < 0
	
	
	direction_to_mouse_from_shoulder = atan2(
		shoulder.global_position.y-get_global_mouse_position().y, 
		shoulder.global_position.x-get_global_mouse_position().x
	)
	
	#what texture to use for the hands in case of double handed weapons
	if Global.equipped_item != -1:
		match Global.items[Global.equipped_item].hand_texture:
			0:
				hand.texture = load("res://characters/hand.png")
				hand.offset.x = 0
			1:
				hand.texture = load("res://characters/horizontal_hands.png")
				hand.offset.x = 0
			2:
				hand.texture = load("res://characters/vertical_hands.png")
				hand.offset.x = -6
	else:
		hand.texture = load("res://characters/hand.png")
	
	
	if not Global.items[Global.equipped_item].directional_basic:
		shoulder_rotation_augment = 0
	
	#logic to figure out the rotationn of the shoulder
	if Global.control_type == Global.KEYBOARD:
		if item_state == IDLE:
			shoulder.rotation = direction_to_mouse_from_shoulder + shoulder_rotation_augment
			last_shoulder_rotation = direction_to_mouse_from_shoulder
		elif not tertiary_active:
			shoulder.rotation = last_shoulder_rotation + shoulder_rotation_augment
		pointer.rotation = direction_to_mouse_from_shoulder
	else:
		if item_state == IDLE:
			shoulder.rotation = atan2(-last_input_vector.y, -last_input_vector.x) + shoulder_rotation_augment
			last_shoulder_rotation = atan2(-last_input_vector.y, -last_input_vector.x)
		else:
			shoulder.rotation = last_shoulder_rotation + shoulder_rotation_augment
		pointer.rotation = atan2(-last_input_vector.y, -last_input_vector.x)
	if item_state == IDLE:
		shoulder.rotation = round(shoulder.rotation*5)/5
	pointer.rotation = round(pointer.rotation*5)/5
	shoulder.show_behind_parent = hand.global_position.y+5 < global_position.y
	
	
	if (Input.is_action_just_pressed("action_1") or (Input.is_action_pressed("action_1") and Global.items[Global.equipped_item].automatic_basic)) and attack_cooldown.is_stopped() and Global.player_energy > basic_energy:
		Global.player_energy -= basic_energy
		use_item()
	
	if Input.is_action_just_pressed("action_2") and secondary_attack_cooldown.is_stopped() and Global.player_energy > secondary_energy:
		Global.player_energy -= secondary_energy
		use_item_secondary()
	
	if Input.is_action_just_pressed("action_3"):
		pass
		#print(">>>>>>>>>>>>>>>>>dash<<<<<<<<<<<<<<<<<<")
		#print($"Super Dash Timer".time_left)
		#print(tertiary_attack_cooldown.time_left)
		#print(dash_speed/5)
	if Input.is_action_just_pressed("action_3") and (tertiary_attack_cooldown.is_stopped() or $"Super Dash Timer".time_left != 0.0) and Global.player_energy > tertiary_energy:
		Global.player_energy -= tertiary_energy
		use_item_tertiary()
		dash_timer.start()
	
	UI.action_1_cooldown = attack_cooldown.time_left/action_1_cooldown
	UI.action_2_cooldown = secondary_attack_cooldown.time_left/action_2_cooldown
	UI.action_3_cooldown = tertiary_attack_cooldown.time_left/action_3_cooldown
	
	$Shoulder/Hand/Sword/Tip/GPUParticles2D.emitting = tertiary_active
	dash_lines.emitting = tertiary_active

func update_held_item():
	#if it's just the hand, load the hand stats
	if Global.equipped_item == -1:
		action_1_damage = 0.0
		action_2_damage = 0.0
		action_3_damage = 0.0
		sword_sprite.texture = null
		action_1_cooldown = 0.1
		action_2_cooldown = 0.5
		action_3_cooldown = 0.75
		blade_base.position.x = 19
		blade_center.position.x = 17
		blade_tip.position.x = 15
		dash_speed = 3
		super_dash_speed = 4
		basic_energy = 0
		secondary_energy = 0
		tertiary_energy = 0
		match sword_direction:
			0:
				shoulder_rotation_augment = 1
			1:
				shoulder_rotation_augment = -1
		return
	#otherwise, load the stats for the item
	var equipped_item_res:Item = Global.items[Global.equipped_item]
	action_1_cooldown = equipped_item_res.basic_cooldown
	action_2_cooldown = equipped_item_res.secondary_cooldown
	action_3_cooldown = equipped_item_res.tertiary_cooldown
	action_1_damage = equipped_item_res.basic_damage
	action_2_damage = equipped_item_res.secondary_damage
	action_3_damage = equipped_item_res.tertiary_damage
	sword_sprite.texture = equipped_item_res.texture
	sword_sprite.position = equipped_item_res.offset
	blade_base.position.x = equipped_item_res.blade_base
	blade_center.position.x = equipped_item_res.blade_center
	blade_tip.position.x = equipped_item_res.blade_tip
	dash_speed = equipped_item_res.dash_speed
	basic_energy = equipped_item_res.basic_energy
	secondary_energy = equipped_item_res.secondary_energy
	tertiary_energy = equipped_item_res.tertiary_energy
	dark_basic = equipped_item_res.dark_basic
	dark_secondary = equipped_item_res.dark_secondary
	dark_tertiary = equipped_item_res.dark_tertiary
	if equipped_item_res.directional_basic:
		match sword_direction:
			0:
				shoulder_rotation_augment = 1
			1:
				shoulder_rotation_augment = -1
	else:
		shoulder_rotation_augment = 0

func use_item():
	if item_state == IN_USE or item_animations.is_playing():
		return
	
	if dark_basic:
		if $"Dark Magic".get_overlapping_areas().size() != 0:
			#print($"Dark Magic".get_overlapping_areas())
			basic_finished()
			return
		spawn_lifeless_patch()
	
	item_state = IN_USE
	attack_cooldown.start(action_1_cooldown)
	if Global.equipped_item == -1:
		hurtbox_points = []
		match sword_direction:
			0:
				item_animations.play("sword_up")
				sword_direction = 1
			1:
				item_animations.play("sword_down")
				sword_direction = 0
		return
	hurtbox_points = []
	var equipped_item_res: Item = Global.items[Global.equipped_item]
	if equipped_item_res.directional_basic:
		match sword_direction:
			0:
				item_animations.play(equipped_item_res.basic_animation + "_up")
				sword_direction = 1
			1:
				item_animations.play(equipped_item_res.basic_animation + "_down")
				sword_direction = 0
	else:
		item_animations.play(equipped_item_res.basic_animation)

func basic_finished():
	item_state = IDLE

func secondary_finsihed():
	item_state = IDLE
	secondary_active = false

func tertiary_finished():
	item_state = IDLE
	tertiary_active = false

func use_item_secondary():
	if item_state == IN_USE or item_animations.is_playing():
		return
	
	if dark_secondary:
		if $"Dark Magic".get_overlapping_areas().size() != 0:
			secondary_finsihed()
			return
		spawn_lifeless_patch()
	
	item_state = IN_USE
	secondary_attack_cooldown.start(action_2_cooldown)
	if Global.equipped_item == -1:
		hurtbox_points = []
		item_state = IN_USE
		match sword_direction:
			0:
				item_animations.play("sword_spin_up")
				sword_direction = 1
			1:
				item_animations.play("sword_spin_down")
				sword_direction = 0
		item_state = IN_USE
		hurtbox_points = []
		if Global.control_type == Global.KEYBOARD:
			velocity = (global_position.direction_to(get_global_mouse_position())).normalized()*max_speed*3
			last_input_vector = global_position.direction_to(get_global_mouse_position())
		else:
			velocity = last_input_vector*max_speed*dash_speed
		return
	
	var equipped_item_res: Item = Global.items[Global.equipped_item]
	#dash
	if equipped_item_res.dash_on_secondary:
		if Global.control_type == Global.KEYBOARD:
			velocity = 	(global_position.direction_to(get_global_mouse_position())).normalized()*max_speed*3
			last_input_vector = global_position.direction_to(get_global_mouse_position())
		else:
			velocity = last_input_vector*max_speed*dash_speed
	#figure out the animation
	if equipped_item_res.directional_secondary:
		match sword_direction:
			0:
				item_animations.play(equipped_item_res.secondary_animation + "_up")
				sword_direction = 1
			1:
				item_animations.play(equipped_item_res.secondary_animation + "_down")
				sword_direction = 0
	else:
		item_animations.play(equipped_item_res.secondary_animation)

func use_item_tertiary():
	if item_state == IN_USE or item_animations.is_playing():
		return
	item_state = IN_USE
	
	if dark_tertiary:
		if $"Dark Magic".get_overlapping_areas().size() != 0:
			tertiary_finished()
			return
		spawn_lifeless_patch()
	
	#if hand is empty, don't bother with any logic
	if Global.equipped_item == -1:
		hurtbox_points = []
		dash_hurtbox.get_parent().damage = action_3_damage
		tertiary_attack_cooldown.start(action_3_cooldown)
		item_state = IN_USE
		tertiary_active = true
		item_animations.play("dash")
		var speed_for_this_dash = 0.0
		if (not $"Super Dash Timer".is_stopped()) and Global.super_dash_unlocked:
			speed_for_this_dash = max_speed*super_dash_speed
		else:
			speed_for_this_dash = max_speed*dash_speed
		if Global.control_type == Global.KEYBOARD:
			velocity = (global_position.direction_to(get_global_mouse_position())).normalized()*speed_for_this_dash
			last_input_vector = global_position.direction_to(get_global_mouse_position())
		else:
			velocity = last_input_vector*speed_for_this_dash
		return
	
	dash_hurtbox.get_parent().damage = action_3_damage
	tertiary_attack_cooldown.start(action_3_cooldown)
	
	
	var equipped_item_res: Item = Global.items[Global.equipped_item]
	if equipped_item_res.directional_tertiary:
		match sword_direction:
			0:
				item_animations.play(equipped_item_res.tertiary_animation + "_up")
				sword_direction = 1
			1:
				item_animations.play(equipped_item_res.tertiary_animation + "_down")
				sword_direction = 0
	else:
		item_animations.play(equipped_item_res.tertiary_animation)
	
	
	shoulder.rotation = direction_to_mouse_from_shoulder
	item_state = IN_USE
	tertiary_active = true
	if Global.control_type == Global.KEYBOARD:
		velocity = (global_position.direction_to(get_global_mouse_position())).normalized()*max_speed*dash_speed*1.5
		last_input_vector = global_position.direction_to(get_global_mouse_position())
	else:
		velocity = last_input_vector*max_speed*dash_speed*1.5

func _add_sword_swing_point(pos):
	if pos == 0:
		swish = sword_swish.instantiate()
		swish.width = Global.items[Global.equipped_item].swish_thickness
		add_sibling(swish)
		#shoulder.visible = false
	if pos == 1 or pos == 3:
		swish.add_point(blade_center.global_position)
		return
	hurtbox_points.append(blade_base.global_position - global_position)
	hurtbox_points.append(blade_tip.global_position - global_position)
	swish.add_point(blade_center.global_position)
	if pos == 4:
		spawn_sword_hurtbox(BASIC)
		shoulder.visible = true
		item_state = IDLE

func add_sword_spin_point(pos):
	if pos == 0:
		swish = sword_swish.instantiate()
		swish.time = 0.4
		swish.width = Global.items[Global.equipped_item].swish_thickness
		add_sibling(swish)
		shoulder.visible = false
		secondary_active = true
	hurtbox_points.append(blade_base.global_position - global_position)
	hurtbox_points.append(blade_tip.global_position - global_position)
	if hurtbox_points.size() >= 4:
		spawn_sword_hurtbox(SECONDARY)
		hurtbox_points = [hurtbox_points[2], hurtbox_points[3]]
	swish.add_point(blade_center.global_position)
	if pos == 8:
		shoulder.visible = true
	if pos == 9:
		secondary_active = false
		item_state = IDLE

func spawn_sword_hurtbox(attack_type):
	var hurtbox = sword_hurtbox.instantiate()
	hurtbox.points = hurtbox_points
	hurtbox.type = attack_type
	hurtbox.position = position
	match attack_type:
		BASIC:
			hurtbox.damage = action_1_damage
			hurtbox.knockback_strength = 100
		SECONDARY:
			hurtbox.damage = action_2_damage
			hurtbox.knockback_strength = 150
	add_sibling(hurtbox)

func add_swish_point():
	swish.add_point(blade_center.global_position)

func _on_timer_timeout():
	swish.points = []

func _on_hitbox_area_entered(area):
	Global.player_health -= area.damage

func camera_shake():
	match Global.screen_shake_size:
		0:
			match randi() %4:
				0:
					$"Camera Shake".play("camera_shake_brief")
				1:
					$"Camera Shake".play("camera_shake_brief_2")
				2:
					$"Camera Shake".play("camera_shake_brief_3")
				3:
					$"Camera Shake".play("camera_shake_brief_4")
		1:
			$"Camera Shake".play("camera shake")

func spawn_lifeless_patch():
	var instance = lifeless_patch.instantiate()
	instance.global_position = global_position
	add_sibling(instance)

func spawn(resource, damage, speed):
	var spark_instance = resource.instantiate()
	spark_instance.global_position = blade_tip.global_position
	spark_instance.damage = Global.items[Global.equipped_item].basic_damage
	spark_instance.velocity = Vector2(
		cos(direction_to_mouse_from_shoulder),
		sin(direction_to_mouse_from_shoulder),
	)*speed
	add_sibling(spark_instance)

func spawn_spark():
	spawn(spark, Global.items[Global.equipped_item].basic_damage, 1)

func spawn_magic_spark():
	spawn(magic_spark, Global.items[Global.equipped_item].basic_damage, 1)
	
func spawn_electric_spark():
	spawn(electric_spark, Global.items[Global.equipped_item].basic_damage, 1.25)

func spawn_fireball():
	spawn(fireball, Global.items[Global.equipped_item].secondary_damage, 1.5)

func spawn_heart():
	spawn(heart, 0, 0)

func spawn_magic_ball():
	spawn(magic_ball, Global.items[Global.equipped_item].secondary_damage, 1.5)
	#var magic_ball_instance = magic_ball.instantiate()
	#magic_ball_instance.global_position = blade_tip.global_position
	#magic_ball_instance.damage = Global.items[Global.equipped_item].secondary_damage
	#magic_ball_instance.velocity = Vector2(
	#	cos(shoulder.rotation),
	#	sin(shoulder.rotation),
	#)*1.5
	#add_sibling(magic_ball_instance)

func spawn_lightning_bolt():
	var lightning_explosion_instance = wand_lightning_explosion.instantiate()
	lightning_explosion_instance.global_position = blade_tip.global_position
	lightning_explosion_instance.rotation = shoulder.rotation
	add_sibling(lightning_explosion_instance)
	var lightning_bolt_instance = lightning_bolt.instantiate()
	lightning_bolt_instance.global_position = blade_tip.global_position
	lightning_bolt_instance.damage = Global.items[Global.equipped_item].secondary_damage
	lightning_bolt_instance.rotation = shoulder.rotation - PI
	add_sibling(lightning_bolt_instance)

func wand_explosion():
	var fire_explosion_instance = wand_fire_explosion.instantiate()
	fire_explosion_instance.global_position = blade_tip.global_position
	fire_explosion_instance.rotation = shoulder.rotation
	add_sibling(fire_explosion_instance)


func _on_tertiary_attack_cooldown_timeout():
	$"Super Dash Timer".start(Global.super_dash_time)
	UI.tertiary_cooldown_finished(Global.super_dash_time)
