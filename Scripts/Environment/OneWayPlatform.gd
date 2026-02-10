@tool
extends StaticBody2D

# ------------------------------------------------------------------------------
# 导出变量
# ------------------------------------------------------------------------------
@export var size: Vector2 = Vector2(100, 20):
	set(value):
		size = value
		_update_shape()

@export var color: Color = Color.AQUA:
	set(value):
		color = value
		queue_redraw()

# ------------------------------------------------------------------------------
# 节点引用
# ------------------------------------------------------------------------------
# 假设存在 CollisionShape2D

func _ready() -> void:
	# 确保 Layer 3
	collision_layer = 1 << 2
	collision_mask = 0
	
	_update_shape()

func _draw() -> void:
	# 绘制矩形 (无贴图)
	var rect = Rect2(-size / 2, size)
	draw_rect(rect, color)

func _update_shape() -> void:
	var col = get_node_or_null("CollisionShape2D")
	if not col:
		return
		
	if not col.shape:
		col.shape = RectangleShape2D.new()
		
	if col.shape is RectangleShape2D:
		col.shape.size = size
		
	# 确保是单向碰撞
	col.one_way_collision = true
	
	# 重绘
	queue_redraw()
