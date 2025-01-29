extends Control

@onready var blur: AnimationPlayer = $AnimationPlayer

# Stores whether the tree was paused when the menu is opened
var _is_tree_paused: bool = false

signal resumed

func _ready():
	$AnimationPlayer.play("RESET") #Play the "RESET" animation to set the initial state.

func resume(): #Function to resume the game
	print("begin resume")
	get_tree().paused = _is_tree_paused
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #Capture the mouse for gameplay
	$AnimationPlayer.play_backwards("blur") #Play the blur animation in reverse to remove the blur effect
	$AnimationPlayer.animation_finished.connect(func(): resumed.emit(); print("resumed"))
	mouse_filter = Control.MOUSE_FILTER_PASS; #Allow mouse events to pass through the control
	
	#resumed.emit()

func pause(): #Function to pause the game
	_is_tree_paused = get_tree().paused
	get_tree().paused = true #Pause the game
	$CanvasLayer2/PanelContainer/ButtonsLayout/Resume.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) #Make the mouse cursor visible
	$AnimationPlayer.play("blur") #Play the blur animation to show the pause effect
	mouse_filter = Control.MOUSE_FILTER_STOP #Stop mouse events from passing through the control

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		get_viewport().set_input_as_handled()
		resume()

func _on_resume_pressed() -> void: #Callback function when the resume button is pressed
	resume()

func _on_options_pressed() -> void: #Callback function when the options button is pressed
	pass #A placeholder for future options menu functionality. SOON! Maybe! :)

func _on_quit_pressed() -> void: #Callback function when the quit button is pressed
	get_tree().quit()
