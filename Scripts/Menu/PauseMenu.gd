extends Control

@export var main_menu_scene := "res://Scenes/Levels/MainMenu.tscn"

@onready var resume_btn: Button = $PauseBg/PauseResume/ResumeGameButton
@onready var quit_btn: Button = $PauseBg/PauseExit/ExitLevelButton
@onready var RestartButton: Button = $PauseBg/PauseRestart/RestartLevelButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

	resume_btn.pressed.connect(resume)
	quit_btn.pressed.connect(_on_quit_pressed)
	RestartButton.pressed.connect(OnRestartButtonPressed)

func open() -> void:
	show()
	get_tree().paused = true

func resume() -> void:
	get_tree().paused = false
	hide()
	
func OnRestartButtonPressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func toggle() -> void:
	if visible:
		resume()
	else:
		open()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_scene)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle()
		get_viewport().set_input_as_handled()
