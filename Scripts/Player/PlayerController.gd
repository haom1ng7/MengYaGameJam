class_name PlayerController
extends CharacterBody2D

# ------------------------------------------------------------------------------
# 状态定义
# ------------------------------------------------------------------------------
enum State {
	NORMAL,   # 正常状态：控制点移动
	POSSESSING # 附身状态：点被隐藏，控制权交给物体
}

# ------------------------------------------------------------------------------
# 导出变量
# ------------------------------------------------------------------------------
@export_group("Movement")
@export var move_speed: float = 200.0
@export var acceleration: float = 1500.0
@export var friction: float = 1000.0

@export_group("Interaction")
@export var detection_radius: float = 50.0

# ------------------------------------------------------------------------------
# 变量
# ------------------------------------------------------------------------------
var current_state: State = State.NORMAL
var current_host: PossessableBase = null # 当前附身的对象
var potential_host: PossessableBase = null # 当前范围内最近的可附身对象

# 节点引用
@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D
@onready var detection_area: Area2D = $DetectionArea

# ------------------------------------------------------------------------------
# 生命周期 (Lifecycle)
# ------------------------------------------------------------------------------
func _ready() -> void:
	# 初始化检测区域
	if detection_area:
		detection_area.body_entered.connect(_on_detection_body_entered)
		detection_area.body_exited.connect(_on_detection_body_exited)

func _physics_process(delta: float) -> void:
	match current_state:
		State.NORMAL:
			_state_normal_update(delta)
		State.POSSESSING:
			_state_possessing_update(delta)

# ------------------------------------------------------------------------------
# 状态逻辑
# ------------------------------------------------------------------------------

## [状态] 正常模式：控制点滚动
func _state_normal_update(delta: float) -> void:
	# 重力
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 左右移动
	var input_axis = Input.get_axis("move_left", "move_right")
	if input_axis:
		velocity.x = move_toward(velocity.x, input_axis * move_speed, acceleration * delta)
		# 滚动视觉效果：根据速度旋转 Sprite
		if sprite:
			sprite.rotate(velocity.x * delta * 0.1)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()
	
	# 交互 (附身)
	if Input.is_action_just_pressed("interact") and potential_host:
		_perform_possession(potential_host)

## [状态] 附身模式：跟随宿主，监听脱离
func _state_possessing_update(delta: float) -> void:
	if is_instance_valid(current_host):
		global_position = current_host.global_position
		
		# 监听脱离
		if Input.is_action_just_pressed("detach"):
			_perform_detach()
	else:
		# 宿主消失异常保护
		_perform_detach()

# ------------------------------------------------------------------------------
# 动作
# ------------------------------------------------------------------------------

func _perform_possession(target: PossessableBase) -> void:
	if current_state == State.POSSESSING:
		return
	
	print("Player: Possessing ", target.name)
	
	# 切换状态
	current_state = State.POSSESSING
	current_host = target
	
	# 视觉处理 (隐藏点或播放动画)
	if sprite:
		sprite.visible = false
	# 禁用自身碰撞，防止与宿主冲突
	set_collision_layer_value(1, false) # 假设Layer 1是玩家
	set_collision_mask_value(1, false) 
	
	# 通知宿主
	target.start_possession(self)
	
	# 相机处理 (略微偏移以适应宿主)
	# 如果 Camera2D 是 Player 的子节点，会自动跟随 Player (而 Player 现在跟随宿主)
	# 可以在这里通过 Tween 调整相机的 offset 或 zoom

func _perform_detach() -> void:
	if current_state != State.POSSESSING or not current_host:
		return
		
	print("Player: Detaching from ", current_host.name)
	
	# 1. 获取弹出位置和速度
	var eject_pos = current_host.get_eject_position()
	var eject_vel = current_host.eject_velocity
	
	# 2. 通知宿主
	current_host.end_possession()
	
	# 3. 恢复自身状态
	current_state = State.NORMAL
	current_host = null
	
	# 4. 物理重置
	global_position = eject_pos
	velocity = eject_vel
	
	if sprite:
		sprite.visible = true
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)

# ------------------------------------------------------------------------------
# 信号回调
# ------------------------------------------------------------------------------

func _on_detection_body_entered(body: Node2D) -> void:
	if body is PossessableBase and body != current_host:
		potential_host = body
		# 可以在这里通知UI显示"按 E 附身"等
		body._update_visual_state(true) # 临时高亮

func _on_detection_body_exited(body: Node2D) -> void:
	if body == potential_host:
		body._update_visual_state(false) # 取消高亮
		potential_host = null
