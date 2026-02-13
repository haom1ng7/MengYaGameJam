class_name Cannon
extends PossessableBase

# ------------------------------------------------------------------------------
# 配置
# ------------------------------------------------------------------------------
@export_group("Cannon Stats")
@export var rotation_speed: float = 2.0
@export var fire_cooldown: float = 0.5
@export var launch_force: float = 1200.0 ## 发射力度

@export_group("References")
@export var barrel_node: Node2D
@export var muzzle_node: Node2D

# ------------------------------------------------------------------------------
# 内部变量
# ------------------------------------------------------------------------------
var _can_fire: bool = true

# ------------------------------------------------------------------------------
# 虚函数实现
# ------------------------------------------------------------------------------

func _handle_movement(delta: float) -> void:
	# 旋转
	var axis := Input.get_axis("move_left", "move_right")
	if axis and barrel_node:
		barrel_node.rotation += axis * rotation_speed * delta

	# 发射
	if Input.is_action_just_pressed("jump") and _can_fire:
		_fire_player()

func get_eject_position() -> Vector2:
	return muzzle_node.global_position if muzzle_node else super.get_eject_position()

# ------------------------------------------------------------------------------
# 逻辑实现
# ------------------------------------------------------------------------------

func _fire_player() -> void:
	# 调用基类强引用
	if not _player: return
	
	_can_fire = false
	
	var dir := Vector2.RIGHT.rotated(barrel_node.global_rotation)
	var launch_vel := dir * launch_force
	
	# 调用 PlayerController API
	_player.force_detach(launch_vel)
	
	# 简单的冷却计时
	await get_tree().create_timer(fire_cooldown).timeout
	_can_fire = true
	
# 让 WiFi 注入“当前操控这个炮台的玩家”
func set_remote_driver(p) -> void:
	_player = p
