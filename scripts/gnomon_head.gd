extends Sprite3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	var relative_rotation = camera.global_position.y - $"..".rotation.y
	frame = wrap(int(round(8 * relative_rotation / TAU)) + 1, 0, 8)
