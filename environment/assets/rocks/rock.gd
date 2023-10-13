@tool
extends StaticBody2D

@export var texture = 0:
	set(value):
		texture = value
		$AnimatedSprite2D.frame = texture
@export var random = false:
	set(_value):
		texture = randi() % 4

