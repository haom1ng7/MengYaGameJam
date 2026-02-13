extends Node2D

@export var door_path: NodePath

@export var up_texture: Texture2D
@export var down_texture: Texture2D

@onready var door = get_node(door_path)
@onready var sprite: Sprite2D = $Sprite2D

var player_in_range := false
var is_on := false


func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

	update_visual()


func _process(delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		toggle()


func toggle():
	is_on = !is_on

	update_visual()

	if door:
		door.set_open(is_on)

	print("lever:", is_on)


func update_visual():
	if is_on:
		sprite.texture = down_texture
	else:
		sprite.texture = up_texture


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
