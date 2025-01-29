extends Sprite3D

@export var disintegrate_stage: int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	var relative_rotation = camera.global_rotation.y - global_rotation.y
	frame_coords = Vector2i(wrap(int(round(8 * relative_rotation / TAU)), 0, 8), disintegrate_stage)
