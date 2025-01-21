extends Control

@onready var blur: AnimationPlayer = $AnimationPlayer
@onready var resum_button: Button = find_child("Resume")
@onready var quit_button: Button = find_child("Quit")

func _ready():
	$AnimationPlayer.play("RESET")
	#pass

func resume(): 
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$AnimationPlayer.play_backwards("blur")
	$PanelContainer.mouse_filter = $PanelContainer.MOUSE_FILTER_IGNORE

func  pause():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$AnimationPlayer.play("blur")

func _process(delta:):
	esc()

func esc():
	if Input.is_action_just_pressed("pause_menu") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("pause_menu") and get_tree().paused == true:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()
