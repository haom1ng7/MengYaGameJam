extends Area2D
class_name Finish

@export var next_scene: PackedScene      # 下一关场景
@export var fade_layer_path: NodePath    # 指向 FadeLayer
@export var fade_time: float = 0.6

var _triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _triggered:
		return
	if not body.is_in_group("player"):
		return
	if next_scene == null:
		push_warning("Finish: next_scene 未设置")
		return

	_triggered = true

	var fade := get_node_or_null(fade_layer_path)
	if fade and fade.has_method("fade_to_black"):
		await fade.fade_to_black(fade_time)

	# 切到下一关
	get_tree().change_scene_to_packed(next_scene)
