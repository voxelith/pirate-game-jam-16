extends Control

@export var death_count: int = 0

signal accepted
signal rejected

func trigger_accepted():
	accepted.emit()

func _ready() -> void:
	$HBoxContainer/DeathCount.text = "Entities Purged: %d" % death_count
	
	$HBoxContainer/HBoxContainer/Yes.grab_focus()
	$HBoxContainer/HBoxContainer/Yes.pressed.connect(func(): $AnimationPlayer.play("detonate"))
	$HBoxContainer/HBoxContainer/No.pressed.connect(func(): rejected.emit())

func haptics_strong() -> void:
	Input.start_joy_vibration(0, 0, 1, 2)

func haptics_weak() -> void:
	Input.start_joy_vibration(0, 1, 0, 3)
