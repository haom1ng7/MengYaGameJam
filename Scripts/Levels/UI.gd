extends CanvasLayer
class_name FadeLayer

@onready var rect: ColorRect = $FadeRect

func _ready() -> void:
	# 初始透明
	var c := rect.color
	c.a = 0.0
	rect.color = c

func fade_to_black(duration: float = 0.6) -> void:
	var c := rect.color
	c.a = 0.0
	rect.color = c

	var tw := create_tween()
	tw.tween_property(rect, "color:a", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tw.finished

func fade_from_black(duration: float = 0.6) -> void:
	var c := rect.color
	c.a = 1.0
	rect.color = c

	var tw := create_tween()
	tw.tween_property(rect, "color:a", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
