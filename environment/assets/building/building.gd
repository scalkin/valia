@tool
extends StaticBody2D
class_name Building

@export var has_door = true
@export var shape:PackedVector2Array
@export var collision_shape:PackedVector2Array
@export var reload = false:
	set(_value):
		if Engine.is_editor_hint():
			reload = false
			_ready()

@onready var collision_polygon = $CollisionPolygon2D
@onready var editor_display_polygon = $Polygon2D
@onready var shadow = $Shadow

func _ready():
	if not Engine.is_editor_hint():
		editor_display_polygon.visible = false
	if not shape == null:
		collision_polygon.polygon = collision_shape
		editor_display_polygon.polygon = shape
	var index = 0
	var poly: PackedVector2Array = []
	for x in shape:
		var point_0 = shape[shape.size() - 1]
		var point_1 = x
		var point_2 = shape[0]
		var shadow_point = point_1
		var extension = 4
		
		if index != shape.size() - 1:
			point_2 = shape[index + 1]
		
		if index != 0:
			point_0 = shape[index - 1]
		
		#calculate a new polygon based off the shape of the building, surrounding the building for a shadow
		#which point do we use to determine the x; if point 0's x is the same as point 1's then use point 2, and if that's x is also the same, then this isn't a corner and shouldn't exist, and will probably result in something that looks weird. 
		if point_1.x == point_0.x:
			if point_1.x == point_2.x:
				pass
			elif point_1.x > point_2.x:
				shadow_point.x += extension
			elif point_1.x < point_2.x:
				shadow_point.x -= extension
		else:
			if point_1.x > point_0.x:
				shadow_point.x += extension
			else:
				shadow_point.x -= extension
				
		if point_1.y == point_0.y:
			if point_1.y == point_2.y:
				pass
			elif point_1.y > point_2.y:
				shadow_point.y += extension
			elif point_1.y < point_2.y:
				shadow_point.y -= extension
		else:
			if point_1.y > point_0.y:
				shadow_point.y += extension
			else:
				shadow_point.y -= extension
		
		poly.append(shadow_point)
		index += 1
	shadow.polygon = poly

func _process(_delta):
	if has_door:
		$Door.modulate.a = 255
	else:
		$Door.modulate.a = 0
	if not shape == null and Engine.is_editor_hint():
		$Polygon2D.polygon = shape
	if not collision_shape == null and Engine.is_editor_hint():
		$CollisionPolygon2D.polygon = collision_shape
	
	
