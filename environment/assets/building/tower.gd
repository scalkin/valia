@tool
extends "res://environment/assets/building/building.gd"

@export var window = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"TowerWindow".visible = window
