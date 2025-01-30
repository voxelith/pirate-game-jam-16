extends Area3D

@export var target_level: String
@onready var main_viewport = get_tree().current_scene.get_node("%MainViewportContainer")
@onready var player = get_tree().current_scene.get_node("%MainViewportContainer").player

func change_level():
	main_viewport.change_level(target_level)

func _ready() -> void:
	body_entered.connect(func(body):
		if body == player: call_deferred("change_level")
	)
