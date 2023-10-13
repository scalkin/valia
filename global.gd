extends Node

enum{
	KEYBOARD,
	CONTROLLER
}

var screen_shake_size = 0
var mouse_held_item = -1
var control_type = KEYBOARD
var player_health = 15:
	set(value):
		player_health = value
		if player_health > player_max_health:
			player_health = player_max_health
		elif player_health <= 0:
			player_health = 0
			respawn()
var player_max_health = 15
var inventory = [
	-1, -1, -1, -1,
	-1, -1, -1, -1,
	-1, -1, 5, 4,
	0, 1, 2, 3,
	-1, -1, -1]

var equipped_item = -1
var items = [
	load("res://items/resources/0.tres"),
	load("res://items/resources/1.tres"),
	load("res://items/resources/2.tres"),
	load("res://items/resources/3.tres"),
	load("res://items/resources/4.tres"),
	load("res://items/resources/5.tres"),
]

var dash_unlocked = true
var super_dash_unlocked = true
var super_dash_time = 0.5

signal inventory_updated
signal equipped_item_changed
signal camera_shake

func _ready():
	UI.call_deferred("load_inventory")
	#get_window().size = Vector2(1600, 900)
	#get_window().position = Vector2(DisplayServer.screen_get_size()*0.5 - get_window().size * 0.5)
	

func _input(event):
	if event is InputEventKey or event is InputEventMouse:
		control_type = KEYBOARD
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if event is InputEventJoypadMotion and event.axis_value < 0.25 and event.axis_value > -0.25:
			return
		control_type = CONTROLLER

func give_item(id):
	var _index = 0
	for x in inventory:
		if x == -1:
			x = id
			UI.load_inventory()
			return true
		_index += 1
	return false

func set_item(item, slot):
	inventory[slot] = item
	equipped_item = inventory[16]
	emit_signal("inventory_updated")

func shake_camera():
	emit_signal("camera_shake")
	screen_shake_size = 0

func freeze_frame():
	$Freeze.start()
	get_tree().paused = true

func _on_freeze_timeout():
	get_tree().paused = false

func respawn():
	get_tree().reload_current_scene()
	randomize()
	player_health = player_max_health

func save_data():
	return {
		"mouse_held_item" : mouse_held_item,
		"player_health" : player_health,
		"player_max_health" : player_health,
		"inventory" : inventory,
		"equipped_item" : equipped_item,
		"dash_unlocked" : dash_unlocked,
	}

func save_game():
	var save = save_data()
	var json_save = JSON.stringify(save, " ", false, true)
	var save_file = FileAccess.open("user://randomboringrpgthatnobodyplays/savedata", FileAccess.WRITE)
	print(save_file)
	save_file.store_string(json_save)
	save_file.close()

#just for readability
func vector_average(vector_1, vector_2):
	return (vector_1+vector_2)/2.0
