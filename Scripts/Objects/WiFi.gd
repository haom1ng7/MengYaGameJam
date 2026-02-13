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

func _handle_input(delta: float) -> void:
	if not remote_target or not _player: return

	# 相机看远程目标
	var cam = _player.get_camera()
	if cam:
		cam.global_position = remote_target.global_position

	# ✅ 把“操控更新”转给远程目标（Cannon 才能检测 jump 并发射）
	if remote_target.has_method("_handle_movement"):
		remote_target.call("_handle_movement", delta)


func _on_possess_start() -> void:
	if remote_target:
		# ✅ 把玩家引用交给远程目标（只要远程目标实现了这个方法）
		if remote_target.has_method("set_remote_driver"):
			remote_target.call("set_remote_driver", _player)

		remote_target.set_remote_control(true)
		print("WiFi: Remote control started -> ", remote_target.name)

func _on_possess_end() -> void:
	if remote_target:
		remote_target.set_remote_control(false)

		# ✅ 清理
		if remote_target.has_method("set_remote_driver"):
			remote_target.call("set_remote_driver", null)

		print("WiFi: Remote control ended")


func _handle_passive_physics(_delta: float) -> void:
	# WiFi 是固定在墙上或空中的装置，不受重力影响
	velocity = Vector2.ZERO
	
func get_eject_position() -> Vector2:
	if remote_target:
		return remote_target.global_position
	return global_position
