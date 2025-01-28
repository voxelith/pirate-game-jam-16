extends Control

@export var death_count: int = 0

signal accepted
signal rejected

func _ready() -> void:
	$HBoxContainer/DeathCount.text = "Death count: %d" % death_count
	
	$HBoxContainer/HBoxContainer/Yes.grab_focus()
	$HBoxContainer/HBoxContainer/Yes.pressed.connect(func(): accepted.emit())
	$HBoxContainer/HBoxContainer/No.pressed.connect(func(): rejected.emit())
