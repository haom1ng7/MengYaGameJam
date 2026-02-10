class_name WiFi
extends PossessableBase

# ------------------------------------------------------------------------------
# 配置
# ------------------------------------------------------------------------------
@export var remote_target: PossessableBase ## 远程控制的目标

# ------------------------------------------------------------------------------
# 生命周期
# ------------------------------------------------------------------------------

func _ready() -> void:
	super._ready()
	# 禁用自动相机跟随，因为我们要看远程目标
	snap_camera = false

# ------------------------------------------------------------------------------
# 虚函数实现
# ------------------------------------------------------------------------------

func _handle_input(_delta: float) -> void:
	if not remote_target or not _player: return
	
	# 强制移动玩家的相机到远程目标位置
	var cam = _player.get_camera()
	if cam:
		cam.global_position = remote_target.global_position

func _on_possess_start() -> void:
	if remote_target:
		remote_target.set_remote_control(true)
		print("WiFi: Remote control started -> ", remote_target.name)

func _on_possess_end() -> void:
	if remote_target:
		remote_target.set_remote_control(false)
		print("WiFi: Remote control ended")

func _handle_passive_physics(_delta: float) -> void:
	# WiFi 是固定在墙上或空中的装置，不受重力影响
	velocity = Vector2.ZERO
