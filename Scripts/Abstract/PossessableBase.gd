class_name PossessableBase
extends CharacterBody2D

# ------------------------------------------------------------------------------
# 信号
# ------------------------------------------------------------------------------
signal possessed_start ## 开始附身
signal possessed_end ## 结束附身

# ------------------------------------------------------------------------------
# 配置
# ------------------------------------------------------------------------------
@export_group("Possession Settings")
@export var snap_camera: bool = true ## 附身时相机是否跟随
@export var camera_offset: Vector2 = Vector2(0, -50)
@export var eject_velocity: Vector2 = Vector2(0, -300) ## 默认脱离速度
@export var possess_effect: PackedScene ## 附身特效
@export var effect_spawn_point: Node2D ## 特效生成点 (可选)

# ------------------------------------------------------------------------------
# 状态
# ------------------------------------------------------------------------------
var is_possessed: bool = false
var _player: PlayerController = null

# ------------------------------------------------------------------------------
# 生命周期
# ------------------------------------------------------------------------------
func _ready() -> void:
	add_to_group("possessable")
	_update_visual_state(false)

func _physics_process(delta: float) -> void:
	if is_possessed:
		_handle_input(delta)
		_handle_movement(delta)
		move_and_slide()
	else:
		_handle_passive_physics(delta)
		# 性能优化: 静止时不计算物理
		if not velocity.is_zero_approx():
			move_and_slide()

# ------------------------------------------------------------------------------
# 公共接口
# ------------------------------------------------------------------------------

## 开始附身
func start_possession(player: PlayerController) -> void:
	if is_possessed: return
		
	is_possessed = true
	_player = player
	
	_spawn_effect()
	emit_signal("possessed_start")
	_update_visual_state(true)
	_on_possess_start()

## 结束附身
func end_possession() -> void:
	if not is_possessed: return
	
	is_possessed = false
	emit_signal("possessed_end")
	_update_visual_state(false)
	_on_possess_end()
	
	_player = null

## 获取弹出位置
func get_eject_position() -> Vector2:
	return global_position + Vector2.UP * 20.0

# ------------------------------------------------------------------------------
# 内部辅助
# ------------------------------------------------------------------------------

func _spawn_effect() -> void:
	if not possess_effect: return
	
	var fx = possess_effect.instantiate() as Node2D
	get_parent().add_child(fx)
	
	if effect_spawn_point:
		fx.global_position = effect_spawn_point.global_position
	else:
		fx.global_position = get_eject_position()

func _update_visual_state(active: bool) -> void:
	modulate = Color(1.2, 1.2, 1.2) if active else Color.WHITE

# ------------------------------------------------------------------------------
# 虚函数 (子类重写)
# ------------------------------------------------------------------------------

func _handle_input(_delta: float) -> void: pass
func _handle_movement(_delta: float) -> void: pass
func _on_possess_start() -> void: pass
func _on_possess_end() -> void: pass

func _handle_passive_physics(delta: float) -> void:
	if is_on_floor():
		velocity = Vector2.ZERO
	else:
		velocity += get_gravity() * delta
