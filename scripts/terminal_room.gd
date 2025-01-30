extends Node

@onready var mvc = get_tree().current_scene.get_node("%MainViewportContainer")
@onready var player = get_tree().current_scene.get_node("%MainViewportContainer").player

func _ready() -> void:
	$FinalSceneTrigger.body_entered.connect(func(body):
		if body == player:
			mvc.show_dialogue(["OK... let's do this.", "*clack clack*", "*beep*", "...", "...", "SUNDIAL  DEACTIVATED", "It... worked?", "Am I... finally free?", "At last..."], true)
	)
