extends Panel

enum item_type {SWORD, ARMOR, BOOTS}

@export var item = -1
@export var slot = 0
@export var equip_slot = false
@export var type: item_type

@onready var icon = $TextureRect

func _ready():
	pass

func _process(_delta):
	if get_node_or_null("Slot Icon"):
		get_node("Slot Icon").visible = (item == -1)
	if item == -1:
		icon.visible = false
		return
	icon.visible = true
	icon.texture = Global.items[item].icon


func _on_button_pressed():
	if equip_slot and (not Global.items[Global.mouse_held_item].type == type) and (not Global.mouse_held_item == -1):
		return
	var buffer = item
	item = Global.mouse_held_item
	Global.mouse_held_item = buffer
	Global.set_item(item, slot)
