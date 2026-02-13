extends Node2D

@export var closed_texture: Texture2D
@export var open_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var col: CollisionShape2D = $StaticBody2D/CollisionShape2D

var is_open := false


func _ready():
	_apply_state()

func set_open(value: bool):
	if is_open == value:
		return
	is_open = value
	_apply_state()

func _apply_state():
	sprite.texture = open_texture if is_open else closed_texture
	col.disabled = is_open
