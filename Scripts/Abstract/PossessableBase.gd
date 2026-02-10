class_name PossessableBase
extends CharacterBody2D


# 供附身的物体的基类
# ------------------------------------------------------------------------------
# 信号 (Signals)
# ------------------------------------------------------------------------------
signal possessed_start ## 开始附身时发出
signal possessed_end ## 结束附身时发出

# ------------------------------------------------------------------------------
# 导出变量 (Exports)
# ------------------------------------------------------------------------------
@export_group("Possession Settings")
## 附身时相机是否应该平滑移动到此物体
@export var snap_camera: bool = true
## 附身后的相机偏移量
@export var camera_offset: Vector2 = Vector2(0, -50)
## 脱离时，玩家(点)弹出的初始速度向量
@export var eject_velocity: Vector2 = Vector2(0, -300)

# ------------------------------------------------------------------------------
# 变量
# ------------------------------------------------------------------------------
var is_possessed: bool = false
var _player_ref: Node2D = null # 存储对玩家(点)的引用

# ------------------------------------------------------------------------------
# 生命周期
# ------------------------------------------------------------------------------
func _ready() -> void:
	# 确保未附身时处于非活跃状态(根据需要调整，比如有些物体未附身也需要物理)
	add_to_group("possessable")
	_update_visual_state(false)

func _physics_process(delta: float) -> void:
	if is_possessed:
		_handle_input(delta)
		_handle_movement(delta)
	else:
		_handle_passive_physics(delta)
	
	move_and_slide()

# ------------------------------------------------------------------------------
# 公共接口
# ------------------------------------------------------------------------------

## 尝试附身此物体
## @param player: 发起附身的玩家节点
func start_possession(player: Node2D) -> void:
	if is_possessed:
		return
		
	is_possessed = true
	_player_ref = player
	
	# 隐藏玩家或将其吸附过来
	# 这里假设逻辑是：玩家节点被“隐藏”并跟随此物体，或者单纯逻辑上移交控制权
	# 具体的玩家隐藏逻辑可以在 PlayerController 中处理，这里主要处理自身状态
	
	emit_signal("possessed_start")
	_update_visual_state(true)
	_on_possess_start()

## 尝试脱离附身
func end_possession() -> void:
	if not is_possessed:
		return
	
	is_possessed = false
	emit_signal("possessed_end")
	_update_visual_state(false)
	_on_possess_end()
	
	# 重置引用
	_player_ref = null

## 获取脱离时的生成位置 (通常是物体中心或头顶)
func get_eject_position() -> Vector2:
	return global_position + Vector2.UP * 20.0 # 默认向上偏移一点

# ------------------------------------------------------------------------------
# 虚函数 (Virtual Methods - 供子类重写)
# ------------------------------------------------------------------------------

## [虚函数] 处理附身状态下的输入
func _handle_input(delta: float) -> void:
	pass

## [虚函数] 处理附身状态下的物理移动
func _handle_movement(delta: float) -> void:
	pass

## [虚函数] 处理非附身状态下的被动物理 (如重力下落)
func _handle_passive_physics(delta: float) -> void:
	# 默认添加重力，防止悬空
	if not is_on_floor():
		velocity += get_gravity() * delta

## [虚函数] 附身开始时的回调 (播放动画/音效)
func _on_possess_start() -> void:
	pass

## [虚函数] 附身结束时的回调
func _on_possess_end() -> void:
	pass
	
## [辅助] 更新视觉状态 (高亮/动画切换)
func _update_visual_state(active: bool) -> void:
	# 子类可重写此函数改变外观
	if active:
		modulate = Color(1.2, 1.2, 1.2) # 简单高亮
	else:
		modulate = Color.WHITE
