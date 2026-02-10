class_name Runner
extends PossessableBase

# ------------------------------------------------------------------------------
# 导出变量
# ------------------------------------------------------------------------------
@export_group("Runner Stats")
@export var speed: float = 150.0
@export var jump_force: float = -400.0
@export var gravity_scale: float = 1.0

# ------------------------------------------------------------------------------
# 重写虚函数
# ------------------------------------------------------------------------------

func _handle_movement(delta: float) -> void:
	# 应用重力
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta

	# 左右移动 (附身状态下监听玩家输入)
	var input_axis = Input.get_axis("move_left", "move_right")
	if input_axis:
		velocity.x = input_axis * speed
		# 简单的面朝向翻转
		# Sprite要是第一个子节点
		var sprite = get_node_or_null("Sprite2D")
		if sprite:
			sprite.flip_h = input_axis < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# 跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	# 基类的 _physics_process 会在调用完这个函数后调用 move_and_slide()
	# 所以这里不需要写 move_and_slide(),直接修改 velocity 即可

func _handle_passive_physics(delta: float) -> void:
	# 未附身时，只有重力和阻力
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity.x = move_toward(velocity.x, 0, speed * delta)

func _on_possess_start() -> void:
	# 在这里播放变身动画
	print("Runner: 被附身了！获得跳跃能力")

func _on_possess_end() -> void:
	# 在这里播放变回原形的动画
	print("Runner: 玩家离开了。")
