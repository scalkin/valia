@icon("res://editor/item.png")
extends Resource

class_name Item

enum item_type {SWORD, ARMOR, BOOTS}

@export var id: int
@export var name: String
@export var type: item_type
@export var texture: Texture
@export var icon: Texture
@export var offset: Vector2
@export var blade_base: int
@export var blade_center: int
@export var blade_tip: int
@export var basic_damage: int
@export var secondary_damage:int
@export var tertiary_damage:int
@export var basic_cooldown:float
@export var secondary_cooldown:float
@export var tertiary_cooldown:float
@export var dash_speed:float
@export var super_dash_speed:float
@export var swish_thickness:int
@export var basic_animation:String
@export var directional_basic = true
@export var automatic_basic = false
@export var basic_energy = 0.0
@export var dark_basic = false
@export var secondary_animation:String
@export var directional_secondary = true
@export var dash_on_secondary = true
@export var secondary_energy = 0.0
@export var dark_secondary = false
@export var tertiary_animation:String
@export var directional_tertiary = false
@export var tertiary_energy = 0.0
@export var dark_tertiary = false
@export var basic_icon:Texture
@export var secondary_icon:Texture
@export var tertiary_icon:Texture
@export_enum("Single", "Horizontal", "Vertical") var hand_texture:int
@export var equip_function:Callable
