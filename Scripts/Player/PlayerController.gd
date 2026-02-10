class_name PlayerController
extends CharacterBody2D

# ------------------------------------------------------------------------------
# 类型定义
# ------------------------------------------------------------------------------
enum State { NORMAL, POSSESSING }

# ------------------------------------------------------------------------------
# 配置
# ------------------------------------------------------------------------------
@export_group("Movement")
@export var move_speed: float = 200.0
@export var acceleration: float = 1500.0
@export var friction: float = 1000.0
@export var air_drag_coefficient: float = 0.01 ## 空中阻力系数 (0-1)

@export_group("Combat")
@export var break_velocity_threshold: float = 600.0 ## 破墙速度阈值

@export_group("Interaction")
@export var detection_radius: float = 50.0

# ------------------------------------------------------------------------------
# 节点引用
# ------------------------------------------------------------------------------
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _detection_area: Area2D = $DetectionArea

# ------------------------------------------------------------------------------
# 状态变量
# ------------------------------------------------------------------------------
var _current_state: State = State.NORMAL
var _current_host: PossessableBase = null
var _potential_host: PossessableBase = null

# ------------------------------------------------------------------------------
# 生命周期
# ------------------------------------------------------------------------------
func _ready() -> void:
	if _detection_area:
		_detection_area.body_entered.connect(_on_detection_area_entered)
		_detection_area.body_exited.connect(_on_detection_area_exited)

func _physics_process(delta: float) -> void:
	match _current_state:
		State.NORMAL:
			_update_state_normal(delta)
		State.POSSESSING:
			_update_state_possessing(delta)

# ------------------------------------------------------------------------------
# 状态逻辑
# ------------------------------------------------------------------------------

func _update_state_normal(delta: float) -> void:
	_apply_gravity(delta)
	_handle_move_input(delta)
	
	# 记录碰撞前速度
	var impact_speed := velocity.length()
	move_and_slide()
	_handle_collisions(impact_speed)
	
	# 附身检测
	if Input.is_action_just_pressed("interact") and _potential_host:
		_perform_possession(_potential_host)

func _update_state_possessing(_delta: float) -> void:
	# 异常保护
	if not is_instance_valid(_current_host):
		_perform_detach()
		return

	global_position = _current_host.global_position
	
	if Input.is_action_just_pressed("detach"):
		_perform_detach()

# ------------------------------------------------------------------------------
# 物理子系统
# ------------------------------------------------------------------------------

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _handle_move_input(delta: float) -> void:
	var axis := Input.get_axis("move_left", "move_right")
	
	if axis:
		velocity.x = move_toward(velocity.x, axis * move_speed, acceleration * delta)
		if _sprite: _sprite.rotate(velocity.x * delta * 0.1)
	else:
		# 地面强摩擦，空中微弱阻力
		var drag = friction if is_on_floor() else friction * air_drag_coefficient
		velocity.x = move_toward(velocity.x, 0, drag * delta)

	# 单向平台下跳 (Layer 3)
	if is_on_floor() and Input.is_action_pressed("move_down") and Input.is_action_just_pressed("jump"):
		set_collision_mask_value(3, false)
		get_tree().create_timer(0.2).timeout.connect(func(): set_collision_mask_value(3, true))

func _handle_collisions(impact_speed: float) -> void:
	if impact_speed < break_velocity_threshold: return
	if get_slide_collision_count() == 0: return
	
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider.has_method("break_wall"):
			collider.break_wall()

# ------------------------------------------------------------------------------
# 动作
# ------------------------------------------------------------------------------

func _perform_possession(target: PossessableBase) -> void:
	print("Player: Possessing ", target.name)
	
	_current_state = State.POSSESSING
	_current_host = target
	
	_set_physics_active(false)
	target.start_possession(self)

func _perform_detach(velocity_override: Variant = null) -> void:
	if not _current_host: return
	print("Player: Detaching from ", _current_host.name)
	
	# 计算退出参数
	var exit_pos = _current_host.get_eject_position()
	var exit_vel = velocity_override if (velocity_override is Vector2) else _current_host.eject_velocity
	
	# 通知宿主
	_current_host.end_possession()
	_current_host = null
	
	# 恢复状态
	_current_state = State.NORMAL
	global_position = exit_pos
	velocity = exit_vel
	
	_set_physics_active(true)

## [API] 强制脱离
func force_detach(launch_velocity: Vector2) -> void:
	_perform_detach(launch_velocity)

func _set_physics_active(active: bool) -> void:
	if _sprite: _sprite.visible = active
	set_collision_layer_value(1, active)
	set_collision_mask_value(1, active)

# ------------------------------------------------------------------------------
# 事件回调
# ------------------------------------------------------------------------------

func _on_detection_area_entered(body: Node2D) -> void:
	if body is PossessableBase and body != _current_host:
		_potential_host = body
		body._update_visual_state(true)

func _on_detection_area_exited(body: Node2D) -> void:
	if body == _potential_host:
		body._update_visual_state(false)
		_potential_host = null
