extends Node2D

@export var destination: PackedScene

func _process(delta):
	$Door.visible = not $Area2D.get_overlapping_bodies().size() > 0
