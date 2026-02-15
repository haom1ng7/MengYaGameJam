class_name Runner
extends PossessableBase

# ------------------------------------------------------------------------------
# 配置
# ------------------------------------------------------------------------------
@export_group("Stats")
@export var speed: float = 150.0
@export var jump_force: float = -400.0
@export var gravity_scale: float = 1.0

@export_group("Visuals")
@export var texture_full: Texture2D ## 附身后的贴图
@export var texture_headless: Texture2D ## 未附身的贴图

# ------------------------------------------------------------------------------
# 生命周期
# ------------------------------------------------------------------------------

func _ready() -> void:
	super._ready()
	_update_texture(false)

# ------------------------------------------------------------------------------
# 虚函数实现
# ------------------------------------------------------------------------------

func _handle_movement(delta: float) -> void:
	# 应用重力 (自定义倍率)
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta

	# 移动
	var axis := Input.get_axis("move_left", "move_right")
	if axis:
		velocity.x = axis * speed
		_update_facing(axis > 0)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# 跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		# 检查下跳
		if Input.is_action_pressed("move_down"):
			velocity.y = 0 # 不起跳
			set_collision_mask_value(3, false) # 忽略单向平台 (Layer 3)
			get_tree().create_timer(0.2).timeout.connect(func(): set_collision_mask_value(3, true))
		else:
			# 普通跳跃
			velocity.y = jump_force

func _handle_passive_physics(delta: float) -> void:
	if is_on_floor():
		velocity = Vector2.ZERO
	else:
		velocity += get_gravity() * delta
		print("Applying gravity: ", velocity) # 调试输出

# ------------------------------------------------------------------------------
# 附身/脱离逻辑
# ------------------------------------------------------------------------------

var _possessed: bool = false

func _is_possessed() -> bool:
	return _possessed

func _on_possess_start() -> void:
	_possessed = true
	_update_texture(true)

func _on_possess_end() -> void:
	_possessed = false
	_update_texture(false)
	
	# 重置物理状态
	velocity = Vector2.ZERO
	set_physics_process(true)


# ------------------------------------------------------------------------------
# 内部逻辑
# ------------------------------------------------------------------------------

func _update_facing(is_right: bool) -> void:
	# 翻转 Sprite
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		sprite.flip_h = not is_right
	
	# 镜像特效挂点 X 轴
	if effect_spawn_point:
		effect_spawn_point.position.x = abs(effect_spawn_point.position.x) * (1 if is_right else -1)

func _update_texture(is_full: bool) -> void:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if not sprite: return
		
	if is_full and texture_full:
		sprite.texture = texture_full
	elif not is_full and texture_headless:
		sprite.texture = texture_headless
