extends CanvasLayer

var action_1_cooldown = 0.0
var action_2_cooldown = 0.0
var action_3_cooldown = 0.0

var mouse_left = preload("res://ui/assets/mouse_left.png")
var mouse_right = preload("res://ui/assets/mouse_right.png")
var mouse_middle = preload("res://ui/assets/mouse_middle.png")
var space_button = preload("res://ui/assets/space.png")
var square_button = preload("res://ui/assets/square.png")
var cross_button = preload("res://ui/assets/cross.png")
var circle_button = preload("res://ui/assets/circle.png")
var fist_basic = preload("res://ui/assets/basic_fist.png")
var fist_spin = preload("res://ui/assets/spin_fist.png")
var fist_dash = preload("res://ui/assets/dash_fist.png")

@onready var item = $Item
@onready var action_1_button = $"Control/Action Bar/HBoxContainer/Action 1/Action 1 Button"
@onready var action_2_button = $"Control/Action Bar/HBoxContainer/Action 2/Action 2 Button"
@onready var action_3_button = $"Control/Action Bar/HBoxContainer/Action 3/Action 3 Button"
@onready var action_1_icon = $"Control/Action Bar/HBoxContainer/Action 1"
@onready var action_2_icon = $"Control/Action Bar/HBoxContainer/Action 2"
@onready var action_3_icon = $"Control/Action Bar/HBoxContainer/Action 3"
@onready var action_1_cooldown_bar = $"Control/Action Bar/HBoxContainer/Action 1/ProgressBar"
@onready var action_2_cooldown_bar = $"Control/Action Bar/HBoxContainer/Action 2/ProgressBar"
@onready var action_3_cooldown_bar = $"Control/Action Bar/HBoxContainer/Action 3/ProgressBar"
@onready var hand_slot = $"Control/Menu/TabContainer/Inventory/VBoxContainer/Control/HBoxContainer/VBoxContainer/Inventory Slot"
@onready var inventory_container = $Control/Menu/TabContainer/Inventory/VBoxContainer/CenterContainer/GridContainer
@onready var equip_container = $Control/Menu/TabContainer/Inventory/VBoxContainer/Control/HBoxContainer/VBoxContainer
@onready var menu = $Control/Menu
@onready var console = $Control/Console
@onready var health_bar = $"Control/Status Bar/NinePatchRect/ProgressBar"
@onready var energy_bar = $"Control/Status Bar/NinePatchRect2/ProgressBar"
@onready var super_effect = $"Control/Action Bar/HBoxContainer/Action 3/Super"

func _process(delta):
	action_1_cooldown_bar.value = action_1_cooldown
	action_2_cooldown_bar.value = action_2_cooldown
	action_3_cooldown_bar.value = action_3_cooldown
	
	super_effect.visible = not $"Super Dash Timer".is_stopped()
	
	match Global.control_type:
		Global.KEYBOARD:
			action_1_button.texture = mouse_left
			action_2_button.texture = mouse_right
			action_3_button.texture = space_button
		Global.CONTROLLER:
			action_1_button.texture = square_button
			action_2_button.texture = cross_button
			action_3_button.texture = circle_button
	
	Global.equipped_item = hand_slot.item
	
	if Global.equipped_item == -1:
		action_1_icon.texture = fist_basic
		action_2_icon.texture = fist_spin
		action_3_icon.texture = fist_dash
	else:
		action_1_icon.texture = Global.items[Global.equipped_item].basic_icon
		action_2_icon.texture = Global.items[Global.equipped_item].secondary_icon
		action_3_icon.texture = Global.items[Global.equipped_item].tertiary_icon
	
	
	if not Global.mouse_held_item == -1:
		item.global_position = item.get_global_mouse_position()
		item.visible = menu.visible
		item.texture = Global.items[Global.mouse_held_item].icon
	else:
		item.visible = false
	
	if Input.is_action_just_pressed("menu"):
		menu.visible = not menu.visible
		console.visible = false
		get_tree().paused = menu.visible
	
	if Input.is_action_just_pressed("console"):
		menu.visible = false
		console.visible = not console.visible
	
	
	health_bar.max_value = Global.player_max_health
	health_bar.value = Global.player_health
	
	energy_bar.max_value = Global.player_max_energy
	energy_bar.value = Global.player_energy
	
	var health_percentage:float = float(Global.player_health)/float(Global.player_max_health)  
	
	var vignette_target_open_amount = Tween.interpolate_value(0.35, 0.19, health_percentage, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	var vignette_open_amount = $Vignette.material.get("shader_parameter/open_amount")
	
	if vignette_open_amount > vignette_target_open_amount:
		vignette_open_amount -= delta/2
		if vignette_open_amount < vignette_target_open_amount:
			vignette_open_amount = vignette_target_open_amount
	else:
		vignette_open_amount += delta/2
		if vignette_open_amount > vignette_target_open_amount:
			vignette_open_amount = vignette_target_open_amount
	
	$Vignette.material.set("shader_parameter/open_amount", vignette_open_amount)
	$Vignette.material.set("shader_parameter/tint", Tween.interpolate_value(Vector4(0.0, 0.0, 0.0, 1.0), Vector4(0.54, 0.12, 0.17, 0.0), 1.2-health_percentage, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN))
	
	#$Vignette.scale = DisplayServer.window_get_size(0)/5


func load_inventory():
	var index = 0
	for x in inventory_container.get_children():
		x.item = Global.inventory[index]
		index += 1
	for x in equip_container.get_children():
		x.item = Global.inventory[index]
		index += 1


func _on_console_text_submitted(new_text):
	if console.placeholder_text == "enter command" or console.placeholder_text == "invalid command":
		match new_text:
			"summon":
				console.placeholder_text = "entity"
			"set":
				console.placeholder_text = "variable"
			_:
				console.placeholder_text = "invalid command"
		console.text = ""
	else:
		match console.placeholder_text:
			"entity":
				match new_text:
					"skeleton":
						console.placeholder_text = "enter command"
					"cancel":
						console.placeholder_text = "enter command"
					_:
						console.placeholder_text = "invalid command"
			"variable":
				match new_text:
					"health":
						console.placeholder_text = "health value"
					_:
						console.placeholder_text = "invalid command"
			"health value":
				Global.player_health = int(new_text)
				console.placeholder_text = "enter command"
				console.visible = false
			_:
				console.placeholder_text = "invalid command"
		console.text = ""


func _on_button_pressed():
	Global.save_game()

func tertiary_cooldown_finished(super_dash_time):
	$"Super Dash Timer".start(super_dash_time)
