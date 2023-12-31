@tool
extends Sprite2D

class_name MultiTextureSprite

@export var textures: PackedStringArray
@export var texture_id: int:
	set(value):
		if value + 1 > textures.size():
			value = 0
		if value < 0:
			value = textures.size() - 1
		if textures.size() != 0:
			texture = load(textures[value])
		texture_id = value

func _ready():
	centered = false

