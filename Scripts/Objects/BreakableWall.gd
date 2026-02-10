class_name BreakableWall
extends StaticBody2D

func break_wall() -> void:
	print("Wall destroyed!")
	# TODO: 碎裂特效
	queue_free()