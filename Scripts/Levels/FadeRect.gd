extends ColorRect

@onready var rect := self

func fade_to_black(time: float) -> void:
	rect.visible = true
	rect.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, time)

	await tween.finished
