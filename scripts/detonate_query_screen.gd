extends Control

signal accepted
signal rejected

func _ready() -> void:
	$HBoxContainer/HBoxContainer/Yes.grab_focus()
	$HBoxContainer/HBoxContainer/Yes.pressed.connect(func(): accepted.emit())
	$HBoxContainer/HBoxContainer/No.pressed.connect(func(): rejected.emit())
