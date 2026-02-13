extends Control

@export var start_scene := "res://Scenes/Levels/Level1.tscn"
@export var chapter_select_scene := "res://Scenes/Levels/SelectMenu.tscn"

@export var snap_distance := 80.0  # 允许的误差半径（像素）

@onready var zone_start: Control  = $TextureRect/StartZone
@onready var zone_select: Control = $TextureRect/SelectZone
@onready var zone_quit: Control   = $TextureRect/QuitZone

@onready var dot_start: DraggableDot  = $TextureRect/MmGreendot
@onready var dot_select: DraggableDot = $TextureRect/MmYellowdot
@onready var dot_quit: DraggableDot   = $TextureRect/MmReddot

func _ready() -> void:
	dot_start.dropped.connect(_on_dot_dropped)
	dot_select.dropped.connect(_on_dot_dropped)
	dot_quit.dropped.connect(_on_dot_dropped)

func _on_dot_dropped(dot: DraggableDot) -> void:
	var target := _target_zone_for(dot)
	if target == null:
		dot.snap_back()
		return

	if _is_in_target(dot, target):
		# 吸附到目标中心（可选，但体验更爽）
		dot.global_position = _zone_center(target)

		# 触发对应操作
		if dot == dot_start:
			_start_game()
		elif dot == dot_select:
			_open_chapter_select()
		elif dot == dot_quit:
			_quit_game()
	else:
		# 没到对应位置 -> 回去
		dot.snap_back()

func _target_zone_for(dot: DraggableDot) -> Control:
	if dot == dot_start:
		return zone_start
	if dot == dot_select:
		return zone_select
	if dot == dot_quit:
		return zone_quit
	return null

func _is_in_target(dot: DraggableDot, zone: Control) -> bool:
	return dot.global_position.distance_to(_zone_center(zone)) <= snap_distance

func _zone_center(z: Control) -> Vector2:
	return z.global_position + z.size * 0.5

func _start_game() -> void:
	get_tree().change_scene_to_file(start_scene)

func _open_chapter_select() -> void:
	get_tree().change_scene_to_file(chapter_select_scene)

func _quit_game() -> void:
	get_tree().quit()
