extends Node

@onready var mvc = get_tree().current_scene.get_node("%MainViewportContainer")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mvc.show_dialogue(["Why? Why is this my existence?", "Is there no way? Can no one help me?", "I must find a way to be rid of this wretched module..."])

func _on_detonate_info_timer_timeout() -> void:
	mvc.show_dialogue(["*sigh * The Sundial has activated again..."])
