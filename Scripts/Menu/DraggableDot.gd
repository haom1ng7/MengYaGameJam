extends TextureRect
class_name DraggableDot

signal dropped(dot: DraggableDot)

var home_pos := Vector2.ZERO
var _dragging := false
var _drag_offset := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	home_pos = global_position

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_offset = global_position - get_global_mouse_position()
			move_to_front()
		else:
			_dragging = false
			dropped.emit(self)

	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() + _drag_offset

func snap_back() -> void:
	global_position = home_pos
