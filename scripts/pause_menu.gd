extends Control

@onready var blur: AnimationPlayer = $AnimationPlayer

func _ready():
	$AnimationPlayer.play("RESET")
	#pass

func resume(): 
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$AnimationPlayer.play_backwards("blur")
	mouse_filter = Control.MOUSE_FILTER_PASS;

func pause():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$AnimationPlayer.play("blur")
	mouse_filter = Control.MOUSE_FILTER_STOP

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("pause_menu"):
			get_viewport().set_input_as_handled()
			if get_tree().paused:
				resume()
			else:
				pause()

func _on_resume_pressed() -> void:
	resume()

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()
