extends Control

signal resume

func _ready():
	$CanvasLayer2/PanelContainer/ButtonsLayout/Resume.grab_focus()

func _on_resume_pressed() -> void: #Callback function when the resume button is pressed
	resume.emit()

func _on_options_pressed() -> void: #Callback function when the options button is pressed
	pass #A placeholder for future options menu functionality. SOON! Maybe! :)

func _on_quit_pressed() -> void: #Callback function when the quit button is pressed
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		get_viewport().set_input_as_handled()
		resume.emit()
