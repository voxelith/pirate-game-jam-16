extends Control

@onready var blur: AnimationPlayer = $AnimationPlayer

func _ready():
	$AnimationPlayer.play("RESET") #Play the "RESET" animation to set the initial state.
	$CanvasLayer2/PanelContainer/ButtonsLayout/Resume.grab_focus() #Set initial focus to the Resume button.

func resume(): #Function to resume the game
	get_tree().paused = false #Unpause the game
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #Capture the mouse for gameplay
	$AnimationPlayer.play_backwards("blur") #Play the blur animation in reverse to remove the blur effect
	mouse_filter = Control.MOUSE_FILTER_PASS; #Allow mouse events to pass through the control

func pause(): #Function to pause the game
	get_tree().paused = true #Pause the game
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) #Make the mouse cursor visible
	$AnimationPlayer.play("blur") #Play the blur animation to show the pause effect
	mouse_filter = Control.MOUSE_FILTER_STOP #Stop mouse events from passing through the control

func _input(event: InputEvent) -> void: #Handles player input
	if Input.is_action_just_pressed("pause_menu"): #Checks if the pause menu action key was pressed
		get_viewport().set_input_as_handled() #Mark input as handled to prevent further processsing
		if get_tree().paused:
			resume()
		else:
			pause()
	elif Input.is_action_just_pressed("ui_cancel"):
		resume()

func _on_resume_pressed() -> void: #Callback function when the resume button is pressed
	resume()

func _on_options_pressed() -> void: #Callback function when the options button is pressed
	pass #A placeholder for future options menu functionality. SOON! Maybe! :)

func _on_quit_pressed() -> void: #Callback function when the quit button is pressed
	get_tree().quit()



#Don't look up this URL link! Trust me! https://youtu.be/dQw4w9WgXcQ?si=9WfgZOLFZqoAO7QQ
