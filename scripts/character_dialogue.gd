extends CanvasLayer

@export var dialogue: PackedStringArray
var next_index: int = 0

signal completed

func advance() -> void:
	if next_index >= dialogue.size():
		completed.emit()
		return
	$TextureRect/MarginContainer/Label.text = dialogue[next_index]
	next_index += 1

func _ready() -> void:
	advance()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") and not get_tree().paused:
		advance()
