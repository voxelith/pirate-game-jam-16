extends Node3D

# for querying from script
@export var is_triggered: bool = false

# for hooking up other elements
signal triggered
signal untriggered

@onready var player = get_tree().current_scene.get_node("%MainViewportContainer").player

func _ready() -> void:
	$Area3D.body_entered.connect(func(body):
		if body == player:
			is_triggered = true
			triggered.emit()
	)
	$Area3D.body_exited.connect(func(body):
		if body == player:
			is_triggered = false
			untriggered.emit()
	)
