extends Control

@onready var exit_button: Button = $CenterContainer/MenuContent/MenuButtons/ExitButton


func _ready() -> void:
	exit_button.pressed.connect(_on_exit_pressed)


func _on_exit_pressed() -> void:
	get_tree().quit()
