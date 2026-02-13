extends Control

@export var main_menu_scene := "res://Scenes/Levels/MainMenu.tscn"

func _ready() -> void:
	$SelectReturn/BackButton.pressed.connect(_on_back_pressed)

	for btn in $TextureRect/LevelButtons.get_children():
		if btn is Button:
			btn.pressed.connect(_on_level_pressed.bind(btn))

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene)

func _on_level_pressed(btn: Button) -> void:
	var level_path = btn.get_meta("scene_path")
	get_tree().change_scene_to_file(level_path)
