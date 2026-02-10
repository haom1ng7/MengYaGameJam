class_name OneShotEffect
extends AnimatedSprite2D

@export var auto_play_anim: String = "default"

func _ready() -> void:
	# 监听动画结束
	animation_finished.connect(_on_animation_finished)
	
	# 播放指定动画
	if sprite_frames and sprite_frames.has_animation(auto_play_anim):
		play(auto_play_anim)
	else:
		# 默认播放
		play()

func _on_animation_finished() -> void:
	queue_free()
