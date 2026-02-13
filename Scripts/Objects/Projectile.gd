class_name Projectile
extends Area2D

@export var speed: float = 600.0
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# 超时销毁
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# 忽略发射者
	if body is Cannon:
		return

	# 尝试破坏墙壁
	if body.has_method("break_wall"):
		body.break_wall()
		_destroy()
	# 撞击普通墙壁
	elif body is TileMap or body is StaticBody2D:
		_destroy()

func _destroy() -> void:
	# TODO: 爆炸特效
	queue_free()
