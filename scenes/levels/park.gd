extends Node3D

@onready var mvc = get_tree().current_scene.get_node("%MainViewportContainer")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mvc.show_dialogue(["Looks like there's just one. He shouldn't be too difficult to avoid"])
