class_name Balloon
extends PossessableBase

# ------------------------------------------------------------------------------
# 配置
# ------------------------------------------------------------------------------
@export_group("Balloon Stats")
@export var buoyancy_force: float = -260.0 ## 向上浮力 (负值表示向上)
@export var horizontal_speed: float = 200.0 ## 左右移动速度
@export var air_friction: float = 0.1 ## 空气阻力 (0-1，越大越快停止)
@export var gravity_scale: float = 0.2 ## 气球受重力的比例 (0-1，越小浮力越明显)

@export_group("Visuals")
@export var texture_full: Texture2D ## 附身后的完整气球贴图
@export var texture_rope: Texture2D ## 未附身的绳索贴图

# ------------------------------------------------------------------------------
# 节点引用
# ------------------------------------------------------------------------------
@onready var _sprite: Sprite2D = $Sprite2D

# ------------------------------------------------------------------------------
# 生命周期
# ------------------------------------------------------------------------------

func _ready() -> void:
	super._ready()
	_update_texture(false)

func _physics_process(delta: float) -> void:
	if is_possessed:
		# 附身状态下，完全接管物理处理
		_handle_input(delta)
		_handle_movement(delta)
		move_and_slide() # 在这里调用 move_and_slide() 以便 is_on_ceiling() 有效

		# 检查是否撞到天花板，如果是则强制脱离
		
	else:
		# 未附身状态下，交由基类处理物理 (即落地静止，空中下落)
		super._physics_process(delta)

# ------------------------------------------------------------------------------
# 虚函数实现
# ------------------------------------------------------------------------------

func _handle_movement(delta: float) -> void:
	# 1. 浮力与重力
	velocity.y += buoyancy_force * delta
	velocity += get_gravity() * gravity_scale * delta

	# 2. 左右移动
	var axis := Input.get_axis("move_left", "move_right")
	if axis:
		velocity.x = move_toward(velocity.x, axis * horizontal_speed, horizontal_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, horizontal_speed * air_friction * delta)
		
	# 限制上升速度
	if velocity.y < buoyancy_force:
		velocity.y = buoyancy_force

# 移除 _handle_passive_physics 的覆盖，让基类处理未附身时的行为

func _on_possess_start() -> void:
	_update_texture(true)
	print("Balloon: 被附身！开始漂浮。")

func _on_possess_end() -> void:
	_update_texture(false)
	print("Balloon: 玩家离开了气球。")

# ------------------------------------------------------------------------------
# 内部逻辑
# ------------------------------------------------------------------------------

func _update_texture(is_full_balloon: bool) -> void:
	if not _sprite: return
		
	if is_full_balloon and texture_full:
		_sprite.texture = texture_full
	elif not is_full_balloon and texture_rope:
		_sprite.texture = texture_rope
